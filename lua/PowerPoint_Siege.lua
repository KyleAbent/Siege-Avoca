function PowerPoint:CanBeCompletedByScriptActor(player)
  return true
end

 function PowerPoint:SpawnSurgeForEach()
        if GetGamerules():GetGameState() == kGameState.Countdown then return end
           local canspawn = GetIsMarineImaginatorActive()
           if not canspawn then return false end
           local where = self:GetOrigin()
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation:GetName() or ""
           if not wherelocation then return end
           
     for _, eligable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, where, 72)) do
         if not eligable:isa("Player") and not eligable:isa("Commander") and not eligable:isa("Cyst") then --and not GetIsPointInMarineBase(eligable:GetOrigin()) then
           local location = GetLocationForPoint(eligable:GetOrigin())
           local locationName = location and location:GetName() or ""
           local sameLocation = locationName == wherelocation
          if sameLocation then 
                eligable:DeductHealth(420, nil, nil, true, false, true)
                eligable:TriggerEffects("arc_hit_primary")
          end --
         end
     end--
     return not self:GetIsDisabled() and canspawn
end





--modifications.lua - powersourcemixin mod