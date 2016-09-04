Script.Load("lua/Additions/AvocaMixin.lua")
class 'PhaseGateAvoca' (PhaseGate)
PhaseGateAvoca.kMapName = "phasegateavoca"

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function PhaseGateAvoca:OnInitialized()
         PhaseGate.OnInitialized(self)
        InitMixin(self, AvocaMixin)
    end
        function PhaseGateAvoca:GetTechId()
         return kTechId.PhaseGate
    end

function PhaseGateAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.PhaseGate
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("PhaseGateAvoca", PhaseGateAvoca.kMapName, networkVars)