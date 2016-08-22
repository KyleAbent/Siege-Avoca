
SetCachedTechData(kTechId.Sentry, kStructureBuildNearClass, false)
SetCachedTechData(kTechId.Sentry, kStructureAttachRange, 999)
SetCachedTechData(kTechId.Sentry, kTechDataSpecifyOrientation, false)
SetCachedTechData(kTechId.SentryBattery, kTechDataHint, "Powers structures without power!")
SetCachedTechData(kTechId.SentryBattery,kTechDataDisplayName, "Backup Battery")

Script.Load("lua/Additions/LevelsMixin.lua")

class 'SentryAvoca' (Sentry)
SentryAvoca.kMapName = "sentryavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)

    
local origsentry  = Sentry.OnInitialized
function Sentry:OnInitialized()
  origsentry(self)
    if Server and not self:isa("SentryAvoca") then
    self:AddTimedCallback( function ()
       local sentry = CreateEntity(SentryAvoca.kMapName, self:GetOrigin(), 1) 
      sentry:SetParent(self:GetParent())
      if self:GetIsBuilt() then sentry:SetConstructionComplete() end
        DestroyEntity(self) end , .5)
    end

end

    function SentryAvoca:OnInitialized()
         Sentry.OnInitialized(self)
        InitMixin(self, LevelsMixin)
          self:AdjustMaxHealth(self:GetMaxHealth())
         self:AdjustMaxArmor(self:GetMaxArmor())
    end
    function SentryAvoca:GetMaxHealth()
    return kSentryHealth
end
function SentryAvoca:GetMaxArmor()
    return kSentryArmor 
end
function SentryAvoca:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sentry:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("attack", self.attacking)
    modelMixin:SetAnimationInput("powered", true)
    
end
if Server then

 function SentryAvoca:OnUpdate(deltaTime)
        Sentry.OnUpdate(self, deltaTime)  
        self.attachedToBattery = true
end

end
    function SentryAvoca:GetMaxLevel()
    return 25
    end
    function SentryAvoca:GetAddXPAmount()
    return 0.25
    end
function SentryAvoca:GetFov()
    return 360
end

function SentryAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Sentry
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("SentryAvoca", SentryAvoca.kMapName, networkVars)

function GetCheckSentryLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName  then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kCommSentryPerRoom
    
end

function GetBatteryInRange(commander)

    local batteries = {}
    for _, battery in ipairs(GetEntitiesForTeam("CommandStation", commander:GetTeamNumber())) do
        batteries[battery] = 999
    end
    
    return batteries
    
end
function PowerConsumerMixin:GetHasSentryBatteryInRadius()
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or self:GetHasSentryBatteryInRadius()
end