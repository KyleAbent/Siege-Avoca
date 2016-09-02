Script.Load("lua/Additions/AvocaMixin.lua")
class 'InfantryPortalAvoca' (InfantryPortal)
InfantryPortalAvoca.kMapName = "infantryportalavoca"

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function InfantryPortalAvoca:OnInitialized()
         InfantryPortal.OnInitialized(self)
        InitMixin(self, AvocaMixin)
    end
        function InfantryPortalAvoca:GetTechId()
         return kTechId.InfantryPortal
    end

function InfantryPortalAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.InfantryPortal
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("InfantryPortalAvoca", InfantryPortalAvoca.kMapName, networkVars)