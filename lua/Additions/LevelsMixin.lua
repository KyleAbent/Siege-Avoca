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
