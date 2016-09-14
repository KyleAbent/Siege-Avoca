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

function Researcher:SetResearchification(boolean, team)

  if team == 1 then
  self.marineenabled = boolean
  end


end
function Researcher:UpdateHivesManually()
        local team2Commander = GetGamerules().team2:GetCommander()
      if not team2Commander then 
       local  hivecount = #GetEntitiesForTeam( "Hive", 2 )
      if  hivecount < 3 and TresCheck(2,40) then
          for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
             if techpoint:GetAttached() == nil then 
               local hive =  techpoint:SpawnCommandStructure(2) 
                  if hive then hive:GetTeam():SetTeamResources(hive:GetTeam():GetTeamResources() - 40) break end
             end
          end
     end

     end
     
end

Shared.LinkClassToMap("Researcher", Researcher.kMapName, networkVars)