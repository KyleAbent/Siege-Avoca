Script.Load("lua/Additions/AvocaMixin.lua")
class 'ShadeAvoca' (Shade)--may not nee dto do ongetmapblipinfo because the way i redone the setcachedtechdata to simply change the mapname to this :)
ShadeAvoca.kMapName = "shadeavoca"

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function ShadeAvoca:OnInitialized()
         Shade.OnInitialized(self)
        InitMixin(self, AvocaMixin)
    end
        function ShadeAvoca:GetTechId()
         return kTechId.Shade
    end

function ShadeAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shade
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("ShadeAvoca", ShadeAvoca.kMapName, networkVars)