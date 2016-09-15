class 'BigDrifter' (Drifter)
BigDrifter.kMapName = "bigdrifter"

local kDrifterConstructSound = PrecacheAsset("sound/NS2.fev/alien/drifter/drift")

function BigDrifter:OnCreate()
 Drifter.OnCreate(self)
 if Server then self:LameFixATM() end
end
function BigDrifter:LameFixATM()
self:AddTimedCallback(BigDrifter.Check, 8)
end
function BigDrifter:Check()
  local gamestarted = false 
    local team2Commander = GetGamerules().team2:GetCommander()
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if gamestarted and team2Commander then DestroyEntity(self) end
   return true
end
local function FindTask(self)

local structure =  GetNearestMixin(self:GetOrigin(), "Construct", 2, function(ent) return not ent:GetIsBuilt() and (not ent.GetCanAutoBuild or ent:GetCanAutoBuild())  and self:CheckTarget(ent:GetOrigin()) and not (GetIsInSiege(ent) and not GetSiegeDoorOpen() )  end)
    
        if structure then      
  
            self:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
            return  
      
        end
    
    

end
local function UpdateTasks(self, deltaTime)

    if not self:GetIsAlive() then
        return
    end
    
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
        local lulz = Drifter.kMoveSpeed * ConditionalValue(not self:GetIsInCombat(), 4, .4)
        local maxSpeedTable = { maxSpeed = lulz }
        self:ModifyMaxSpeed(maxSpeedTable)
        local drifterMoveSpeed = maxSpeedTable.maxSpeed

        local currentOrigin = Vector(self:GetOrigin())
        
        if currentOrder:GetType() == kTechId.Move or currentOrder:GetType() == kTechId.Patrol then
            self:ProcessMoveOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder:GetType() == kTechId.Follow then
            self:ProcessFollowOrder(drifterMoveSpeed, deltaTime)     
        elseif currentOrder:GetType() == kTechId.EnzymeCloud or currentOrder:GetType() == kTechId.Hallucinate or currentOrder:GetType() == kTechId.MucousMembrane or currentOrder:GetType() == kTechId.Storm then
            self:ProcessEnzymeOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder:GetType() == kTechId.Grow then
            self:ProcessGrowOrder(drifterMoveSpeed, deltaTime)
        end
        
        -- Check difference in location to set moveSpeed
        local distanceMoved = (self:GetOrigin() - currentOrigin):GetLength()
        
        self.moveSpeed = (distanceMoved / drifterMoveSpeed) / deltaTime
        
    else
    
        if not self.timeLastTaskCheck or self.timeLastTaskCheck + 2 < Shared.GetTime() then
        
            FindTask(self)
            self.timeLastTaskCheck = Shared.GetTime()
        
        end
    
    end
    
end
local function AoeBuild(self, deltaTime)
    for _, structure in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), 4)) do
    
        if not structure:GetIsBuilt() and (not structure.GetCanAutoBuild or structure:GetCanAutoBuild()) then      
  
            structure:Construct( deltaTime * 4 )
      
        end
    
    end
end
function BigDrifter:GetHoverHeight()    
    return 0.84
end
function BigDrifter:OnUpdate(deltaTime)
  Drifter.OnUpdate(self, deltaTime)
      if Server then
        if not self.timelastAoEBuild or self.timelastAoEBuild + 1 <= Shared.GetTime() then
           AoeBuild(self, deltaTime)
           self.timelastAoEBuild = Shared.GetTime()
       end
      end
end
 function BigDrifter:OnAdjustModelCoords(modelCoords)
         local coords = modelCoords
        coords.xAxis = coords.xAxis * 1.7                          
        coords.yAxis = coords.yAxis * 2                             
        coords.zAxis = coords.zAxis * 1.7
   
    return coords
end
local kDetectInterval = 0.5
local kDetectRange = 1.5
local function ScanForNearbyEnemy(self)

    -- Check for nearby enemy units. Uncloak if we find any.
    self.lastDetectedTime = self.lastDetectedTime or 0
    if self.lastDetectedTime + kDetectInterval < Shared.GetTime() then
    
        if #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kDetectRange) > 0 then
        
            self:TriggerUncloak()
            
        end
        self.lastDetectedTime = Shared.GetTime()
        
    end
    
end
function BigDrifter:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Drifter
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function BigDrifter:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    -- Blend smoothly towards target value
    self.moveSpeedParam = Clamp(Slerp(self.moveSpeedParam, self.moveSpeed, deltaTime), 0, 1)
    --UpdateMoveYaw(self, deltaTime)
    
    if Server then
    
        self.constructing = false
        UpdateTasks(self, deltaTime)
        
        ScanForNearbyEnemy(self)
        
        self.camouflaged = (not self:GetHasOrder() or self:GetCurrentOrder():GetType() == kTechId.HoldPosition ) and not self:GetIsInCombat()
--[[
        self.hasCamouflage = GetHasTech(self, kTechId.ShadeHive) == true
        self.hasCelerity = GetHasTech(self, kTechId.ShiftHive) == true
        self.hasRegeneration = GetHasTech(self, kTechId.CragHive) == true
--]]
        if self.hasRegeneration then
        
            if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then
            
                self:AddHealth(0.06 * self:GetMaxHealth())  
                self.timeLastAlienAutoHeal = Shared.GetTime()
                
            end    
        
        end
        
        self.canUseAbilities = self.timeAbilityUsed + kDrifterAbilityCooldown < Shared.GetTime()
        
    elseif Client then
    
        self.trailCinematic:SetIsVisible(self:GetIsMoving() and self:GetIsVisible())
        
        if self.constructing and not self.playingConstructSound then
        
            Shared.PlaySound(self, kDrifterConstructSound)
            self.playingConstructSound = true
            
        elseif not self.constructing and self.playingConstructSound then
        
            Shared.StopSound(self, kDrifterConstructSound)
            self.playingConstructSound = false
            
        end
        
    end
    
end




Shared.LinkClassToMap("BigDrifter", BigDrifter.kMapName, networkVars)