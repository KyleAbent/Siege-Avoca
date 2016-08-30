-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/

class 'SandCastle' (ScriptActor)
SandCastle.kMapName = "sandcastle"



local networkVars = 

{
   SiegeTimer = "float",
   FrontTimer = "float",
   mainroom = "boolean",
}


function SandCastle:OnReset() 
   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
end
function SandCastle:GetIsMapEntity()
return true
end
function SandCastle:OnCreate()
  self:SetUpdates(true)
     self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
   self.mainroom = true
end

function SandCastle:OnUpdate(deltaTime)
      if Server and not GetGameInfoEntity():GetWarmUpActive()then
         if not  self.timeLastSandCastle or self.timeLastSandCastle + 1 <= Shared.GetTime() then
         self.timeLastSandCastle = Shared.GetTime()
         self:FrontDoorTimer()
         self:CountSTimer() 
          end
      end
end
function SandCastle:GetSiegeLength()
 return self.SiegeTimer
end
function SandCastle:GetFrontLength()
 return self.FrontTimer 
end
function SandCastle:OpenSiegeDoors()
      self.SiegeTimer = 0
     -- Print("OpenSiegeDoors SandCastle")
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 if not siegedoor:isa("FrontDoor") then siegedoor:Open() end
              end 
end
function SandCastle:OpenFrontDoors()

      self.FrontTimer = 0
               for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                frontdoor:Open()
                frontdoor.isvisible = false
              end 


end
function SandCastle:GetIsSiegeOpen()
           local gamestarttime = GetGamerules():GetGameStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.SiegeTimer
end
function SandCastle:GetIsFrontOpen()
           local gamestarttime = GetGamerules():GetGameStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= self.FrontTimer
end
function SandCastle:CountSTimer()

   local boolean = false
       if  self:GetIsSiegeOpen() then
                --  boolean = true
           --  if not SuddenDeathConditionsCheck(self) then
               self:OpenSiegeDoors()
               
            -- else
           --    AddTime(8)
             --end
       end
       return self.SiegeTimer ~= 0
       
end
function SandCastle:AddSiegeTime(seconds)
  if not self:GetIsSiegeOpen() then self.SiegeTimer = self.SiegeTimer + seconds end
end
function SandCastle:FrontDoorTimer()
   local boolean = false
    if self:GetIsFrontOpen() then
         boolean = true
         self:OpenFrontDoors() -- Ddos!
       end
       
       return self.FrontTimer ~= 0
end
local function CloseDoors()
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 siegedoor:TrickedYou()
              end 
end
function SandCastle:PickMainRoom()
   if self.mainroom then
       local location = self:GetLocationWithMostMixedPlayers()
       if not location then return true end
       self:SetMainRoom(location:GetOrigin(), location, opcyst) 
   end
       return true
end
local function CreateAlienMarker(where)
             local nearestenemy = GetNearestMixin(where, "Combat", 1, function(ent) return ent:GetIsInCombat()  and not ent:isa("Commander") and ent:GetIsAlive()  end)
             if not nearestenemy then return end -- hopefully not. Just for now this should be useful anyway.
              local where = nearestenemy:GetOrigin()
              CreatePheromone(kTechId.ThreatMarker,where, 2) 
end
local function SendMarineOrders(self,where)

   if not self:GetIsSiegeOpen( )  then
          for _, player in ipairs(GetEntitiesWithinRange("Marine", where, 999)) do
                 if not player:isa("Commander")  and player:GetClient():GetIsVirtual() and player:GetIsAlive() then
                  local nearestenemy = GetNearestMixin(where, "Combat", 2, function(ent) return ent:GetIsInCombat() and not ent:isa("Commander") and ent:GetIsAlive()  end)
                    if not nearestenemy then return end 
                     local where = nearestenemy:GetOrigin()
                     player:GiveOrder(kTechId.Attack, nearestenemy:GetId(), nearestenemy:GetOrigin(), nil, true, true)
                end
          end
     end     
end
local function CoordinateWithPowerNode(locationname)
                 local powernode = GetPowerPointForLocation(locationname)
                    if powernode then
                    powernode:SetLightMode(kLightMode.MainRoom)
                    powernode:AddTimedCallback(function() powernode:SetLightMode(kLightMode.Normal) end, 10)
                    end
end
function SandCastle:SetMainRoom(where, which, opcyst)
        CreateAlienMarker(where) 
        CoordinateWithPowerNode(which.name)
         --8.20 notes
         --if not self:GetIsFrontOpen() then SendOrderFrontOrBuild?
       -- if self:GetIsSiegeOpen() then return SendMarineDefOrdersSiege() end
        SendMarineOrders(self,where)
end
function SandCastle:OnPreGame()
if Server then   self:AddTimedCallback(SandCastle.PickMainRoom, 16) end
   for i = 1, 4 do
     Print("SandCastle OnPreGame")
   end
   
   
end
function SandCastle:OnRoundStart() 



   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
   CloseDoors()
  -- self:AutoBioMass()
end
function SandCastle:GetLocationWithMostMixedPlayers()
-- works good 2.15
--so far v1.23 shows this works okay except for picking empty res rooms for some reason -.-
//Print("GetLocationWithMostMixedPlayers")

            for _, mainent in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
                    if mainent:GetIsInCombat() then return mainent end
             end
             
local team1avgorigin = Vector(0, 0, 0)
local marines = 1
local team2avgorigin = Vector(0, 0, 0)
local aliens = 1
local neutralavgorigin = Vector(0, 0, 0)

            for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
            if marine:GetIsAlive() and not marine:isa("Commander") then marines = marines + 1 team1avgorigin = team1avgorigin + marine:GetOrigin() end
             end
             
           for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do
            if alien:GetIsAlive() and not alien:isa("Commander") then aliens = aliens + 1 team2avgorigin = team2avgorigin + alien:GetOrigin() end 
             end
             --v1.23 added check to make sure room isnt empty
         neutralavgorigin =  team1avgorigin + team2avgorigin
         neutralavgorigin =  neutralavgorigin / (marines+aliens) --better as a table i know
     //    Print("neutralavgorigin is %s", neutralavgorigin)
     local nearest = GetNearest(neutralavgorigin, "Location", nil, function(ent) local powerpoint = GetPowerPointForLocation(ent.name) return powerpoint ~= nil end)
    if nearest then
   // Print("nearest is %s", nearest.name)
        return nearest
    end

end
function SandCastle:GetCombatEntitiesCount()
            local combatentities = 1
            for _, entity in ipairs(GetEntitiesWithMixin("Combat")) do
                --Though taken from combatmixin.lua :P
             local inCombat = (entity.timeLastDamageDealt + math.random(4,8) > Shared.GetTime()) or (entity.lastTakenDamageTime + math.random(4,8) > Shared.GetTime())
                  if inCombat then combatentities = combatentities + 1 end
                  if entity.mainbattle == true then entity.mainbattle = false end
             end
             //     Print("combatentities %s", combatentities)
            return combatentities
end
function SandCastle:GetCombatEntitiesCountInRoom(location)
       local entities = location:GetEntitiesInTrigger()
       local eligable = 0
             for _, entity in ipairs(entities) do
             if HasMixin(entity, "Combat") then
                local inCombat = (entity.timeLastDamageDealt + math.random(4,8) > Shared.GetTime()) or (entity.lastTakenDamageTime + math.random(4,8) > Shared.GetTime())
                  if inCombat then
                  eligable = eligable + 1
                 end
             end
            end
       // Print("location %s, eligable %s", location, eligable)
        return eligable
end

Shared.LinkClassToMap("SandCastle", SandCastle.kMapName, networkVars)





