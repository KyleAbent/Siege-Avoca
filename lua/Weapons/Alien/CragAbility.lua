//
// lua\Weapons\Alien\CragAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'CragStructureAbility' (StructureAbility)

function CragStructureAbility:GetEnergyCost(player)
    return 0
end

function CragStructureAbility:GetPrimaryAttackDelay()
    return 0
end

function CragStructureAbility:GetGhostModelName(ability)
    return Crag.kModelName
end

function CragStructureAbility:GetDropStructureId()
    return kTechId.GorgeCrag
end

function CragStructureAbility:GetIsPositionValid(position, player)
    return true
end

//function CragStructureAbility:GetRequiredTechId()
  //  return kTechId.CragHive
//end

function CragStructureAbility:GetSuffixName()
    return "gorgecrag"
end

function CragStructureAbility:GetDropClassName()
    return "GorgeCrag"
end

function CragStructureAbility:GetDropMapName()
    return GorgeCrag.kMapName
end
