


local orig_CommandStation_OnKill = CommandStation.OnKill
function CommandStation:OnKill(attacker, doer, point, direction)
        for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), 8)) do
              if techpoint.attachedId == self:GetId() then techpoint.attachedId =   Entity.invalidId end
       end
       
 return orig_CommandStation_OnKill(self,attacker, doer, point, direction)
end
local orig_CommandStation_OnInitialized = CommandStation.OnInitialized
function CommandStation:OnInitialized()
  orig_CommandStation_OnInitialized(self)
        for _, techpoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), 8)) do
              if techpoint:GetAttached() == nil and techpoint.attachedId ~= self:GetId() then techpoint.attachedId =   self:GetId() end
       end
       

end