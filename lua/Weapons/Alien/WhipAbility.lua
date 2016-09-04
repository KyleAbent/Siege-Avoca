//
// lua\Weapons\Alien\WhipAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'WhipStructureAbility' (StructureAbility)

function WhipStructureAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end
function WhipStructureAbility:GetGhostModelName(ability)
    return Whip.kModelName
end

function WhipStructureAbility:GetDropStructureId()
    return kTechId.GorgeWhip
end

function WhipStructureAbility:GetRequiredTechId()
    return kTechId.None
end

function WhipStructureAbility:GetIsPositionValid(position, player)
    return true
end

function WhipStructureAbility:GetSuffixName()
    return "gorgewhip"
end

function WhipStructureAbility:GetDropClassName()
    return "GorgeWhip"
end

function WhipStructureAbility:GetDropMapName()
    return GorgeWhip.kMapName
end