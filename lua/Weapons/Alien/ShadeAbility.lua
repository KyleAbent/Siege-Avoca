//
// lua\Weapons\Alien\ShadeAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ShadeStructureAbility' (StructureAbility)

function ShadeStructureAbility:GetEnergyCost(player)
    return 0
end

function ShadeStructureAbility:GetPrimaryAttackDelay()
    return 0
end

function ShadeStructureAbility:GetGhostModelName(ability)
    return Shade.kModelName
end

function ShadeStructureAbility:GetDropStructureId()
    return kTechId.GorgeShade
end


function ShadeStructureAbility:GetIsPositionValid(displayOrigin, player, normal, lastClickedPosition, entity)
    return entity == nil
end

function ShadeStructureAbility:GetSuffixName()
    return "gorgeshade"
end

function ShadeStructureAbility:GetDropClassName()
    return "GorgeShade"
end

function ShadeStructureAbility:GetDropMapName()
    return GorgeShade.kMapName
end