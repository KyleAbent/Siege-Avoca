Script.Load("lua/Additions/LevelsMixin.lua")

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
    return 50
    end
    function CommandStationAvoca:GetAddXPAmount()
    return 0.15
    end   
    

Shared.LinkClassToMap("CommandStationAvoca", CommandStationAvoca.kMapName, networkVars)

