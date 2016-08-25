Script.Load("lua/Modifications/FrontDoorOpenConvars.lua")
Script.Load("lua/Modifications/PreGameConvars.lua")
Script.Load("lua/Modifications/RoundStartConvars.lua")
Script.Load("lua/Modifications/CustomLightRules.lua")
Script.Load("lua/Modifications/WelderMod.lua")

function LeapMixin:GetHasSecondary(player)
    return GetHasTech(player, kTechId.Leap)
end