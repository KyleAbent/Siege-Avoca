-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/

class 'SandCastle' (Entity)
SandCastle.kMapName = "sandcastle"



local networkVars = 

{
   SiegeTimer = "float",
   FrontTimer = "float"
}


function SandCastle:OnCreate() 
   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
end
function SandCastle:GetIsMapEntity()
return true
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
function SandCastle:OnRoundStart() 
   self.SiegeTimer = kSiegeTimer
   self.FrontTimer = kFrontTimer
   CloseDoors()
           if Server then
              self:AddTimedCallback(SandCastle.CountSTimer, 1)
              self:AddTimedCallback(SandCastle.FrontDoorTimer, 1)
            end
end


Shared.LinkClassToMap("SandCastle", SandCastle.kMapName, networkVars)





