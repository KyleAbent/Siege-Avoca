--Kyle 'Avoca' Abent

class 'Researcher' (Entity) 
Researcher.kMapName = "researcher"


local networkVars = 
{
}
local function TresCheck(cost)
if GetGamerules().team1:GetTeamResources() >= cost then return true end
return false
end
function Researcher:GetIsMapEntity()
return true
end
function Researcher:OnCreate() 

   for i = 1, 4 do
     Print("Researcher created")
   end
   
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
                                if  NotBeingResearched(techId, who) and TresCheck(cost) then 
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
            
end
function Researcher:Calculate()
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
local team1Commander = GetGamerules().team1:GetCommander()

         if gamestarted and not team1Commander then
            for _, researchable in ipairs(GetEntitiesWithMixinForTeam("Research", 1)) do
                 ResearchEachTechButton(researchable) 
             end
         end
         
                       self:UpdateHivesManually()
                       
              return true
              

end

local function GetBioMassLevel()
           local teamInfo = GetTeamInfoEntity(2)
           local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           return math.round(bioMass / 4, 1, 3)
end
local function TresCheck(cost)
    return GetGamerules().team2:GetTeamResources() >= cost

end
local function WorkHere(self, hive)
       if GetHasTech(hive, kTechId.Xenocide) or not GetGamerules():GetGameStarted() or not hive:GetIsBuilt() or hive:GetIsResearching() then return true end
           
           local teamInfo = GetTeamInfoEntity(2)
           local teambioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           
    local techid = nil
    

      if teambioMass >= 2 and not GetHasTech(hive, kTechId.Charge) then
    techid = kTechId.Charge
      elseif teambioMass >= 3 and not GetHasTech(hive, kTechId.BileBomb) then
    techid = kTechId.BileBomb
      elseif teambioMass >= 3 and not GetHasTech(hive, kTechId.MetabolizeEnergy) then
    techid = kTechId.MetabolizeEnergy
      elseif teambioMass >= 4 and not GetHasTech(hive, kTechId.Leap) then
    techid = kTechId.Leap
      elseif teambioMass >= 4 and not GetHasTech(hive, kTechId.Spores) then
    techid = kTechId.Spores
      elseif teambioMass >= 5 and not GetHasTech(hive, kTechId.Umbra) then
    techid = kTechId.Umbra
      elseif teambioMass >= 5 and not GetHasTech(hive, kTechId.MetabolizeHealth) then
    techid = kTechId.MetabolizeHealth
      elseif teambioMass >= 6 and not GetHasTech(hive, kTechId.BoneShield) then 
    techid = kTechId.BoneShield
      elseif teambioMass >= 7 and not GetHasTech(hive, kTechId.Stab) then 
    techid = kTechId.Stab
      elseif teambioMass >= 8 and not GetHasTech(hive, kTechId.Stomp) then 
    techid = kTechId.Stomp
      elseif teambioMass >= 9 and not GetHasTech(hive, kTechId.Xenocide) then 
    techid = kTechId.Xenocide
    end
    
        if techid == nil and hive.bioMassLevel <= 1 then
    techid = kTechId.ResearchBioMassOne
    elseif techid == nil and hive.bioMassLevel == 2 then
    techid = kTechId.ResearchBioMassTwo
    elseif techid == nil and hive.bioMassLevel == 3 then
    techid = kTechId.ResearchBioMassThree
    elseif techid == nil and hive.bioMassLevel == 4 then
    techid = kTechId.ResearchBioMassFour   
    end
    
    if techid == nil then return true end
    local cost = LookupTechData(techid, kTechDataCostKey, 0)
    if TresCheck(cost) then
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
function Researcher:UpdateHivesManually()
local randomhive = nil
          for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             if hive:GetIsBuilt() then 
                  if hive:GetTechId() == kTechId.Hive then UpdateTypeOfHive(hive) end
                   WorkHere(self,hive)
              end
          end
      
      if  TresCheck(40) then
          for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
             if techpoint:GetAttached() == nil then 
               local hive =  techpoint:SpawnCommandStructure(2) 
                  if hive then hive:GetTeam():SetTeamResources(hive:GetTeam():GetTeamResources() - 40) break end
             end
          end
     end
end

Shared.LinkClassToMap("Researcher", Researcher.kMapName, networkVars)