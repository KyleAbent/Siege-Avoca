--Kyle 'Avoca' Abent
--Overwrite now because lazy
class 'RoboMod' (RoboticsFactory)
RoboMod.kMapName = "robomod"


Script.Load("lua/Additions/LevelsMixin.lua")


local networkVars =
{
    automaticspawningmac = "boolean",
}


AddMixinNetworkVars(LevelsMixin, networkVars)


function RoboMod:OnInitialized()
 InitMixin(self, LevelsMixin)
 RoboticsFactory.OnInitialized(self)
 self.automaticspawningmac = false
self.automaticspawningarc = false
end
    function RoboMod:GetMaxLevel()
    return 25
    end
    function RoboMod:GetAddXPAmount()
    return 0.25
    end
local originit = RoboticsFactory.OnInitialized
function RoboticsFactory:OnInitialized()
  originit(self)
    if Server and not self:isa("RoboMod") and not self:isa("ARCRoboticsFactory") then
    self:AddTimedCallback( function ()
      local robomod = CreateEntity(RoboMod.kMapName, self:GetOrigin(), 1) DestroyEntity(self) 
      robomod:SetParent(self:GetParent())
      if self:GetIsBuilt() then robomod:SetConstructionComplete() end 
      end , .5)
    end
end
local function GetMacsAmount()
    local macs = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                macs = macs + 1
         end
    return  macs
end
function RoboMod:GetTechButtons(techId)

    local techButtons = {  kTechId.ARC, kTechId.MAC, kTechId.None, kTechId.None, 
               kTechId.UpgradeRoboticsFactory, kTechId.None, kTechId.None, kTechId.None }

   if not self.automaticspawningmac and not self.automaticspawningarc then 
      techButtons[6] = kTechId.MacSpawnOn
   elseif self.automaticspawningmac then
      techButtons[6] = kTechId.MacSpawnOff
    end
   
    
    return techButtons
    
end
function RoboMod:GetTechId()

    return kTechId.RoboticsFactory
    
end
function RoboMod:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.RoboticsFactory
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
  function RoboMod:OnUpdate()
   if self.timeOfLastHealCheck == nil or Shared.GetTime() > self.timeOfLastHealCheck + 10 then
   if self.automaticspawningmac then
        if self:GetTeam():GetTeamResources() >= kMACCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.MAC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetMacsAmount() <= 8 then
        
            self:OverrideCreateManufactureEntity(kTechId.MAC)
            //self.spawnedFreeMAC = true
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kMACCost )
        end
    end
    self.timeOfLastHealCheck = Shared.GetTime()  
    end
end
end

Shared.LinkClassToMap("RoboMod", RoboMod.kMapName, networkVars)

class 'RoboModArc' (ARCRoboticsFactory)

local originit = ARCRoboticsFactory.OnInitialized
function ARCRoboticsFactory:OnInitialized()
  originit(self)
    if Server and not self:isa("RoboModArc")   then
    self:AddTimedCallback( function ()
      local robomod = CreateEntity(RoboModArc.kMapName, self:GetOrigin(), 1) DestroyEntity(self) 
      robomod:SetParent(self:GetParent())
      if self:GetIsBuilt() then robomod:SetConstructionComplete() end 
      end , .5)
    end
end


Script.Load("lua/Additions/LevelsMixin.lua")


local networkVars =
{
    automaticspawningmac = "boolean",
    automaticspawningarc = "boolean",
}


AddMixinNetworkVars(LevelsMixin, networkVars)


function RoboModArc:OnInitialized()
 InitMixin(self, LevelsMixin)
 RoboticsFactory.OnInitialized(self)
 self.automaticspawningmac = false
self.automaticspawningarc = false
end
    function RoboModArc:GetMaxLevel()
    return 25
    end
    function RoboModArc:GetAddXPAmount()
    return 0.25
    end
local function GetMacsAmount()
    local macs = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                macs = macs + 1
         end
    return  macs
end
local function GetArcsAmount()
    local arcs = 0
        for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
              if not arc.ignorelimit then arcs = arcs + 1 end
         end
    return  arcs
end
function RoboModArc:GetTechButtons(techId)

    local techButtons = {  kTechId.None, kTechId.MAC, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    
       if GetArcsAmount() <=12 then
       techButtons[1] = kTechId.ARC
       end
                

   if not self.automaticspawningmac and not self.automaticspawningarc then 
      techButtons[6] = kTechId.MacSpawnOn
   elseif self.automaticspawningmac then
      techButtons[6] = kTechId.MacSpawnOff
    end
   
    
       if not self.automaticspawningmac and not self.automaticspawningarc then 
      techButtons[7] = kTechId.ArcSpawnOn
   elseif self.automaticspawningarc then
      techButtons[7] = kTechId.ArcSpawnOff
    end
    
    return techButtons
    
end
function RoboModArc:GetTechId()

    return kTechId.ARCRoboticsFactory
    
end
function RoboModArc:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.RoboticsFactory
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
  function RoboModArc:OnUpdate()
   if self.timeOfLastHealCheck == nil or Shared.GetTime() > self.timeOfLastHealCheck + 10 then
   if self.automaticspawningmac then
        if self:GetTeam():GetTeamResources() >= kMACCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.MAC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetMacsAmount() <= 8 then
        
            self:OverrideCreateManufactureEntity(kTechId.MAC)
            //self.spawnedFreeMAC = true
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kMACCost )
        end
    end
    if self.automaticspawningarc then
        if self:GetTeam():GetTeamResources() >= kARCCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.ARC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetArcsAmount() <= 12 - 1 then
        
            self:OverrideCreateManufactureEntity(kTechId.ARC)
            //self.spawnedFreeMAC = true
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kARCCost )
        end
    end
    self.timeOfLastHealCheck = Shared.GetTime()  
    end
end
end

Shared.LinkClassToMap("RoboModArc", RoboModArc.kMapName, networkVars)