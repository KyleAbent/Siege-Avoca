local function OnlyPregame(self, techPoint)
     local gamestarted = false
   if GetGamerules():GetGameState() == kGameState.Started  or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if not gamestarted then 
 local avocaarc = CreateEntity(AvocaArc.kMapName, FindFreeSpace(techPoint:GetOrigin()), 1)
  local phaseavo  = CreateEntity(PhaseAvoca.kMapName, FindFreeSpace(techPoint:GetOrigin()), 1)
  local bigmac  = CreateEntity(BigMac.kMapName, FindFreeSpace(techPoint:GetOrigin()), 1)
  phaseavo:LameFixATM()
  avocaarc:LameFixATM()
  bigmac:LameFixATM()
  
  return false
  end
end

local orig_MarineTeam_InitTechTree = MarineTeam.InitTechTree


local orig_MarineTeam_SpawnInitialStructures = MarineTeam.SpawnInitialStructures
function MarineTeam:SpawnInitialStructures(techPoint)
orig_MarineTeam_SpawnInitialStructures(self, techPoint)
     OnlyPregame(self, techPoint)
end

function MarineTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_MarineTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
    
    
    
    
    
    
    

    self.techTree:AddActivation(kTechId.AdvancedBeacon,           kTechId.Observatory)  
    self.techTree:AddActivation(kTechId.MacSpawnOn,                kTechId.RoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.MacSpawnOff,                kTechId.RoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.ArcSpawnOn,                kTechId.ARCRoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.ArcSpawnOff, kTechId.ARCRoboticsFactory, kTechId.None)
    
    
    
    
    
    
    
    
    
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end