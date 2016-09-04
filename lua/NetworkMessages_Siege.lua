
local kGorgeBuildGorgeStructureMessage = 
{
    origin = "vector",
    direction = "vector",
    structureIndex = "integer (1 to 5)",
    lastClickedPosition = "vector"
}
function BuildGorgeDropGorgeStructureMessage(origin, direction, structureIndex, lastClickedPosition)

    local t = {}
    
    t.origin = origin
    t.direction = direction
    t.structureIndex = structureIndex
    t.lastClickedPosition = lastClickedPosition or Vector(0,0,0)

    return t
    
end    
Shared.RegisterNetworkMessage("GorgeBuildGorgeStructure", kGorgeBuildGorgeStructureMessage)