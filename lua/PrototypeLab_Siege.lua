Script.Load("lua/Additions/LevelsMixin.lua")

class 'PrototypeLabAvoca' (PrototypeLab)--may not nee dto do ongetmapblipinfo because the way i redone the setcachedtechdata to simply change the mapname to this :)
PrototypeLabAvoca.kMapName = "prototypelabavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function PrototypeLabAvoca:OnInitialized()
         InitMixin(self, LevelsMixin)
         PrototypeLab.OnInitialized(self)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.PrototypeLab)
    end
        function PrototypeLabAvoca:GetTechId()
         return kTechId.PrototypeLab
    end
        function PrototypeLabAvoca:GetMaxLevel()
    return 25
    end
    function PrototypeLabAvoca:GetAddXPAmount()
    return 0.25
    end
    
function PrototypeLab:GetMinRangeAC()
return ProtoAutoCCMR      
end
function PrototypeLabAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.PrototypeLab
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
Shared.LinkClassToMap("PrototypeLabAvoca", PrototypeLabAvoca.kMapName, networkVars)