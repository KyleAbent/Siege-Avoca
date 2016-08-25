if Server then




function Hive:UpdateAliensWeaponsManually() ///Seriously this makes more sense than spamming some complicated formula every 0.5 seconds no?
 for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        alien:HiveCompleteSoRefreshTechsManually() 
end





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
self:UpdateAliensWeaponsManually()

    if researchId == kTechId.UpgradeToCragHive or researchId == kTechId.UpgradeToShadeHive or researchId ==  kTechId.UpgradeToShiftHive then
        self:AddTimedCallback(Hive.CheckForDoubleUpG, 4) 
      --  Print("Started Callback Hive CheckForDoubleUpG")
     end   

  return orig_Hive_OnResearchComplete(self, researchId) 
end

end






