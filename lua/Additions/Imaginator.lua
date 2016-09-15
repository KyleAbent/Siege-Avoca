--Kyle 'Avoca' Abent

class 'Imaginator' (ScriptActor) 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
 alienenabled = "private boolean",
 marineenabled = "private boolean",
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
function Imaginator:DelayActivation()
  local team1Commander = GetGamerules().team2:GetCommander()
    local team2Commander = GetGamerules().team2:GetCommander()
          self.marineenabled = not team1Commander
   self.alienenabled = not team2Commander
   return true
end
function Imaginator:OnRoundStart() 
   for i = 1, 4 do
     Print("Imaginator OnRoundStart")
   end
     BuildKill()

      self.marineenabled = false
   self.alienenabled = false
  
       self:AddTimedCallback(Imaginator.DelayActivation, 16)
            
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
local function GetHasAdvancedArmory()
    for index, armory in ipairs(GetEntitiesForTeam("Armory", 1)) do
       if armory:GetTechId() == kTechId.AdvancedArmory then return true end
    end
    return false
end
local function GetIsACreditStructure(who)
local boolean = HasMixin(who, "Avoca") and who:GetIsACreditStructure()  or false
--Print("isacredit structure is %s", boolean)
return boolean

end
local function OrganizedIPCheck(who)
local count = 0
local ips = GetEntitiesForTeamWithinRange("InfantryPortal", 1, who:GetOrigin(), kInfantryPortalAttachRange)
            for index, ent in ipairs(ips) do
              if not GetIsACreditStructure(ent) then
                  count = count + 1
               end   
           end
           
           if count >= 2 then return end
           
           for i = 1, math.abs( 2 - count ) do
           local cost = 20
               if TresCheck(1, cost) then 
               local origin = FindFreeSpace(who:GetOrigin(), 1, kInfantryPortalAttachRange)
               local ip = CreateEntity(InfantryPortalAvoca.kMapName, origin,  1)
              ip:GetTeam():SetTeamResources(ip:GetTeam():GetTeamResources() - cost)
              end
           end
           
              
           
end
local function HaveCCsCheckIps()
   local CommandStations = GetEntitiesForTeam( "CommandStation", 1 )
       if not CommandStations then return end
        OrganizedIPCheck(table.random(CommandStations))
end
local function GetMarineSpawnList()
local tospawn = {}
local canafford = {}
local cost = 1 
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true HaveCCsCheckIps() end
      table.insert(tospawn, kTechId.PhaseGate)
      table.insert(tospawn, kTechId.Armory)
      table.insert(tospawn, kTechId.Observatory)
     -- table.insert(tospawn, kTechId.Scan)
      table.insert(tospawn, kTechId.RoboticsFactory)
      table.insert(tospawn, kTechId.Observatory)
      
   -- local  AdvancedArmory = #GetEntitiesForTeam( "AdvancedArmory", 1 )
     
        --  if AdvancedArmory => 1 then
            if GetHasAdvancedArmory() then
            table.insert(tospawn, kTechId.PrototypeLab)
            end
    --  end
      

      table.insert(tospawn, kTechId.Sentry)
      
      local  ArmsLabs = #GetEntitiesForTeam( "ArmsLab", 1 )
      --local  InfantryPortal = #GetEntitiesForTeam( "InfantryPortal", 1 )
      local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
      

      
      
      if ArmsLabs < 2 then
      table.insert(tospawn, kTechId.ArmsLab)
      end
      
      
      --if InfantryPortal < 4 then
      --table.insert(tospawn, kTechId.InfantryPortal)
      --end
      
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
local function FuckShitUp(self)               --would these be better spawned through robo?
      local  AvocaArcCount = #GetEntitiesForTeam( "AvocaArc", 1 )
      local  SiegeArcCount = #GetEntitiesForTeam( "SiegeArc", 1 )
      local  CommandStation = GetEntitiesForTeam( "CommandStation", 1 )
      CommandStation = table.random(CommandStation)
      
      
            if AvocaArcCount < 1 then
              CreateEntity(AvocaArc.kMapName, FindFreeSpace(CommandStation:GetOrigin()) , 1)
