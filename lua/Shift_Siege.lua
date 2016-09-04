Script.Load("lua/Additions/AvocaMixin.lua")
class 'ShiftAvoca' (Shift)
ShiftAvoca.kMapName = "shiftavoca"

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function ShiftAvoca:OnInitialized()
         Shift.OnInitialized(self)
        InitMixin(self, AvocaMixin)
    end
        function ShiftAvoca:GetTechId()
         return kTechId.Shift
    end

function ShiftAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shift
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("ShiftAvoca", ShiftAvoca.kMapName, networkVars)


