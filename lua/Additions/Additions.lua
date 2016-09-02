Script.Load("lua/Additions/AvocaMixin.lua")
Script.Load("lua/Additions/Functions.lua")
Script.Load("lua/Additions/Convars.lua")
Script.Load("lua/Additions/SandCastle.lua")
Script.Load("lua/Additions/Doors.lua")
Script.Load("lua/ClassMods/ClassMods.lua")
Script.Load("lua/Additions/EggBeacon.lua")
Script.Load("lua/Additions/Imaginator.lua")
Script.Load("lua/Additions/Researcher.lua")
Script.Load("lua/Additions/AvocaArc.lua")
Script.Load("lua/Additions/PhaseAvoca.lua")
Script.Load("lua/Additions/BigMac.lua")
Script.Load("lua/Additions/SiegeArc.lua")
Script.Load("lua/Additions/LayStructures.lua")

local orig_EvolutionChamber_OnResearchComplete = EvolutionChamber.OnResearchComplete
function EvolutionChamber:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
UpdateAliensWeaponsManually()


  return orig_EvolutionChamber_OnResearchComplete(self, researchId) 
end




