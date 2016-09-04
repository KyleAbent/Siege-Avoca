function OnCommandGorgeBuildGorgeStructure(client, message)

    local player = client:GetControllingPlayer()
    local origin, direction, structureIndex, lastClickedPosition = ParseGorgeBuildMessage(message)
    
    local dropStructureAbility = player:GetWeapon(DropGorgeStructureAbility.kMapName)

    --[[
        The player may not have an active weapon if the message is sent
        after the player has gone back to the ready room for example.
    ]]
    if dropStructureAbility then
        dropStructureAbility:OnDropStructure(origin, direction, structureIndex, lastClickedPosition)
    end
    
end


Server.HookNetworkMessage("GorgeBuildGorgeStructure", OnCommandGorgeBuildGorgeStructure)