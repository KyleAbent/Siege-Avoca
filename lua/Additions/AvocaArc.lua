--Kyle 'Avoca' Abent
class 'AvocaArc' (ARC)
AvocaArc.kMapName = "avocaarc"
local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")
local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

function AvocaArc:OnCreate()
 ARC.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())

end
function AvocaArc:OnInitialized()
 ARC.OnInitialized(self)
   if Server then
 self:AddTimedCallback(AvocaArc.Instruct, 2.5)
 self:AddTimedCallback(AvocaArc.Waypoint, 16)
  self:AddTimedCallback(AvocaArc.Scan, 6)
 end

end

function AvocaArc:GetMaxHealth()
    return 4000
end
function AvocaArc:GetMaxArmor()
    return 1200
end
local function SoTheGameCanEnd(self, who) --Although HiveDefense prolongs it
   local arc = GetEntitiesWithinRange("ARC", who:GetOrigin(), ARC.kFireRange)
   if #arc >= 1 then CreateEntity(Scan.kMapName, who:GetOrigin(), 1) end
end
local function CheckHivesForScan()
local hives = {}
           for _, hiveent in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             table.insert(hives, hiveent)
          end
          if #hives == 0 then return end
          --Scan hive if arc in range, only 1 check per hive.. not per arc.. or whatever. 
          for i = 1, #hives do
             local ent = hives[i]
             SoTheGameCanEnd(self, ent)
          end
end
function ARC:GetShowDamageIndicator()
    return true
end
function AvocaArc:LameFixATM()
self:AddTimedCallback(AvocaArc.Check, 8)
end
function ARC:Check()
  local gamestarted = false 
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if gamestarted then DestroyEntity(self) end
   return false
end
local function MoveToHives(who) --Closest hive from origin
local where = who:GetOrigin()
 local hive =  GetNearest(where, "Hive", 2, function(ent) return not ent:GetIsDestroyed() end)

 
               if hive then
        local origin = hive:GetOrigin() -- The arc should auto deploy beforehand
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                    return
                end  
    -- Print("No closest hive????")    
end

local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTarget(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end

local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
local function BuffPlayersNearby(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 5.5)
local alive = false
         for i = 1, #players do
            local player = players[i]
            if player:GetIsAlive() and alive == false then alive = true end
            if ( player:GetIsAlive() and  player.GetIsNanoShielded and not player:GetIsNanoShielded()) then player:ActivateNanoShield() end
           if player:isa("Marine") and( player:GetHealth() == player:GetMaxHealth() ) then
           local addarmoramount = 8 
           addarmoramount = who:GetInAttackMode() and addarmoramount * 1.5 or addarmoramount
           player:AddHealth(addarmoramount, false, not true, nil, nil, true)
           else
           player:AddHealth(Armory.kHealAmount, false, false, nil, nil, true)   
           end
         end
return alive

end
local function ShouldStop(who)
local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 8)
if #players >=1 then return false end
return true
end
function AvocaArc:SpecificRules()
local moving = self.mode == ARC.kMode.Moving     
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
local shouldstop = ShouldStop(self)
local shouldmove = not shouldstop and not moving and not inradius
local shouldstop = moving and ShouldStop(self)
local shouldattack = inradius and not attacking 
local shouldundeploy = attacking and not inradius and not moving
  
  if moving then
    
    if shouldstop or shouldattack then 
           FindNewParent(self)
       --Print("StopOrder")
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
      
         GiveUnDeploy(self)
       else 
       MoveToHives(self)
       end
       
   elseif shouldattack then
   
     GiveDeploy(self)
    return true
    
 end
 
    end
end
function AvocaArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

function AvocaArc:ModifyDamageTaken(damageTable, attacker, doer, damageType)
local damagemult = .25 
        if doer then 
          if attacker:isa("Bomb") then
           damagemult = .45
           end
         end
        damageTable.damage = damageTable.damage * damagemult

end

function AvocaArc:GetDamageType()
return kDamageType.StructuresOnly
end

