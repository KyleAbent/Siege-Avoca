--Kyle 'Avoca' Abent

class 'Imaginator' (ScriptActor) --Because I dont want to spawn it other than when conductor is active and that file is already full. 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
 alienenabled = "boolean",
 marineenabled = "boolean",
}

local function BuildPowerNodes()
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                       if not powerpoint:GetIsSocketed() then powerpoint:SetConstructionComplete()  powerpoint:Kill() end
             end
end
local function BuildKill()
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                       if not powerpoint:GetIsSocketed() and not GetIsInSiege(powerpoint) then 
                        powerpoint:SetConstructionComplete()
                       local resnodes = GetEntitiesWithinRange( "ResourcePoint", powerpoint:GetOrigin(), 18 )
                       if #resnodes >= 4 then 
                      powerpoint:Kill()
                      end
                     end
             end
end
local function ChangeBuiltNodeLightsDiscolulz()
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                    if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then   powerpoint:SetLightMode(kLightMode.MainRoom) end
             end
end
function Imaginator:OnCreate() 
/*
   for i = 1, 4 do
     Print("Imaginator created")
   end
   */
   self.marineenabled = true
   self.alienenabled = true
   self:SetUpdates(true)
end
function Imaginator:OnInitialized()

end
function Imaginator:GetIsMapEntity()
return true
end
function Imaginator:OnUpdate(deltatime)
   
   if Server then
                 if not  self.timeLastAutomations or self.timeLastAutomations + 8 <= Shared.GetTime() then
                 self.timeLastAutomations = Shared.GetTime()
        self:Automations()
         end
            if not  self.timeLastImaginations or self.timeLastImaginations + math.random(4,8) <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
        self:Imaginations()
         end
            if not  self.timeLastCystTimer or self.timeLastCystTimer + 1 <= Shared.GetTime() then
            self.timeLastCystTimer = Shared.GetTime()
         self:CystTimer()
         end
         
         
         end
   
end
function Imaginator:OnPreGame()

   for i = 1, 4 do
     Print("Imaginator OnPreGame")
   end
   
   
end
function Imaginator:OnRoundStart() 
   for i = 1, 4 do
     Print("Imaginator OnRoundStart")
   end
     local team1Commander = GetGamerules().team1:GetCommander()
  local team2Commander = GetGamerules().team2:GetCommander()
  
      self.marineenabled = not team1Commander
   self.alienenabled = not team2Commander
  
   if self.alienenabled then BuildKill() end
            
end
function Imaginator:SetImagination(boolean, team)



  if team == 1 then
  self.marineenabled = boolean
          --  if boolean == true then
         --       local  BigMac = #GetEntitiesForTeam( "BigMac", 1 )
         --        if not BigMac then  
         --    else
             
         --    end
   
  elseif team == 2 then
  self.alienenabled = boolean
  if self.alienenabled == true then BuildKill() end --and not GetSandCastle():GetIsFrontOpen() then BuildKill() end
  end


end
local function GetDisabledPowerPoints()
 local nodes = {}
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                    if powerpoint and  powerpoint:GetIsDisabled() and not ( not GetSiegeDoorOpen() and GetIsInSiege(powerpoint) ) then
                    table.insert(nodes, powerpoint)
                    end
                    
             end

return nodes

end
local function PowerPointStuff(who, self)
local location = GetLocationForPoint(who:GetOrigin())
local powerpoint =  location and GetPowerPointForLocation(location.name)
  local team1Commander = GetGamerules().team1:GetCommander()
  local team2Commander = GetGamerules().team2:GetCommander()
      if powerpoint ~= nil then 
              if not ( team1Commander and self.marineenabled )  and ( powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() ) then 
                return 1
              end
             if ( not team2Commander and self.alienenabled ) and ( not powerpoint:GetCanTakeDamageOverride() )  then
                  return 2
               end
     end
