function AddSiegeTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local conductor = entityList:GetEntityAtIndex(0) 
                sandcastle:SendNotification(seconds)
                sandcastle:AddTime(seconds) 
    end    
end
function AddFrontTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                sandcastle:SendNotification(seconds)
                sandcastle:AddTime(seconds) 
    end    
end
function GetSandCastle() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                 return sandcastle
    end    
    return nil
end
function GetIsPointInMarineBase(where)    
    local cclocation = nil
           for _, cc in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        cclocation = GetLocationForPoint(cc:GetOrigin())
        cclocation = cclocation.name
             break
          end
    
    local pointlocation = GetLocationForPoint(where)
          pointlocation = pointlocation and pointlocation.name or nil
          
          return pointlocation == cclocation
    
end
function GetNearestMixin(origin, mixinType, teamNumber, filterFunc)
    assert(type(mixinType) == "string")
    local nearest = nil
    local nearestDistance = 0
    for index, ent in ientitylist(Shared.GetEntitiesWithTag(mixinType)) do
        if not filterFunc or filterFunc(ent) then
            if teamNumber == nil or (teamNumber == ent:GetTeamNumber()) then
                local distance = (ent:GetOrigin() - origin):GetLength()
                if nearest == nil or distance < nearestDistance then
                    nearest = ent
                    nearestDistance = distance
                end
            end
        end
    end
    return nearest
end
function FindFreeSpace(where, mindistance, maxdistance)    
     if not mindistance then mindistance = .5 end
     if not maxdistance then maxdistance = 24 end
        for index = 1, 8 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, mindistance, maxdistance, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation.name or nil
           local sameLocation = spawnPoint ~= nil and locationName == wherelocation
        
           if spawnPoint ~= nil and sameLocation   then
              return spawnPoint
           end
       end
           Print("No valid spot found for FindFreeSpace")
           return where
end
  