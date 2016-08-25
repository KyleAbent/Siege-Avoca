--Kyle 'Avoca' Abent

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Blink.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

local kStructureHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_structure.cinematic")
local kMarineHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_marine.cinematic")

local kCinematic = PrecacheAsset("cinematics/alien/lerk/primal2.cinematic")
local kSound = PrecacheAsset("sound/NS2.fev/alien/lerk/taunt")

class 'FadeWall' (Blink)

FadeWall.kMapName = "fadewall"

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")


local networkVars =
{
    lastPrimaryAttackTime = "private time"
}


local function TriggerWall(self, fade)

     if Server then CreateEntity(BoneWall.kMapName, FindFreeSpace(fade:GetOrigin() - Vector(0, 1, 0), .5, 4) , 2) end 
      

    
end

function FadeWall:OnCreate()

    Blink.OnCreate(self)

	
    self.primaryAttacking = false
    self.lastPrimaryAttackTime = 0

end

function FadeWall:GetAnimationGraphName()
    return kAnimationGraph
end

function FadeWall:GetEnergyCost(player)
    return kPrimalScreamEnergyCost
end

function FadeWall:GetHUDSlot()
    return 4
end

function FadeWall:GetAttackDelay()
    return kPrimalScreamROF
end

function FadeWall:GetLastAttackTime()
    return self.lastPrimaryAttackTime
end

function FadeWall:GetDeathIconIndex()

    if self.secondaryAttacking then
        return kDeathMessageIcon.Spikes
    else
        return kDeathMessageIcon.Umbra
    end
    
end
function FadeWall:GetCanWall(player)
local bonewall = #GetEntitiesWithinRange("BoneWall", player:GetOrigin(), 2)
if bonewall >= 1 then return false end
return Shared.GetTime() > self:GetLastAttackTime() + kPrimalScreamROF
end
function FadeWall:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() and self:GetCanWall(player) then
        self:TriggerEffects("primal_scream")
        if Server then        
            TriggerWall(self, player)
        end
        self:GetParent():DeductAbilityEnergy(self:GetEnergyCost())
        self.lastPrimaryAttackTime = Shared.GetTime()
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end
function FadeWall:GetBlinkAllowed()
    return true
end
function FadeWall:GetSecondaryTechId()
    return kTechId.Blink
end
function FadeWall:OnPrimaryAttackEnd()
    
    Ability.OnPrimaryAttackEnd(self)
    self.primaryAttacking = false
    
end

function FadeWall:OnUpdateAnimationInput(modelMixin)

    PROFILE("FadeWall:OnUpdateAnimationInput")    
    
end


Shared.LinkClassToMap("FadeWall", FadeWall.kMapName, networkVars)