
local orig_AlienTeam_InitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_AlienTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
 
self.techTree:AddBuildNode(kTechId.EggBeacon, kTechId.CragHive)
self.techTree:AddBuildNode(kTechId.StructureBeacon, kTechId.ShiftHive)
self.techTree:AddResearchNode(kTechId.PrimalScream,              kTechId.Spores, kTechId.None, kTechId.AllAliens) -- though linking
self.techTree:AddResearchNode(kTechId.FadeWall,              kTechId.Stab, kTechId.None, kTechId.AllAliens) -- though linking
self.techTree:AddResearchNode(kTechId.OnoLow,              kTechId.Stomp, kTechId.None, kTechId.AllAliens) -- though linking
self.techTree:AddResearchNode(kTechId.OnoGrow,              kTechId.Stomp, kTechId.None, kTechId.AllAliens) -- though linking
    
    
    
    self.techTree:AddBuildNode(kTechId.GorgeCrag,                      kTechId.CragHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.GorgeShift,                     kTechId.ShiftHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.GorgeShade,                     kTechId.ShadeHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.GorgeWhip,                     kTechId.None,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.CommTunnel,                     kTechId.None,          kTechId.None)
    
    
    
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end
