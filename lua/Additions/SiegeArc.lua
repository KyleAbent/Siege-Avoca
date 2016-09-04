--Kyle 'Avoca' Abent
class 'SiegeArc' (ARC)
SiegeArc.kMapName = "siegearc"
local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")
local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

function SiegeArc:OnCreate()
 ARC.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
  if Server then  self:LameFixATM() end
end
function SiegeArc:OnInitialized()
 ARC.OnInitialized(self)
   if Server then
 self:AddTimedCallback(SiegeArc.Instruct, 2.5)
 --self:AddTimedCallback(SiegeArc.Waypoint, 16)
 end

end

function SiegeArc:GetMaxHealth()
    return 4000
end
function SiegeArc:GetMaxArmor()
    return 1200
end
local function SoTheGameCanEnd(self, who) --Although HiveDefense prolongs it
   local arc = GetEntitiesWithinRange("ARC", who:GetOrigin(), ARC.kFireRange + 12)
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
function SiegeArc:GetCanFireAtTargetActual(target, targetPoint)    

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    
    // don't target eggs (they take only splash damage)
    if target:isa("Egg") or target:isa("Cyst") then
        return false
    end
    if not target:GetIsSighted() and not GetIsTargetDetected(target) then
        return false
    end

    return true
    
end
function SiegeArc:LameFixATM()
self:AddTimedCallback(SiegeArc.Check, 8)
end
function SiegeArc:Check()
  local gamestarted = false 
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if gamestarted then 
         local team1Commander = GetGamerules().team1:GetCommander()
     if team1Commander or not GetSandCastle():GetIsSiegeOpen() then DestroyEntity(self) end
    end
   return true
end

local function GetSiegeLocation()
--local locations = {}

local hive = nil

 for _, hivey in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
    hive = hivey
 end
 local siegeloc = nil
 if hive ~= nil then
  siegeloc = GetNearest(hive:GetOrigin(), "Location", nil, function(ent) return string.find(ent.name, "siege") or string.find(ent.name, "Siege") end)
 end
 
if siegeloc then return siegeloc end
 return nil
end
local function MoveToHives(self) --Closest hive from origin
--Print("Siegearc MoveToHives")
local siegelocation = GetSiegeLocation()
if not siegelocation then return true end
local siegepower = GetPowerPointForLocation(siegelocation.name)
local hiveclosest = GetNearest(siegepower:GetOrigin(), "Hive", 2)
local origin = 0

--if hiveclosest then
--origin = siegepower:GetOrigin()
--origin = origin + hiveclosest:GetOrigin()
--origin = origin + siegelocation:GetOrigin()
--origin = origin / 3
--end
if origin == 0 then origin = FindArcHiveSpawn(siegepower:GetOrigin())  end
local where = origin
               if where then
        self:GiveOrder(kTechId.Move, nil, where, nil, true, true)
                    return
                end  
   return not self.mode == ARC.kMode.Moving  and not GetIsInSiege(self)  
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
local function PlayersNearby(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 5.5)
local alive = true--false
    if not who:GetInAttackMode() and #players >= 1 then
         for i = 1, #players do
            local player = players[i]
            if player:GetIsAlive() and alive == false then alive = true end
            if ( player:GetIsAlive() and  player.GetIsNanoShielded and not player:GetIsNanoShielded()) then player:ActivateNanoShield() end
           if player:isa("Marine") and( player:GetHealth() == player:GetMaxHealth() ) then
           local addarmoramount = kArmoryAvoArcAddArmrAmt * player:GetArmorLevel()
           addarmoramount = who:GetInAttackMode() and addarmoramount * 1.5 or addarmoramount
           player:AddHealth(addarmoramount, false, not true, nil, nil, true)
           else
           player:AddHealth(Armory.kHealAmount, false, false, nil, nil, true)   
           end
         end
    end
return alive
end
local function ShouldStop(who)
local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 8)
if #players >=1 then return false end
return true
end
function SiegeArc:SpecificRules()
--Print("Siegearc SpecificRules")
local moving = self.mode == ARC.kMode.Moving     
--Print("moving is %s", moving) 
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
--Print("attacking is %s", moving) 
local inradius = GetIsInSiege(self) and GetIsPointWithinHiveRadius(self:GetOrigin()) 
--Print("inradius is %s", inradius) 

local shouldstop = not PlayersNearby(self)
--Print("shouldstop is %s", shouldstop) 
local shouldmove = not moving and not inradius
--Print("shouldmove is %s", shouldmove) 
local shouldstop = moving and inradius
--Print("shouldstop is %s", shouldstop) 
local shouldattack = inradius and not attacking 
--Print("shouldattack is %s", shouldattack) 
local shouldundeploy = attacking and not inradius and not moving
--Print("shouldundeploy is %s", shouldundeploy) 
  
  if moving then
    
    if shouldstop or shouldattack then 
       --Print("StopOrder")
       FindNewParent(self)
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
         --Print("ShouldUndeploy")
         GiveUnDeploy(self)
       else --should move
       --Print("GiveMove")
       MoveToHives(self)
       end
       
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
    
 end
 
    end
end
function SiegeArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

function SiegeArc:GetDamageType()
return kDamageType.StructuresOnly
end

function SiegeArc:OnGetMapBlipInfo()
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
function SiegeArc:Waypoint()
    for _, marine in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 9999)) do
                     if marine:GetClient():GetIsVirtual() and marine:GetIsAlive() and not marine:isa("Commander") then
                     marine:GiveOrder(kTechId.Defend, self:GetId(), self:GetOrigin(), nil, true, true)
                     end
    end
    return true
end
function SiegeArc:Instruct()
   CheckHivesForScan()
   self:SpecificRules()
   return true
end


function SiegeArc:PreOnKill(attacker, doer, point, direction)
     if Server then
      local nearestcc = GetNearest(self:GetOrigin(), "CommandStation", 1)
      if nearestcc then
       CreateEntity(SiegeArc.kMapName, FindFreeSpace(nearestcc:GetOrigin()), 1)
       end
     end
end 
function SiegeArc:UpdateMoveOrder(deltaTime)

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
        
        local hitEntities = GetEntitiesInHiveRoom(self) -- GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)

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

function SiegeArc:OnTag(tagName)

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

    function SiegeArc:OnUpdateRender()
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


Shared.LinkClassToMap("SiegeArc", SiegeArc.kMapName, networkVars)