--              CreateEntity(PhaseAvoca.kMapName, FindFreeSpace(CommandStation:GetOrigin()) , 1)
      end
      
            if SiegeArcCount < 12 then
              CreateEntity(SiegeArc.kMapName, FindFreeSpace(CommandStation:GetOrigin()) , 1)
      end 

end

local function InstructSiegeArcs(self)
             for index, siegearc in ipairs(GetEntitiesForTeam("SiegeArc", 1)) do
                 siegearc:Instruct()
             end
end
function Imaginator:ActualFormulaMarine()

      
--Print("AutoBuildConstructs")
local randomspawn = nil
local tospawn, cost, gamestarted = GetMarineSpawnList()
if not gamestarted or (gamestarted and GetSandCastle():GetIsSiegeOpen()) then FuckShitUp(self) InstructSiegeArcs(self)end
local airlock = GetActiveAirLock()
local success = false
local entity = nil
            if airlock and tospawn then
                local powerpoint = GetPowerPointForLocation(airlock.name)
             if powerpoint then
                 randomspawn = FindFreeSpace(FindMarine(airlock, powerpoint), 2.5)
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return ent:GetTechId() == tospawn or ( ent:GetTechId() == kTechId.AdvancedArmory and tospawn == kTechId.Armory) end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = nearestof:GetMinRangeAC()
                          if tospawn == kTechId.Scan then minrange = kScanRadius end
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
local function FindPoorVictim()
local airlock = GetActiveAirLock()
local spawnpoint = airlock and airlock:GetRandomMarine() or nil
       return spawnpoint
end
local function ChanceRandomContamination(who) --messy
    --  Print("ChanceRandomContamination")
     gamestarted =  not GetGameInfoEntity():GetWarmUpActive() 
     local chance = GetSiegeDoorOpen() and 50 or 30
     local randomchance = math.random(1, 100)
     if (not gamestarted or TresCheck( 2, 5 ) ) and randomchance <= chance then
       local where = FindPoorVictim()
           if where then 
               local contamination = CreateEntityForTeam(kTechId.Contamination, FindFreeSpace(where, 4, 8), 2)
                    -- CreatePheromone(kTechId.ExpandingMarker,contamination:GetOrigin(), 2) 
                    contamination:StartBeaconTimer()
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
       
      self:DoBetterUpgs()

return true

end
local function UpgChambers()
           local gamestarted = not GetGameInfoEntity():GetWarmUpActive()   
if not gamestarted then return nil end     
 local tospawn = {}
local canafford = {}    

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

           
        if hasshift then  
              local  Spur = #GetEntitiesForTeam( "Spur", 2 )
              if Spur < 3 then table.insert(tospawn, kTechId.Spur) end
       end

        if hasecrag  then  
              local  Shell = #GetEntitiesForTeam( "Shell", 2 )
              if Shell < 3 then table.insert(tospawn, kTechId.Shell) end
       end
        if hasshade then  
                local  Veil = #GetEntitiesForTeam( "Veil", 2 )
              if Veil < 3 then table.insert(tospawn, kTechId.Veil) end
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
local function GetHivePowerPoint()
 local hivey = nil
            for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
               hivey = hive
               break   
             end
local node = GetNearest(hivey:GetOrigin(), "PowerPoint", 1, function(ent) return GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(hivey:GetOrigin())  end)

if node then return node end

return nil

end
function Imaginator:ClearAttached()
return 
end
function Imaginator:DoBetterUpgs()
local tospawn, cost, gamestarted = UpgChambers()
local success = false
local randomspawn = nil
local hivepower = GetHivePowerPoint()
     if hivepower and tospawn then             
                 randomspawn = FindFreeSpace(hivepower:GetOrigin())
            if randomspawn then
                   local entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                    if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
            end
  end
    
  return success
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
                 randomspawn = FindFreeSpace(FindAlien(GetAllLocationsWithSameName(powerpoint:GetOrigin(), tospawn == kTechId.Clog), powerpoint), 2.5)
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetTechId() == tospawn end)
                if tospawn == kTechId.Clog then  nearestof = GetNearest(randomspawn, "Clog", 2) end
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange =  nearestof:GetMinRangeAC() or 12
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
        if not respoint:GetAttached() then AutoDrop(self, respoint) end
    end
end

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)