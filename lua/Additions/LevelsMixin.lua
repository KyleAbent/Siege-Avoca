--Kyle 'Avoca' Abent
LevelsMixin = CreateMixin(LevelsMixin)
LevelsMixin.type = "Levels"


LevelsMixin.networkVars =
{
    level = "float (0 to " .. 50 .. " by .1)",
}

LevelsMixin.expectedMixins =
{
    Construct = "Derp",
}

LevelsMixin.expectedCallbacks = 
{
    GetMaxLevel = "",
    GetAddXPAmount = "",
}
function LevelsMixin:__initmixin()

self.level = 0
    
end
    function LevelsMixin:GetMaxLevel()
    return 50
    end
    function LevelsMixin:GetAddXPAmount()
    return 0.25
    end

  function LevelsMixin:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s %s"), self:GetLevel(), self:GetClassName())
return unitName
end 

function LevelsMixin:AddXP(amount)
    --Print("add xp triggered")
    local xpReward = 0
        xpReward = math.min(amount, self:GetMaxLevel() - self.level)
        self.level = self.level + xpReward
        --self:AdjustMaxHealth(self:GetMaxHealth() * (self.level/self:GetMaxLevel()) + self:GetMaxHealth()) 
      
    return xpReward
    
end
function LevelsMixin:GetLevel()
        return Round(self.level, 2)
end
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