end
local function WhoIsQualified(who, self)
   return PowerPointStuff(who, self)
end
local function Touch(who, where, what, number)
 local tower = CreateEntityForTeam(what, where, number, nil)
         if tower then
            who:SetAttached(tower)
            if number == 1 then
            tower:SetConstructionComplete()
            end
            return tower
         end
end
local function Envision(self,who, which)
   if which == 1 and self.marineenabled then
     Touch(who, who:GetOrigin(), kTechId.Extractor, 1)
   elseif which == 2 and self.alienenabled then
     Touch(who, who:GetOrigin(), kTechId.Harvester, 2)
    end
end
local function AutoDrop(self,who)
  local which = WhoIsQualified(who, self)
  if which ~= 0 then Envision(self,who, which) end
end
function Imaginator:Automations() 
  local gamestarted = not GetGameInfoEntity():GetWarmUpActive() 
   
     if gamestarted then
              self:AutoBuildResTowers()
    else
          BuildPowerNodes()
          ChangeBuiltNodeLightsDiscolulz()
      end
      
              return true
end
function Imaginator:Imaginations() 
  local gamestarted = not  GetGameInfoEntity():GetWarmUpActive()
  local team1Commander = GetGamerules().team1:GetCommander()
  local team2Commander = GetGamerules().team2:GetCommander()
  
            if not gamestarted  or (self.marineenabled and not team1Commander) then 
              self:MarineConstructs()
           end
            
            if not gamestarted  or (self.alienenabled and not team2Commander) then
              self:AlienConstructs(false)
           end
           
              return true
end
function Imaginator:CystTimer()
  local gamestarted = false 
   if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
  local team2Commander = GetGamerules().team2:GetCommander()
              if not gamestarted  or (self.alienenabled and not team2Commander) then
              self:AlienConstructs(true)
           end
              return true
end
local function FindMarine(location, powerpoint)

  local ents = location:GetEntitiesInTrigger()
  
  if #ents == 0 then return powerpoint:GetOrigin() end
  
  for i = 1, #ents do
    local entity = ents[i]
    if entity:isa("Marine") and entity:GetIsAlive() then return entity:GetOrigin() end
  end

 return powerpoint:GetOrigin()
end
local function InsideLocation(ents)
local origin = nil
  if #ents == 0  then return origin end
  for i = 1, #ents do
    local entity = ents[i]   
    if entity:isa("Alien") and entity:GetIsAlive() and (entity:GetGameEffectMask(kGameEffect.OnInfestation) ) then return entity:GetOrigin() end
  end
return origin
  
end

local function FindAlien(location, powerpoint)
  if #location == 0  then return end
  local origin = nil
  
    for i = 1, #location do
    local location = location[i]   
      local ents = location:GetEntitiesInTrigger()
      local potential = InsideLocation(ents)
      if potential ~= nil then origin = potential break end 
  end
  

  
 if origin == nil then origin = powerpoint:GetOrigin() end
  


 return origin
end
/*
local function FindAlien(location, powerpoint)
  local ents = location:GetEntitiesInTrigger()
  
  if #ents == 0 then return powerpoint:GetOrigin() end
  
  for i = 1, #ents do
    local entity = ents[i]   
    if entity:isa("Alien") and entity:GetIsAlive() and (entity:GetGameEffectMask(kGameEffect.OnInfestation) ) then return entity:GetOrigin() end
  end

 return powerpoint:GetOrigin()
end
*/
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end

local function TresCheck(team, cost)
    if team == 1 then
    return GetGamerules().team1:GetTeamResources() >= cost
    elseif team == 2 then
    return GetGamerules().team2:GetTeamResources() >= cost
    end

end
local function GetSentryMinRangeReq(where)
local count = 0
            local ents = GetEntitiesForTeamWithinRange("SentryAvoca", 1, where, 16)
            for index, ent in ipairs(ents) do
                  count = count + 1
           end
           
           count = Clamp(count, 1, 4)
           
           return count*8
                
