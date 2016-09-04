function Whip:OnTeleportEnd()
                    self:InfestationNeedsUpdate()
                    self:AddTimedCallback(function()  self:InfestationNeedsUpdate() end, 1)
end
Script.Load("lua/Additions/AvocaMixin.lua")
class 'WhipAvoca' (Whip)
WhipAvoca.kMapName = "whipavoca"

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function WhipAvoca:OnInitialized()
         Whip.OnInitialized(self)
        InitMixin(self, AvocaMixin)
    end
        function WhipAvoca:GetTechId()
         return kTechId.Whip
    end

function WhipAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Whip
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("WhipAvoca", WhipAvoca.kMapName, networkVars)



