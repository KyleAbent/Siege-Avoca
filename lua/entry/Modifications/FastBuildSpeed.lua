local origbuild = ConstructMixin.Construct
local kBuildEffectsInterval = 1
local kDrifterBuildRate = 1
  --Meh
  /**
 * Add health to structure as it builds.
 */
local function AddBuildHealth(self, scalar)
    // Add health according to build time.
    if scalar > 0 then
    
        local maxHealth = self:GetMaxHealth()
        self:AddHealth(scalar * (1 - kStartHealthScalar) * maxHealth, false, false, true)
        
    end
    
end
/**
 * Add health to structure as it builds.
 */
local function AddBuildArmor(self, scalar)
    // Add health according to build time.
    if scalar > 0 then
    
        local maxArmor = self:GetMaxArmor()
        self:SetArmor(self:GetArmor() + scalar * (1 - kStartHealthScalar) * maxArmor, true)
        
    end
    
end
function ConstructMixin:Construct(elapsedTime, builder)

   --Print("kBuildSpeed is %s", kBuildSpeed)


   
    local success = false
    local playAV = false
    
    if not self.constructionComplete and (not HasMixin(self, "Live") or self:GetIsAlive()) then
        
        if builder and builder.OnConstructTarget then
            builder:OnConstructTarget(self)
        end
        
        if Server then
            if not self.lastBuildFractionTechUpdate then
                self.lastBuildFractionTechUpdate = self.buildFraction
            end
            
            local techTree = self:GetTeam():GetTechTree()
            local techNode = techTree:GetTechNode(self:GetTechId())
            local modifier = (self:GetTeamType() == kMarineTeamType and GetIsPointOnInfestation(self:GetOrigin())) and kInfestationBuildModifier or 1
            local gameRules = GetGamerules()
            modifier = modifier * ConditionalValue(not GetFrontDoorOpen() or not GetGameStarted(), kSetupBuildSpeed, modifier)
           -- Print("modifier is %s", modifier)
            local startBuildFraction = self.buildFraction
            local newBuildTime = self.buildTime + elapsedTime * modifier
            local timeToComplete = self:GetTotalConstructionTime()            
            
            if newBuildTime >= timeToComplete then
            
                self:SetConstructionComplete(builder)
                
                if techNode then
                    techNode:SetResearchProgress(1.0)
                    techTree:SetTechNodeChanged(techNode, "researchProgress = 1.0f")
                end    
                
            else
            
                if self.buildTime <= self.timeOfNextBuildWeldEffects and newBuildTime >= self.timeOfNextBuildWeldEffects then
                
                    playAV = true
                    self.timeOfNextBuildWeldEffects = newBuildTime + kBuildEffectsInterval
                    
                end
                
                self.timeLastConstruct = Shared.GetTime()
                self.underConstruction = true
                
                self.buildTime = newBuildTime
                self.oldBuildFraction = self.buildFraction
                self.buildFraction = math.max(math.min((self.buildTime / timeToComplete), 1), 0)
                
                if techNode and (self.buildFraction - self.lastBuildFractionTechUpdate) >= 0.05 then
                
                    techNode:SetResearchProgress(self.buildFraction)
                    techTree:SetTechNodeChanged(techNode, string.format("researchProgress = %.2f", self.buildFraction))
                    self.lastBuildFractionTechUpdate = self.buildFraction
                    
                end
                
                if not self.GetAddConstructHealth or self:GetAddConstructHealth() then
                
                    local scalar = self.buildFraction - startBuildFraction
                    AddBuildHealth(self, scalar)
                    AddBuildArmor(self, scalar)
                
                end
                
                if self.oldBuildFraction ~= self.buildFraction then
                
                    if self.OnConstruct then
                        self:OnConstruct(builder, self.buildFraction, self.oldBuildFraction)
                    end
                    
                end
                
            end
        
        end
        
        success = true
        
    end
    
    if playAV then
        local builderClassName = builder and builder:GetClassName()    
        self:TriggerEffects("construct", {classname = self:GetClassName(), doer = builderClassName, isalien = GetIsAlienUnit(self)})
        
    end 
    
    return success, playAV
    
    
end
