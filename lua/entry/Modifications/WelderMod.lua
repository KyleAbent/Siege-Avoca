local origweld = Welder.PerformWeld
function Welder:PerformWeld(player)
origweld(self, player)
    local attackDirection = player:GetViewCoords().zAxis
    // prioritize friendlies
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(self, player, 0, self:GetRange(), nil, true, 1, PrioritizeDamagedFriends, nil, PhysicsMask.Flame)
    
    if didHit and target and HasMixin(target, "Live") then
           
        if player:GetTeamNumber() == target:GetTeamNumber() and HasMixin(target, "Weldable") and  HasMixin(target, "Levels") and target.GetMaxLevel ~= target:GetMaxLevel() then
                 local prevlevel = target.level
                target:AddXP(target:GetAddXPAmount())
                local success = false
                success = prevlevel ~= target.level
                   if success then
                   local addAmount = (target.level - prevlevel)
                   local kAmountLeveledForPoints = 10
                   local kLevelScoreAdded = 1
                   player:AddContinuousScore("WeldHealth", addAmount, kAmountLeveledForPoints, kLevelScoreAdded)
                   end     
       end
    end
        return origweld(self, player)
    
end