Script.Load("lua/ClassMods/AntiExploit.lua")




local orig_Commander_Logout = Commander.Logout

function CommandStructure:Logout()




   if self:isa("Alien") then
        self:AddTimedCallback(function() UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), self:GetTierFourTechId()) end, .8) 
   end

 return orig_CommandStructure_Logout(self)
end