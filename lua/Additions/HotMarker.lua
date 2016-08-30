Script.Load("lua/ScriptActor.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/OwnerMixin.lua")

-- store tables of effects played recently for entities, so same effects won't stack and spam the client and network (multiple bilebombs in one place)
local gRecentEffects = {}


class 'HotMarker' (ScriptActor)

HotMarker.kMapName = "hotmarker"

local kDefaultEffectName = "damage"

local networkVars =
{
    targetId = "entityid"
}

AddMixinNetworkVars(TeamMixin, networkVars)

HotMarker.kType = enum({'Static', 'Dynamic', 'SingleTarget'})

local function GetRelativImpactPoint(origin, hitEntity)

    PROFILE("GetRelativImpactPoint")

    local impactPoint = nil
    local worldImpactPoint = nil

    local targetOrigin = hitEntity:GetOrigin() + Vector(0, 0.2, 0)

    if hitEntity.GetEngagementPoint then
        targetOrigin = hitEntity:GetEngagementPoint()
    end
    
    if origin == targetOrigin then
        return Vector(0,0.2,0), targetOrigin
    end
    
    local trace = Shared.TraceRay(origin, targetOrigin, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOnly(hitEntity))

    if trace.entity == hitEntity then
    
        impactPoint = Vector()
        local hitEntityCoords = hitEntity:GetCoords()
        local direction = trace.endPoint - hitEntityCoords.origin
        impactPoint.z = hitEntityCoords.zAxis:DotProduct(direction)
        impactPoint.x = hitEntityCoords.xAxis:DotProduct(direction)
        impactPoint.y = hitEntityCoords.yAxis:DotProduct(direction)
        worldImpactPoint = trace.endPoint

    else
    
        local trace = Shared.TraceRay(origin, targetOrigin, CollisionRep.LOS, PhysicsMask.Bullets, EntityFilterAll())
        if trace.fraction > 0.9 then
        
            impactPoint = Vector(0,0.2,0)
            worldImpactPoint = hitEntity:GetOrigin()
        
        end
    
    end

    return impactPoint, worldImpactPoint

end

function HotMarker:SetFallOffFunc(fallOffFunc)
    self.fallOffFunc = fallOffFunc
end

local function ConstructTargetEntry(origin, hitEntity, heal, radius, ignoreLos, customImpactPoint, fallOffFunc)

    local entry = {}
    
    if not hitEntity or not hitEntity:GetIsAlive() or GetIsVortexed(hitEntity) then
        return nil
    end    

    local worldImpactPoint = nil
    entry.impactPoint, worldImpactPoint = GetRelativImpactPoint(origin, hitEntity)
    
    if entry.impactPoint or ignoreLos or customImpactPoint then
    
        if not worldImpactPoint then
            worldImpactPoint = hitEntity:GetOrigin()
        end
        
        entry.id = hitEntity:GetId()
        if radius ~= 0 then
        
            local distanceFraction = (worldImpactPoint - origin):GetLength() / radius
            if fallOffFunc then
                distanceFraction = fallOffFunc(distanceFraction)
            end
            distanceFraction = Clamp(distanceFraction, 0, 1)
            entry.heal = heal * (1 - distanceFraction)
            
        else
            entry.heal = heal
        end
        
        entry.heal = math.max(entry.heal, 0.1)
        
        if customImpactPoint then
            entry.impactPoint = customImpactPoint
        else
            entry.impactPoint = ConditionalValue(entry.impactPoint, entry.impactPoint, Vector(0,0,0))
        end
        
        return entry
    
    end

end

-- caches heal dropoff and target ids so it does not need to be recomputed every time
local function ConstructCachedTargetList(origin, forTeam, heal, radius, fallOffFunc)

    local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", forTeam, origin, radius)
    local targetList = {}
    local targetIds = {}
    
    for index, hitEntity in ipairs(hitEntities) do
        local entry = ConstructTargetEntry(origin, hitEntity, heal, radius, false, nil, fallOffFunc)
        
        if entry then
            table.insert(targetList, entry)
            targetIds[hitEntity:GetId()] = true
        end
    end
    
    return targetList, targetIds
    
end

function HotMarker:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, EntityChangeMixin)
    
    self.targetList = nil
    self.damageIntervall = 4
    self.healamt = 16
    self.radius = 8
    self.targetEffectName = kDefaultEffectName
    self.targetId = Entity.invalidId
    self.HotMarkerType = HotMarker.kType.Static
    self.timeLastUpdate = Shared.GetTime()
    self.deathIconIndex = kDeathMessageIcon.None
    self.targetIds = {}

end

function HotMarker:TimeUp()
    DestroyEntity(self)
end

function HotMarker:GetNotifiyTarget(target)
    return not target or not target:isa("Player")
end

function HotMarker:SetLifeTime(lifeTime)
    self:AddTimedCallback(HotMarker.TimeUp, lifeTime)
end

function HotMarker:SetHotMarkerType(HotMarkerType)
    self.HotMarkerType = HotMarkerType
end

function HotMarker:SetTargetEffectName(targetEffectName)
    self.targetEffectName = targetEffectName
end

function HotMarker:SetDamageIntervall(damageIntervall)
    self.damageIntervall = damageIntervall
    self.timeLastUpdate = Shared.GetTime()
end

function HotMarker:SetTechId( id )
	self.techId = id
