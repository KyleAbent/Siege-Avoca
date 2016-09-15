Script.Load("lua/Additions/LevelsMixin.lua")
function CommandStation:GetMinRangeAC()
return math.random(16,420)      
end


local orig_CommandStation_OnKill = CommandStation.OnKill
function CommandStation:OnKill(attacker, doer, point, direction)
        for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), 8)) do
              if techpoint.attachedId == self:GetId() then techpoint.attachedId =   Entity.invalidId end
       end
       
 return orig_CommandStation_OnKill(self,attacker, doer, point, direction)
end
local orig_CommandStation_OnInitialized = CommandStation.OnInitialized
function CommandStation:OnInitialized()
  orig_CommandStation_OnInitialized(self)
        for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), 8)) do
              if techpoint:GetAttached() == nil and techpoint.attachedId ~= self:GetId() then techpoint.attachedId =   self:GetId() end
       end
       

end


class 'CommandStationAvoca' (CommandStation)
CommandStationAvoca.kMapName = "commandstationavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)



    function CommandStationAvoca:OnInitialized()
         CommandStation.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        self:SetTechId(kTechId.CommandStation)
    end
    
     function CommandStationAvoca:GetMaxLevel()
    return 37
    end
    function CommandStationAvoca:GetAddXPAmount()
    return 0.15
    end   
   function CommandStationAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.CommandStation
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end 

Shared.LinkClassToMap("CommandStationAvoca", CommandStationAvoca.kMapName, networkVars)

