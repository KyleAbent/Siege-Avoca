-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/

class 'SandCastle' (ScriptActor)
SandCastle.kMapName = "sandcastle"



local networkVars = 

{
   SiegeTimer = "float",
   FrontTimer = "float",
}


function SandCastle:OnReset() 
   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
end
function SandCastle:GetIsMapEntity()
return true
end
function SandCastle:ClearAttached()
return 
end
function SandCastle:OnCreate()
     self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
      self:SetUpdates(true)
end
local function DoubleCheckLocks(who)
               for index, door in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 door:CloseLock()
              end 
end
function SandCastle:OnRoundStart() 


if Server then   self:AddTimedCallback(SandCastle.DiscoLights, 16) end
   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
  -- self:AutoBioMass()
  DoubleCheckLocks(self)
end
function SandCastle:GetSiegeLength()
 return self.SiegeTimer
end
function SandCastle:GetFrontLength()
 return self.FrontTimer 
end
function SandCastle:OpenSiegeDoors(cleartimer)
     if cleartimer == true then self.SiegeTimer = 0 end
     -- Print("OpenSiegeDoors SandCastle")
               for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
                 if not siegedoor:isa("FrontDoor") then siegedoor:Open() end
              end 
end
function SandCastle:OpenFrontDoors(cleartimer, pregame)

      if cleartimer == true then self.FrontTimer = 0 end
               for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                frontdoor:Open(pregame)
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
               self:OpenSiegeDoors(true)
       end
       
end
function SandCastle:OnUpdate(deltatime)
  if Server then
    local gamestarted = GetGamerules():GetGameStarted()
  if gamestarted then 
       if not self.timelasttimerup or self.timelasttimerup + 1 <= Shared.GetTime() then
       self:FrontDoorTimer()
       self:CountSTimer()
        self.timeLastAutomations = Shared.GetTime()
         end
  
  end
  end
end
function SandCastle:AddSiegeTime(seconds)
  if not self:GetIsSiegeOpen() then self.SiegeTimer = self.SiegeTimer + seconds end
end
function SandCastle:FrontDoorTimer()
    if self:GetIsFrontOpen() then
         boolean = true
         self:OpenFrontDoors(true) -- Ddos!
       end

end
local function CoordinateWithPowerNode(locationname)
                 local powernode = GetPowerPointForLocation(locationname)
                    if powernode then
                    powernode:SetLightMode(kLightMode.MainRoom)
                    powernode:AddTimedCallback(function() powernode:SetLightMode(kLightMode.Normal) end, 10)
                    end
end
function SandCastle:DiscoLights()
local locations = EntityListToTable(Shared.GetEntitiesWithClassname("Location"))
      -- locations = table.random(locations)

       local name = nil
       for _, derp in ipairs(locations) do
        local powernode = GetPowerPointForLocation(derp.name)
         if powernode and ( powernode:GetIsBuilt() and not powernode:GetIsDisabled() )  then   name = derp.name break end
       end
       
       if name == nil then return true end

               for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
           if location.name == name then 
         CoordinateWithPowerNode(location.name)
        end
    end

       return true
end
function SandCastle:OnPreGame()

   for i = 1, 4 do
     Print("SandCastle OnPreGame")
   end
   
   for i = 1, 8 do
   self:OpenSiegeDoors(false, true)
   self:OpenFrontDoors(false, true)
   end
   
end

Shared.LinkClassToMap("SandCastle", SandCastle.kMapName, networkVars)





