if Server then



local orig_Hive_OnKill = Hive.OnKill
function Hive:OnKill(attacker, doer, point, direction)
    orig_Hive_OnKill(self, attacker, doer, point, direction)
UpdateAliensWeaponsManually()
end

function Hive:HiveResearch()
if not self or GetGameInfoEntity():GetWarmUpActive() then return false end
if self:GetIsResearching() then return true end
local tree = self:GetTeam():GetTechTree()
local technodes = {}
    for _, node in pairs(tree.nodeList) do
           local canRes = tree:GetHasTech(node:GetPrereq1()) and tree:GetHasTech(node:GetPrereq2())
         if canRes and node:GetIsResearch() and node:GetCanResearch() then
                node:SetResearched(true)
                tree:SetTechNodeChanged(node, string.format("hasTech = %s", ToString(true)))
         end
    
    end              
                  return false


end



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
local orig_Hive_OnConstructionComplete = Hive.OnConstructionComplete
function Hive:OnConstructionComplete()
self.bioMassLevel = 3
UpdateTypeOfHive(self)
UpdateAliensWeaponsManually()
self:AddTimedCallback(Hive.HiveResearch, 4)
end
/*
function Hive:GetTechButtons()

return {}

end


*/