end

function HotMarker:GetTechId()
	return self.techId
end
	

-- this is per second
function HotMarker:SetDamage(damage)
    self.damage = damage
end

function HotMarker:SetRadius(radius)
    self.radius = radius
end

function HotMarker:SetDeathIconIndex(iconIndex)
    self.deathIconIndex = iconIndex
end

function HotMarker:GetDeathIconIndex()
    return self.deathIconIndex
end

function HotMarker:SetAttachToTarget(target, impactPoint)

    self.targetId = target:GetId()
    
    -- store relative impact point
    if impactPoint then
        local hitEntityCoords = target:GetCoords()
        local direction = impactPoint - hitEntityCoords.origin
        self.impactPoint = Vector(0,0,0)
        self.impactPoint.z = hitEntityCoords.zAxis:DotProduct(direction)
        self.impactPoint.x = hitEntityCoords.xAxis:DotProduct(direction)
        self.impactPoint.y = hitEntityCoords.yAxis:DotProduct(direction)
    end
    
end
local function HealEntityActual(self, who)
  local health = kHealsprayDamage + who:GetMaxHealth() * 3 / 100.0
  local parent = self:GetOwner() or nil 
    
    -- Heal structures by multiple of damage(so it doesn't take forever to heal hives, ala NS1)
    if GetReceivesStructuralDamage(who) then
        health = 60
    -- Don't heal self at full rate - don't want Gorges to be too powerful. Same as NS1.
    elseif who == parent then
        health = health * 0.5
    end
    
    local amountHealed = who:AddHealth(health, true, false, true, self:GetOwner() or nil)
    
    -- Do not count amount self healed.
    if targetEntity ~= parent then
        self:GetOwner():AddContinuousScore("HealSpray", amountHealed, kAmountHealedForPoints, kHealScoreAdded)
    end
    
    if targetEntity.OnHealSpray then
        targetEntity:OnHealSpray(parent)
    end
    
    -- Put out entities on fire sometimes.
    if HasMixin(who, "GameEffects") and math.random() < kSprayDouseOnFireChance then
        who:SetGameEffectMask(kGameEffect.OnFire, false)
    end
    
    if Server and amountHealed > 0 then
        who:TriggerEffects("sprayed")
    end
end
local function ApplyHeal(self, targetList)

    for index, targetEntry in ipairs(targetList) do
    
        local entity = Shared.GetEntity(targetEntry.id)     

        if entity and self.destroyCondition and self.destroyCondition(self, entity) then
            DestroyEntity(self)
            break
        end
   
        if entity and self.targetIds[entity:GetId()] and entity:GetIsAlive() and (not self.immuneCondition or not self.immuneCondition(self, entity)) then

            local worldImpactPoint = entity:GetCoords():TransformPoint(targetEntry.impactPoint)
            HealEntityActual(self, entity)
              
        end
        
    end

end

function HotMarker:OnEntityChange(oldId)

    if self.HotMarkerType == HotMarker.kType.SingleTarget then
    
        if oldId == self.targetId then
            DestroyEntity(self)
        end
        
    elseif self.HotMarkerType == HotMarker.kType.Static then

        if self.targetIds[oldId] ~= nil then
            self.targetIds[oldId] = false
        end
    
    end
end

function HotMarker:SetDestroyCondition(func)
    self.destroyCondition = func
end

function HotMarker:OnUpdate(deltaTime)

    if Server then

        if self.timeLastUpdate + self.damageIntervall < Shared.GetTime() then
            -- we are attached to a target, update position
            if self.targetId ~= Entity.invalidId then        
                local target = Shared.GetEntity(self.targetId)
                if target then
                    self:SetOrigin(target:GetOrigin())  
                end
            end

            local targetList = self.targetList
            
            if self.HotMarkerType == HotMarker.kType.SingleTarget then

                -- single target will deal damage only to the attached target (used for poison dart)
                if not targetList and self.targetId ~= Entity.invalidId then
                    
                    local target = Shared.GetEntity(self.targetId)

                    if target then

                        self.targetList = {}
                        table.insert(self.targetList, ConstructTargetEntry(self:GetOrigin(), target, self.damage, self.radius, true, self.impactPoint, self.fallOffFunc) )
                        targetList = self.targetList
                        
                    end
                    
                end

            elseif self.HotMarkerType == HotMarker.kType.Dynamic then
            
                -- in case for dynamic dot marker recalculate the target list each damage tick (used for burning)
                targetList = ConstructCachedTargetList(self:GetOrigin(), self:GetTeamNumber(), self.healamt, self.radius, self.fallOffFunc)
                
            elseif self.HotMarkerType == HotMarker.kType.Static then
            
                -- calculate the target list once and reuse it later (used for bilebomb)
                if not targetList then
                    self.targetList, self.targetIds = ConstructCachedTargetList(self:GetOrigin(), GetEnemyTeamNumber(self:GetTeamNumber()), self.healamt, self.radius, self.fallOffFunc)
                    targetList = self.targetList
                end
            
            end
            
            if targetList then
                ApplyHeal(self, targetList)
            end
                
            self.timeLastUpdate = Shared.GetTime()
            
        end
    
    elseif Client then
    
    
    end

end


Shared.LinkClassToMap("HotMarker", HotMarker.kMapName, networkVars)