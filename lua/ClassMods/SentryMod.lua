
SetCachedTechData(kTechId.Sentry, kStructureBuildNearClass, "CommandStation")
SetCachedTechData(kTechId.Sentry, kStructureAttachRange, 999)
SetCachedTechData(kTechId.Sentry, kTechDataSpecifyOrientation, false)


if Server then

 function Sentry:OnUpdate(deltaTime)
        self.attachedToBattery = true
end

end

Sentry.kFov = 360

function Sentry:GetFov()
    return 360
end

function GetCheckSentryLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName  then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kCommSentryPerRoom
    
end

function GetBatteryInRange(commander)

    local batteries = {}
    for _, battery in ipairs(GetEntitiesForTeam("CommandStation", commander:GetTeamNumber())) do
        batteries[battery] = 999
    end
    
    return batteries
    
end