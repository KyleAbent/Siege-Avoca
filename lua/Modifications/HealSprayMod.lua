local function PerformHealSpray(self, player)

    for _, entity in ipairs(GetEntitiesInCone(self, player)) do
    
        if HasMixin(entity, "Team") then
        
            if entity:GetTeamNumber() == player:GetTeamNumber() then
                HealEntity(self, player, entity)
                  --so gorge healspray levels up structures based on their.... settings.
                    if HasMixin(entity, "Levels") and entity:GetIsBui8lt() then 
                          local target = entity
                          local prevlevel = target.level
                          target:AddXP(entity:GetAddXPAmount())
                          local success = false
                          success = prevlevel ~= target.level
                          if success then
                          local addAmount = (target.level - prevlevel)
                          local kAmountLeveledForPoints = 20
                           local kLevelScoreAdded = 1
                           player:AddContinuousScore("Healspray", addAmount, kAmountLeveledForPoints, kLevelScoreAdded)
                           end
                     end
            elseif GetAreEnemies(entity, player) then
                DamageEntity(self, player, entity)
            end
            
        end
        
    end
    
end

function HealSprayMixin:OnTag(tagName)

    PROFILE("HealSprayMixin:OnTag")

    if self.secondaryAttacking and tagName == "heal" then
        
        local player = self:GetParent()
        if player and player:GetEnergy() >= self:GetSecondaryEnergyCost(player) then
        
            PerformHealSpray(self, player)            
            player:DeductAbilityEnergy(self:GetSecondaryEnergyCost(player))
            
            local effectCoords = Coords.GetLookIn(GetHealOrigin(self, player), player:GetViewCoords().zAxis)
            player:TriggerEffects("heal_spray", { effecthostcoords = effectCoords })
            
            self.lastSecondaryAttackTime = Shared.GetTime()
        
        end
    
    end
    
end