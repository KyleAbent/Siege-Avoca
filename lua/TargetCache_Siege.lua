--Derp overwrite


function StaticTargetCache:AddPossibleTargets(selector, result)
    PROFILE("StaticTargetCache:AddPossibleTargets")
    
    self:ValidateCache(selector)

    local count = 0
    for targetId, range in pairs(self.targetIdToRangeMap) do
        PROFILE("StaticTargetCache:AddPossibleTargets/loop")
        local target = Shared.GetEntity(targetId)
        
            if target and ( target.GetIsAlive and target:GetIsAlive() )  and ( target.GetCanTakeDamage and target:GetCanTakeDamage() ) then 
                PROFILE("StaticTargetCache:AddPossibleTargets/_ApplyFilters")
                if selector:_ApplyFilters(target, target:GetEngagementPoint()) then
                    table.insert(result,target)
                    --Log("%s: static target %s at range %s", selector.attacker, target, range)
                end
            end
    end

end