end
local function GetWhipMinRangeReq(where)
local count = 0
            local ents = GetEntitiesForTeamWithinRange("WhipAvoca", 1, where, 16)
            for index, ent in ipairs(ents) do
                  count = count + 1
           end
           
           count = Clamp(count, 1, 4)
           
           return count*16
                
end
local function GetMarineSpawnList()
local tospawn = {}
local canafford = {}
local cost = 1 
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
      table.insert(tospawn, kTechId.PhaseGate)
      table.insert(tospawn, kTechId.Armory)
      table.insert(tospawn, kTechId.Observatory)
     -- table.insert(tospawn, kTechId.Scan)
      table.insert(tospawn, kTechId.RoboticsFactory)
      table.insert(tospawn, kTechId.Observatory)
      
   -- local  AdvancedArmory = #GetEntitiesForTeam( "AdvancedArmory", 1 )
     
        --  if AdvancedArmory => 1 then
            table.insert(tospawn, kTechId.PrototypeLab)
    --  end
      

      table.insert(tospawn, kTechId.Sentry)
      
      local  ArmsLabs = #GetEntitiesForTeam( "ArmsLab", 1 )
      local  InfantryPortal = #GetEntitiesForTeam( "InfantryPortal", 1 )
      local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
      

      
      
      if ArmsLabs < 2 then
      table.insert(tospawn, kTechId.ArmsLab)
      end
      
      
      if InfantryPortal < 4 then
      table.insert(tospawn, kTechId.InfantryPortal)
      end
      
      if CommandStation < 3 then
      table.insert(tospawn, kTechId.CommandStation)
      end
      
    
       for _, techid in pairs(tospawn) do
       local cost = LookupTechData(techid, kTechDataCostKey)
           if not gamestarted or TresCheck(1,cost) then
             table.insert(canafford, techid)
           end
    end
     
     --if TresCheck(4) then
     --table.insert(tospawn, SentryBattery.kMapName)
     -- end

      local finalchoice = table.random(canafford)
      local finalcost = not gamestarted and 0
      finalcost = LookupTechData(finalchoice, kTechDataCostKey) 
      --Print("GetMarineSpawnList() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost, gamestarted
end
--local function BuildArcsMacs()

--end
function Imaginator:MarineConstructs()
       for i = 1, 2 do
         local success = self:ActualFormulaMarine()
         if success == true then return true end
       end
       
    --   BuildArcsMacs()

return true
end
function Imaginator:TriggerNotification(locationId, techId)

    local message = BuildCommanderNotificationMessage(locationId, techId)
    
    -- send the message only to Marines (that implies that they are alive and have a hud to display the notification
    
    for index, marine in ipairs(GetEntitiesForTeam("Player", 1)) do
        Server.SendNetworkMessage(marine, "CommanderNotification", message, true) 
    end

end
local function GetTechId(mapname)
      local thehardway = GetEntitiesWithMixinForTeam("Construct", 1) 
      
      for i = 1, #thehardway do
        local ent = thehardway[i]
         if ent:GetMapName() == mapname then return ent:GetTechId() end
      end
      return nil
end
local function GetActiveAirLock()
  local airlocks = {}
  for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location:GetIsAirLock(true) then table.insert(airlocks,location) end
    end
    return table.random(airlocks) 
end
local function GetScanMinRangeReq(where)

            local obs = #GetEntitiesForTeamWithinRange("Observatory", 1, where, kScanRadius)
            
            for i = 1, obs do
             if GetIsUnitActive(obs) then return 999 end
            end
            
            return kScanRadius  
                
end
local function BuildNotificationMessage(where, self, mapname)
end
local function FuckShitUp(self)
      local  AvocaArcCount = #GetEntitiesForTeam( "AvocaArc", 1 )
      local  SiegeArcCount = #GetEntitiesForTeam( "SiegeArc", 1 )
      local  CommandStation = GetEntitiesForTeam( "CommandStation", 1 )
      CommandStation = table.random(CommandStation)
      
      
            if AvocaArcCount < 1 then
              CreateEntity(AvocaArc.kMapName, FindFreeSpace(CommandStation:GetOrigin()) , 1)
              CreateEntity(PhaseAvoca.kMapName, FindFreeSpace(CommandStation:GetOrigin()) , 1)
      end
      
            if SiegeArcCount < 12 then
              CreateEntity(SiegeArc.kMapName, FindFreeSpace(CommandStation:GetOrigin()) , 1)
      end 

end

function Imaginator:ActualFormulaMarine()

    if GetSandCastle():GetIsSiegeOpen() then FuckShitUp(self) end
   -- SpawnBigMac()
      
--Print("AutoBuildConstructs")
local randomspawn = nil
local tospawn, cost, gamestarted = GetMarineSpawnList()
local airlock = GetActiveAirLock()
local success = false
local entity = nil
            if airlock and tospawn then
                local powerpoint = GetPowerPointForLocation(airlock.name)
             if powerpoint then
                 randomspawn = FindFreeSpace(FindMarine(airlock, powerpoint))
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return ent:GetTechId() == tospawn or ent:isa("AdvancedArmory") and tospawn == kTechId.Armory end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = 12
                          if tospawn == kTechId.Armory then minrange = 16  end
                          if tospawn == kTechId.PhaseGate then minrange = 55  end
                          if tospawn == kTechId.Observatory then minrange = kScanRadius end
                          if tospawn == kTechId.RoboticsFactory then minrange = 72 end
                          if tospawn == kTechId.Sentry then minrange = 16  end --GetSentryMinRangeReq(randomspawn) end
                          if tospawn == kTechId.PrototypeLab then minrange = 42  end
                          if tospawn == kTechId.Scan then minrange = kScanRadius end--GetScanMinRangeReq(randomspawn) end
                          if tospawn == kTechId.CommandStation then minrange = math.random(16,420) end
                          if tospawn == kTechId.ArmsLab then minrange = 4 end
                          if tospawn == kTechId.InfantryPortal then minrange = 8 end
                          if range >=  minrange  then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                               --BuildNotificationMessage(randomspawn, self, tospawn)
                               success = true
                          end --
                     else -- it tonly takes 1!
                       entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
                     end
               end   
            end
  end
    
  return success
  
end
/*
local function HasThreeUpgFor()
GetGamerules().team2
end
*/
local function GetAlienSpawnList(cystonly)

local tospawn = {}
local canafford = {}
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
      
      table.insert(tospawn, kTechId.Shade)
      table.insert(tospawn, kTechId.Shift)
      table.insert(tospawn, kTechId.Whip)
      table.insert(tospawn, kTechId.Crag)
      
      
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
                
                
        if hasshift or not gamestarted then  
              local  Spur = #GetEntitiesForTeam( "Shell", 2 )
              if gamestarted then
                if GetFrontDoorOpen() then table.insert(tospawn, kTechId.StructureBeacon) 
                 end 
               else
              table.insert(tospawn, kTechId.StructureBeacon)  
             end
              if Spur < 3 then table.insert(tospawn, kTechId.Spur) end
       end

        if hasecrag or not gamestarted  then  
              local  Shell = #GetEntitiesForTeam( "Shell", 2 )
              if GetFrontDoorOpen() then table.insert(tospawn, kTechId.EggBeacon) end
              if Shell < 3 then table.insert(tospawn, kTechId.Shell) end
       end
        if hasshade or not gamestarted then  
                local  Veil = #GetEntitiesForTeam( "Veil", 2 )
              if Veil < 3 then table.insert(tospawn, kTechId.Veil) end
       end
       
      table.insert(tospawn, kTechId.NutrientMist)
      
      
      
      if cystonly then
      return kTechId.Clog, 1, gamestarted
      end
      
       for _, techid in pairs(tospawn) do
          local cost = LookupTechData(techid, kTechDataCostKey)
           if not gamestarted or TresCheck(2,cost) then
             table.insert(canafford, techid)   
           end
    end

      local finalchoice = table.random(canafford)
      local finalcost = LookupTechData(finalchoice, kTechDataCostKey)
      finalcost = not gamestarted and 0 or finalcost
      --Print("GetAlienSpawnList() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost, gamestarted
      
end
local function GetBioMassLevel()
           local teamInfo = GetTeamInfoEntity(2)
           local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           return bioMass
end
local function ChanceRandomContamination(who) --messy
    --  Print("ChanceRandomContamination")
     gamestarted =  not GetGameInfoEntity():GetWarmUpActive() 
     local chance = GetSiegeDoorOpen() and 50 or 70
     local randomchance = math.random(1, 100)
     if (not gamestarted or TresCheck( 2, 5 ) ) and randomchance <= chance then
       local where =  GetAverageBuiltNode()
           if where then 
               local contamination = CreateEntityForTeam(kTechId.Contamination, FindFreeSpace(where, 4, 8), 2)
                    -- CreatePheromone(kTechId.ExpandingMarker,contamination:GetOrigin(), 2) 
            if gamestarted then contamination:GetTeam():SetTeamResources(contamination:GetTeam():GetTeamResources() - 5) end
                        --     Print("nearestbuiltnode is %s", contamination)
           end--
         end--
end--
function Imaginator:AlienConstructs(cystonly)


       if not cystonly then
       
       if GetBioMassLevel() >= 9 then
         ChanceRandomContamination(self)
       
       end
       
       end
       
       
       for i = 1, 2 do
         local success = self:ActualAlienFormula(cystonly)
                  if success == true then return true end
       end
       


return true

end
local function GetAllLocationsWithSameName(origin)
local location = GetLocationForPoint(origin)
local locations = {}
local name = location.name
 for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location.name == name then table.insert(locations, location) end
    end
    return locations
end
function Imaginator:ActualAlienFormula(cystonly)
--Print("AutoBuildConstructs")
local  hivecount = #GetEntitiesForTeam( "Hive", 2 )
if hivecount < 3 then return end -- build hives first ya newb
local randomspawn = nil
local powerPoints = GetDisabledPowerPoints()
local tospawn, cost, gamestarted = GetAlienSpawnList(cystonly)
local success = false
local entity = nil

     if powerPoints and tospawn then
                local powerpoint = table.random(powerPoints)
             if powerpoint then                      
                 randomspawn = FindFreeSpace(FindAlien(GetAllLocationsWithSameName(powerpoint:GetOrigin(), tospawn == kTechId.Clog), powerpoint))
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetTechId() == tospawn end)
                if tospawn == kTechId.Clog then  nearestof = GetNearest(randomspawn, "Clog", 2) end
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = 12
                          if tospawn == kTechId.Clog then minrange = kCystRedeployRange * .7 end
                          if tospawn == kTechId.Shade then minrange = 17 end
                          if tospawn == kTechId.Shift then minrange = kEnergizeRange end
                          if tospawn == kTechId.Shift then minrange = kEnergizeRange end
                          if tospawn == kTechId.Crag then minrange = Crag.kHealRadius / 3 end
                          if tospawn == kTechId.EggBeacon then minrange = 9999 end
                          if tospawn == kTechId.StructureBeacon then minrange = 9999 end
                          if tospawn == kTechId.NutrientMist then minrange = NutrientMist.kSearchRange end
                          if range >=  minrange then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                          if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                          end
                          success = true
                     else -- it tonly takes 1!
                         entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
                     end
               end   
            end
  end
    
  return success
 end
function Imaginator:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if respoint:GetAttached() == nil then AutoDrop(self, respoint) end
    end
end

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)