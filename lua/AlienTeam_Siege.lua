

local function OnlyPregame(self, techPoint)
     local gamestarted = false
   if GetGamerules():GetGameState() == kGameState.Started  or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if not gamestarted then 
  local bigmac  = CreateEntity(BigDrifter.kMapName, FindFreeSpace(techPoint:GetOrigin()), 2)
  
  return false
  end
end

local orig_AlienTeam_SpawnInitialStructures = AlienTeam.SpawnInitialStructures
function AlienTeam:SpawnInitialStructures(techPoint)
orig_AlienTeam_SpawnInitialStructures(self, techPoint)
     OnlyPregame(self, techPoint)
end


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
    self.techTree:AddBuildNode(kTechId.CommVortex,                     kTechId.ShadeHive,          kTechId.None)
    
    
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end
