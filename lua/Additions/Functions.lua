--Kyle 'Avoca' Abent
function CheckSpaceAboveForJump(who)

    local startPoint = who:GetOrigin() 
    local endPoint = startPoint + Vector(1.2, 1.2, 1.2)
    local trace = Shared.TraceRay(who:GetOrigin(), who:GetOrigin() + Vector(0,1,0),  CollisionRep.Default,  PhysicsMask.All,  EntityFilterOne(self))
       if trace.fraction < 1 or trace.entity then
            return false
        end
    return GetWallBetween(startPoint, endPoint, who)
    
end
   function FindFreeSpawn(who) 
         if not CheckSpaceAboveForJump(who) then return who:GetOrigin() + Vector(0, 0.2, 0) end
        for index = 1, 25 do
           local extents = LookupTechData(kTechId.Onos, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, who:GetModelOrigin(), .5, 12, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == who:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation then//and GetIsPointOnInfestation(spawnPoint) then
           return spawnPoint
           end
       end
           Print("No valid spot found for tunnel exit!")
           return FindFreeSpace(who:GetOrigin())
    end 
function GetAllLocationsWithSameName(origin)
local location = GetLocationForPoint(origin)
local locations = {}
local name = location.name
 for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location.name == name then table.insert(locations, location) end
    end
    return locations
end
function UpdateTypeOfHive(who)
local hasshade = false
local hasecrag = false
local hasshift = false

             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() and hive:GetIsBuilt() then 
                  if hive:GetTechId() ==  kTechId.CragHive then
                  hasecrag = true
                  elseif hive:GetTechId() ==  kTechId.ShadeHive then
                  hasshade = true
                  elseif hive:GetTechId() ==  kTechId.ShiftHive then
                  hasshift = true
                  end
                end
              end
local techids = {}
if hasecrag == false then table.insert(techids, kTechId.CragHive) end
if hasshade == false then table.insert(techids, kTechId.ShadeHive) end
if hasshift == false then table.insert(techids, kTechId.ShiftHive) end
   
   if #techids == 0 then return end 
    for i = 1, #techids do
      local current = techids[i]
      if who:GetTechId() == techid then
      table.remove(techids, current)
      end
    end
    
    local random = table.random(techids)
    
    who:UpgradeToTechId(random) 
    who:GetTeam():GetTechTree():SetTechChanged()

end
function UpdateAliensWeaponsManually() ///Seriously this makes more sense than spamming some complicated formula every 0.5 seconds no?
 for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        alien:HiveCompleteSoRefreshTechsManually() 
end
end
function GetIsMarineImaginatorActive()
  local gamestarted = not  GetGameInfoEntity():GetWarmUpActive()
   local team1Commander = GetGamerules().team1:GetCommander()
   return true --not gamestarted and not team1Commander and GetImaginator().marineenabled == true
end
function GetIsRoomPowerDown(who)
 local location = GetLocationForPoint(who:GetOrigin())
 local powernode = GetPowerPointForLocation(location.name)
 if powernode and powernode:GetIsDisabled()  then return true end
 return false
end
function GetEntitiesInHiveRoom(who)
local hiventity = nil
local hitentities = {}
            for index, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                   if hive then
                     hiventity = hive
                     break
                   end
                end 
    -- Print("hivelocation is %s", hivelocation)
    if hiventity ~= nil then
    local entities = GetEntitiesWithMixinForTeamWithinRange("Live", 2, hiventity:GetOrigin(), ARC.kFireRange)
          table.insert(hitentities,hiventity)
      
           if #entities == 0 then return end
           for i = 1, #entities do
             local possibletarget = entities[i]
                 if who:GetCanFireAtTarget(possibletarget) then
                   table.insert(hitentities,possibletarget)
                 end
           end
    end
    
    return hitentities 
    
end
local function GetLocationName(who)
        local location = GetLocationForPoint(who:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function GetIsInSiege(who)
if string.find(GetLocationName(who), "siege") or string.find(GetLocationName(who), "Siege") then return true end
return false
end
local function GetLocationNameWhere(where)
        local location = GetLocationForPoint(where)
        local locationName = location and location:GetName() or ""
        return locationName
end
function GetWhereIsInSiege(where)
if string.find(GetLocationNameWhere(where), "siege") or string.find(GetLocationNameWhere(where), "Siege") then return true end
return false
end
       function FindArcHiveSpawn(where)    
        for index = 1, 8 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, .5, 48, EntityFilterAll())
           local inradius = false

           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
             inradius = #GetEntitiesWithinRange("Hive", spawnPoint, ARC.kFireRange) >= 1
           end
                -- Print("FindArcHiveSpawn inradius is %s", inradius)
           local sameLocation = spawnPoint ~= nil and GetWhereIsInSiege(spawnPoint)
         --  Print("FindArcHiveSpawn sameLocation is %s", sameLocation)

           if spawnPoint ~= nil and sameLocation and inradius then
           return spawnPoint
           end
       end
--           Print("No valid spot found for FindArcHiveSpawn")
           return nil --FindFreeSpace(where, .5, 48)
    end
function GetIsPointWithinHiveRadius(point)     
    /*
    local hivesnearby = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
      for i = 1, #hivesnearby do
           local ent = hivesnearby[i]
           if ent == GetClosestHiveFromCC(point) then return true end
              return false   
     end
   */
  
   local hive = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
   if #hive >= 1 then return true end

   return false
end
function GetGameStarted()
     local gamestarted = false
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   return gamestarted
end
function ExploitCheck(who)
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end

 if not gamestarted then return end 
 
 
  if who:isa("Cyst") then --Better than getentwithinrange because that returns a table regardless of these specifics of range and origin
     local frontdoor = GetNearest(who:GetOrigin(), "FrontDoor", 0, function(ent) return who:GetDistance(ent) <= 12 and ent:GetOrigin() == ent.savedOrigin end)
        if frontdoor  then who:Kill( )return end
  end
  
  local location = GetLocationForPoint(who:GetOrigin())
  local locationName = location and location:GetName() or ""
  if string.find(locationName, "siege") or string.find(locationName, "Siege") then
  
    if not GetSandCastle():GetIsSiegeOpen() then who:Kill( )end
  
  end

end
function AddSiegeTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                sandcastle:AddSiegeTime(seconds) 
    end    
end
function GetRandomChair()
    local entityList = Shared.GetEntitiesWithClassname("CommandStation")
    if entityList:GetSize() > 0 then
                 local cc = entityList:GetEntityAtIndex(0) 
                 return cc
    end    
    return nil
end
function AddFrontTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                sandcastle:SendNotification(seconds)
                sandcastle:AddTime(seconds) 
    end    
end
function GetFrontDoorOpen()
   return GetSandCastle():GetIsFrontOpen()
end
function GetSiegeDoorOpen()
   return GetSandCastle():GetIsSiegeOpen()
end
function GetSandCastle() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                 return sandcastle
    end    
    return nil
end
function GetImaginator() 
    local entityList = Shared.GetEntitiesWithClassname("Imaginator")
    if entityList:GetSize() > 0 then
                 local imaginator = entityList:GetEntityAtIndex(0) 
                 return imaginator
    end    
    return nil
end
function GetResearcher() 
    local entityList = Shared.GetEntitiesWithClassname("Researcher")
    if entityList:GetSize() > 0 then
                 local researcher = entityList:GetEntityAtIndex(0) 
                 return researcher
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
function GetIsPointInAlienBase(where)    
    local cclocation = nil
           for _, cc in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
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
        for index = 1, 1 do
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
--           Print("No valid spot found for FindFreeSpace")
           return where
end
  function GetAverageBuiltNode()
    local origin = 0
    local count = 0
              for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                     if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
                      origin = origin + powerpoint:GetOrigin()
                      count = count + 1
                     end
             end
   origin = origin / count
    return origin 
  end
    