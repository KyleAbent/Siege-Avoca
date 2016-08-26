--Kyle 'Avoca' Abent
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

Script.Load("lua/Weapons/Alien/StompMixin.lua")

class 'OnoLow' (Ability)

OnoLow.kMapName = "onowlo"

local networkVars =
{
    timeFuelChanged = "private time",
    fuelAtChange = "private float (0 to 1 by 0.01)",
    modelsize = "float (1 to 2 by 0.1)",
    
}
AddMixinNetworkVars(StompMixin, networkVars)

function OnoLow:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, StompMixin)
    
    self.timeFuelChanged = 0
    self.fuelAtChange = 1

end
function OnoLow:SetFuel(fuel)
   self.timeFuelChanged = Shared.GetTime()
   self.fuelAtChange = fuel
end

function OnoLow:GetFuel()
    if self.primaryAttacking then
        return Clamp(self.fuelAtChange - (Shared.GetTime() - self.timeFuelChanged) / kBoneShieldMaxDuration, 0, 1)
    else
        return Clamp(self.fuelAtChange + (Shared.GetTime() - self.timeFuelChanged) / kBoneShieldCooldown, 0, 1)
    end
end

function OnoLow:GetEnergyCost()
    return kBoneShieldInitialEnergyCost
end

function OnoLow:GetAnimationGraphName()
    return kAnimationGraph
end

function OnoLow:GetHUDSlot()
    return 4
end

function OnoLow:GetCooldownFraction()
    return 1 - self:GetFuel()
end
    
function OnoLow:IsOnCooldown()
    return self:GetFuel() < kBoneShieldMinimumFuel
end

function OnoLow:GetCanUseOnoLow(player)
    return not self:IsOnCooldown() and not self.secondaryAttacking and not player.charging
end

function OnoLow:OnPrimaryAttack(player)

    if not self.primaryAttacking then
        if player:GetIsOnGround() and self:GetCanUseOnoLow(player) and self:GetEnergyCost() < player:GetEnergy() then
                
            player:DeductAbilityEnergy(self:GetEnergyCost())
            
            self:SetFuel( self:GetFuel() ) -- set it now, because it will go down from this point
            self.primaryAttacking = true
            
            if Server then
                player:TriggerEffects("onos_shield_start")
            end
        end
    end

end

function OnoLow:OnPrimaryAttackEnd(player)
    
    if self.primaryAttacking then 
    
        self:SetFuel( self:GetFuel() ) -- set it now, because it will go up from this point
        self.primaryAttacking = false
    
    end
    
end

function OnoLow:OnUpdateAnimationInput(modelMixin)

    local activityString = "none"
    local abilityString = "boneshield"
    
    if self.primaryAttacking then
        activityString = "primary" -- TODO: set anim input
    end
    
    modelMixin:SetAnimationInput("ability", abilityString)
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function OnoLow:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self:OnPrimaryAttackEnd(player)
    
end

function OnoLow:OnProcessMove(input)

    if self.primaryAttacking then
        
        if self:GetFuel() > 0 then
            
                self.modelsize = Clamp(self.modelsize + (0.5 * input.time))
        
        else
           self.gravity = Clamp(self.modelsize - (0.5 * input.time))
            self:SetFuel( 0 )
            self.primaryAttacking = false
           
        end
        
    end

end

Shared.LinkClassToMap("OnoLow", OnoLow.kMapName, networkVars)