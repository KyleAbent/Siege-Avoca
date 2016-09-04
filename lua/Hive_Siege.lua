if Server then











function Hive:CheckForDoubleUpG()  --CONSTANT issue of Double hives. Meaning no upgs. Ruining games after time spent seeding server.
 
--Print("Hive:CheckForDoubleUpG()")

for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do 
        --  Print("FoundHive")
        if hive ~= self and self:GetTechId() ~= kTechId.Hive and hive:GetTechId() == self:GetTechId() then
         self:SetTechId(kTechId.Hive)
       --  Print("Found DBL UPG hive and set tech id to hive")
         break
        end
end

end



local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
UpdateAliensWeaponsManually()

    if researchId == kTechId.UpgradeToCragHive or researchId == kTechId.UpgradeToShadeHive or researchId ==  kTechId.UpgradeToShiftHive then
        self:AddTimedCallback(Hive.CheckForDoubleUpG, 4) 
      --  Print("Started Callback Hive CheckForDoubleUpG")
     end   

  return orig_Hive_OnResearchComplete(self, researchId) 
end

end
local function NotBeingResearchedHive(techId)   
    if techId == kTechId.ResearchBioMassOne or techId == kTechId.ResearchBioMassTwo then return true end
for _, structure in ientitylist(Shared.GetEntitiesWithClassname("Hive" )) do
         if structure:GetIsResearching() and structure:GetResearchingId() == techId then return false end
     end
    return true
end
function Hive:HiveResearch()
if not self or GetGameInfoEntity():GetWarmUpActive() then return false end
if self:GetIsResearching() then return true end
local tree = self:GetTeam():GetTechTree()
local technodes = {}
--Print("HiveResearch 1")
    for _, node in pairs(tree.nodeList) do
   --  Print("HiveResearch 2")
           local canRes = tree:GetHasTech(node:GetPrereq1()) and tree:GetHasTech(node:GetPrereq2())
          local techId = node:GetTechId()
         if canRes and NotBeingResearchedHive(techId) and node:GetIsResearch() and node:GetCanResearch() then --and  not NotBeingResearchedHive(techId) then
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
                                --     Print("HiveResearch 7")
                                  self:SetResearching(technode, self)
                                  break
                  end --
                  
                  return true

end

local orig_Hive_OnConstructionComplete = Hive.OnConstructionComplete
function Hive:OnConstructionComplete()

self:AddTimedCallback(Hive.HiveResearch, 4)

end
function Hive:GetTechButtons()

return {}

end




