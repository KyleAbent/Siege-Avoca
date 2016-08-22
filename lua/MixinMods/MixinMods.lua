function InfestationMixin:OnKill()
    
    // trigger receed
    self:SetDesiredInfestationRadius(0)
    
      for _, structure in ipairs(GetEntitiesWithMixinForTeamWithinRange("InfestationTracker", 1, self:GetOrigin(), 8)) do
      structure:InfestationNeedsUpdate()
      end
     
end
