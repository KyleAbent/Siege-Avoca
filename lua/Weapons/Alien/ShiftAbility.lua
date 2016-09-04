//
// lua\Weapons\Alien\ShiftAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ShiftStructureAbility' (StructureAbility)

function ShiftStructureAbility:GetEnergyCost(player)
    return 0
end

function ShiftStructureAbility:GetPrimaryAttackDelay()
    return 0
end

function ShiftStructureAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function ShiftStructureAbility:GetGhostModelName(ability)
    return Shift.kModelName
end

function ShiftStructureAbility:GetDropStructureId()
    return kTechId.GorgeShift
end

function ShiftStructureAbility:GetIsPositionValid(displayOrigin, player, normal, lastClickedPosition, entity)
    return entity == nil
end

function ShiftStructureAbility:GetSuffixName()
    return "gorgeshift"
end

function ShiftStructureAbility:GetDropClassName()
    return "GorgeShift"
end

function ShiftStructureAbility:GetDropMapName()
    return GorgeShift.kMapName
end