function AvocaArc:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.ARC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
function AvocaArc:Waypoint()
    for _, marine in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 9999)) do
                     if marine:GetIsAlive() and not marine:isa("Commander") then
                     marine:GiveOrder(kTechId.Defend, self:GetId(), self:GetOrigin(), nil, true, true)
                     end
    end
    return true
end
function AvocaArc:Scan()
  if not GetIsPointWithinHiveRadius(self:GetOrigin()) then CreateEntity(Scan.kMapName, self:GetOrigin(), 1) end
    return true
end
function AvocaArc:Instruct()
   CheckHivesForScan()
   self:SpecificRules()
   BuffPlayersNearby(self)
   return true
end


function AvocaArc:PreOnKill(attacker, doer, point, direction)
     if Server then
      local nearestcc = GetNearest(self:GetOrigin(), "CommandStation", 1)
      if nearestcc then
       CreateEntity(AvocaArc.kMapName, FindFreeSpace(nearestcc:GetOrigin()), 1)
       end
     end
end 
function AvocaArc:UpdateMoveOrder(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    ASSERT(currentOrder)
    
    self:SetMode(ARC.kMode.Moving)  
    local slowspeed = ARC.kCombatMoveSpeed
    local normalspeed = ARC.kMoveSpeed * 1.25
    local moveSpeed = ( self:GetIsInCombat() or self:GetGameEffectMask(kGameEffect.OnInfestation) ) and slowspeed or normalspeed
   -- local marines = GetEntitiesWithinRange("Marine", self:GetOrigin(), 4)
    --        if #marines >= 2 then
    --        moveSpeed = moveSpeed * Clamp(#marines/4, 1.1, 4)
    --        end
    local maxSpeedTable = { maxSpeed = moveSpeed }
    self:ModifyMaxSpeed(maxSpeedTable)
    
    self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), maxSpeedTable.maxSpeed, deltaTime)
    
    self:AdjustPitchAndRoll()
    
    if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then
    
        self:CompletedCurrentOrder()
        self:SetPoseParam(kMoveParam, 0)
        
        -- If no more orders, we're done
        if self:GetCurrentOrder() == nil then
            self:SetMode(ARC.kMode.Stationary)
        end
        
    else
        self:SetPoseParam(kMoveParam, .5)
    end
    
end

local function PerformAttack(self)

    if self.targetPosition then
    
        self:TriggerEffects("arc_firing")    
        -- Play big hit sound at origin
        
        -- don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
        
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)

        -- Do damage to every target in range
        RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, 1200, self, true)

        -- Play hit effect on each
        for index, target in ipairs(hitEntities) do
        
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
           
        end
        
    end
    
    -- reset target position and acquire new target
    self.targetPosition = nil
    self.targetedEntity = Entity.invalidId
    
end

--all this just to modify damage -.-

function AvocaArc:OnTag(tagName)

    PROFILE("ARC:OnTag")
    
    if tagName == "fire_start" then
        PerformAttack(self)
    elseif tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(ARC.kMode.Targeting)
    elseif tagName == "deploy_start" then
        self:TriggerEffects("arc_deploying")
    elseif tagName == "undeploy_start" then
        self:TriggerEffects("arc_stop_charge")
    elseif tagName == "deploy_end" then
    
        -- Clear orders when deployed so new ARC attack order will be used
        self.deployMode = ARC.kDeployMode.Deployed
        self:ClearOrders()
        -- notify the target selector that we have moved.
        self.targetSelector:AttackerMoved()
        
        local currentArmor = self:GetArmor()
        if currentArmor ~= 0 then
            self.undeployedArmor = currentArmor
        end

        
    elseif tagName == "undeploy_end" then
    
        self.deployMode = ARC.kDeployMode.Undeployed
        

    end
    
end

end



if Client then

    function AvocaArc:OnUpdateRender()
          local showMaterial = not self:GetInAttackMode()
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client


Shared.LinkClassToMap("AvocaArc", AvocaArc.kMapName, networkVars)