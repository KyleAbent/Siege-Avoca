--Kyle 'Avoca' Abent

class 'Researcher' (Entity) 
Researcher.kMapName = "researcher"


local networkVars = 
{
 marineenabled = "boolean",
}
local function TresCheck(team, cost)
if team == 1 then
if GetGamerules().team1:GetTeamResources() >= cost then return true end
elseif team == 2 then
if GetGamerules().team2:GetTeamResources() >= cost then return true end
end

return false
end
function Researcher:GetIsMapEntity()
return true
end
function Researcher:OnCreate() 

   for i = 1, 4 do
     Print("Researcher created")
   end
   
   self.marineenabled = false
end
local function NotBeingResearched(techId, who)   
for _, structure in ientitylist(Shared.GetEntitiesWithClassname( string.format("%s", who:GetClassName()) )) do
         if structure:GetIsResearching() and structure:GetClassName() == who:GetClassName( )and structure:GetResearchingId() == techId then return false end
     end
    return true
end
--help from commanderbrain.lua
local function ResearchEachTechButton(who)
local techIds = who:GetTechButtons() or {}
                       for _, techId in ipairs(techIds) do
                     if techId ~= kTechId.None then
                        if who:GetCanResearch(techId) then
                          local tree = GetTechTree(who:GetTeamNumber())
                         local techNode = tree:GetTechNode(techId)
                          assert(techNode ~= nil)
                          
                            if tree:GetTechAvailable(techId) then
                             local cost = 0--LookupTechData(techId, kTechDataCostKey) * 
                                if  NotBeingResearched(techId, who) and TresCheck(1,cost) then 
                                  who:SetResearching(techNode, who)
                                  who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
                                 end
                             end
                         end
                      end
                  end
end

function Researcher:OnRoundStart() 

   for i = 1, 4 do
     Print("Researche Begin")
   end
           if Server then
              self:AddTimedCallback(Researcher.Calculate, 16)
            end
            
                 local team1Commander = GetGamerules().team1:GetCommander()
     self.marineenabled = not team1Commander
end
function Researcher:Calculate()
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
local team1Commander = GetGamerules().team1:GetCommander()

            if not gamestarted  or (self.marineenabled and not team1Commander) then
            for _, researchable in ipairs(GetEntitiesWithMixinForTeam("Research", 1)) do
                 ResearchEachTechButton(researchable) 
             end
         end
         
                if gamestarted then  self:UpdateHivesManually()  end
                       
              return true
              

end

local function GetBioMassLevel()
           local teamInfo = GetTeamInfoEntity(2)
           local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           return math.round(bioMass / 4, 1, 3)
end
local function WorkHere(self, hive)
       if  hive:GetIsResearching() then return true end
           
           local teamInfo = GetTeamInfoEntity(2)
           local teambioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           
    local techid = nil
    
    
        if  hive.bioMassLevel <= 1 then
    techid = kTechId.ResearchBioMassOne
    elseif  hive.bioMassLevel == 2 then
    techid = kTechId.ResearchBioMassTwo
    end
    
    if techid == nil then return true end
    local cost = LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(2,cost) then
    hive:GetTeam():SetTeamResources(hive:GetTeam():GetTeamResources() - cost) 
   local techNode = hive:GetTeam():GetTechTree():GetTechNode( techid ) 
   hive:SetResearching(techNode, self)
   end
   
   
end
local function UpdateTypeOfHive(who)
local hasshade = false
local hasecrag = false
local hasshift = false

             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() and hive:GetIsBuilt() then 
                  if hive:GetTechId() ==  kTechId.CragHive then
                  hasecrag = true
                  elseif hive:GetTechId() ==  kTechId.ShadeHive then
                  hasshade = true
                  elseif hive:GetTechId() ==  kTechId.ShiftHive then
                  hasshift = true
                  end
                end
              end
local techids = {}
if hasecrag == false then table.insert(techids, kTechId.CragHive) end
if hasshade == false then table.insert(techids, kTechId.ShadeHive) end
if hasshift == false then table.insert(techids, kTechId.ShiftHive) end
   
   if #techids == 0 then return end 
    for i = 1, #techids do
      local current = techids[i]
      if who:GetTechId() == techid then
      table.remove(techids, current)
      end
    end
    
    local random = table.random(techids)
    
    who:UpgradeToTechId(random) 
    who:GetTeam():GetTechTree():SetTechChanged()

end
function Researcher:SetResearchification(boolean, team)

  if team == 1 then
  self.marineenabled = boolean
  end


end
local function GetHiveTechButtons(who)
  local techIds = {} 
   table.insert(techIds,who:GetTechButtons())
   return techIds
end
local function NotBeingResearchedHive(techId)   
    if techId == kTechId.ResearchBioMassOne or techId == kTechId.ResearchBioMassTwo then return true end
for _, structure in ientitylist(Shared.GetEntitiesWithClassname("Hive" )) do
         if structure:GetIsResearching() and structure:GetResearchingId() == techId then return false end
     end
    return true
end
local function NotBeingResearched(techId)   
for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive" )) do
     if hive:GetIsBuilt() then
         if hive:GetIsResearching() and hive:GetResearchingId() == techId then return false end
     end
    return true
end
end
local function HiveResearch(who)
if not who or who:GetIsResearching() then return false end
local tree = who:GetTeam():GetTechTree()
local technodes = {}
--Print("HiveResearch 1")
    for _, node in pairs(tree.nodeList) do
   --  Print("HiveResearch 2")
           local canRes = tree:GetHasTech(node:GetPrereq1()) and tree:GetHasTech(node:GetPrereq2())
          local techId = node:GetTechId()
         if canRes and NotBeingResearched(techId) and node:GetIsResearch() and node:GetCanResearch() then --and  not NotBeingResearchedHive(techId) then
       --     Print("HiveResearch 3")
          table.insert(technodes, node)
         end
    
    end


                       for _, technode in ipairs(technodes) do
                      --   Print("HiveResearch 4")
                        local techId = technode:GetTechId()
                              --  Print("HiveResearch 5")
                        --  Print("HiveResearch 4")
                             --    Print("HiveResearch 6")
                             local cost = 0--LookupTechData(techId, kTechDataCostKey) * 
                                if  TresCheck(2,cost) then 
                                --     Print("HiveResearch 7")
                                  who:SetResearching(technode, who)
                                  who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
                                  break
                                 end --
                  end --
                  
                  return false

end

function Researcher:UpdateHivesManually()
local randomhive = nil
local  hivecount = #GetEntitiesForTeam( "Hive", 2 )
          for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             if hive:GetIsBuilt() then 
                  if hive:GetTechId() == kTechId.Hive then UpdateTypeOfHive(hive) end
                   WorkHere(self,hive)
              end
          end
      
      if  hivecount < 3 and TresCheck(2,40) then
          for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
             if techpoint:GetAttached() == nil then 
               local hive =  techpoint:SpawnCommandStructure(2) 
                  if hive then hive:GetTeam():SetTeamResources(hive:GetTeam():GetTeamResources() - 40) break end
             end
          end
     end

     
end

Shared.LinkClassToMap("Researcher", Researcher.kMapName, networkVars)