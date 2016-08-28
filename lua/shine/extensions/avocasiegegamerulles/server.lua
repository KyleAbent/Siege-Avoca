--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"

local function GetSandCastle() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                 return sandcastle
    end    
    return nil
end
local function GetImaginator() 
    local entityList = Shared.GetEntitiesWithClassname("Imaginator")
    if entityList:GetSize() > 0 then
                 local imaginator = entityList:GetEntityAtIndex(0) 
                 return imaginator
    end    
    return nil
end
local function GetResearcher() 
    local entityList = Shared.GetEntitiesWithClassname("Researcher")
    if entityList:GetSize() > 0 then
                 local researcher = entityList:GetEntityAtIndex(0) 
                 return researcher
    end    
    return nil
end

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
return true
end

function Plugin:MapPostLoad()
      Server.CreateEntity(SandCastle.kMapName)
      Server.CreateEntity(Imaginator.kMapName)
      Server.CreateEntity(Researcher.kMapName)
end

/*
function Plugin:CommLoginPlayer(Building, Player)
  if not  GetGameInfoEntity():GetWarmUpActive() then 
if Building:GetTeamNumber() == 1 then
GetImaginator().marineenabled = false
GetResearcher().marineenabled = false
self:NotifyGeneric( nil, "Marines Imaginator set to false (No Comm Required)", true)
self:NotifyGeneric( nil, "Marines Researcher set to false (No Comm Required)", true)
elseif  Building:GetTeamNumber() == 2 then
GetImaginator().alienenabled = false
GetResearcher().alienenabled = false
self:NotifyGeneric( nil, "Aliens Imaginator set to false (No Comm Required)", true)
self:NotifyGeneric( nil, "Aliens Researcher set to false (No Comm Required)", true)
end
 end
end

function Plugin:CommLogout(Building)
  if not  GetGameInfoEntity():GetWarmUpActive()then 
if Building:GetTeamNumber() == 1 then
GetImaginator().marineenabled = true
GetResearcher().marineenabled = true
self:NotifyGeneric( nil, "Marines Imaginator set to true(No Comm Required)", true)
self:NotifyGeneric( nil, "Marines Researcher set to true (No Comm Required)", true)
elseif  Building:GetTeamNumber() == 2 then
GetImaginator().alienenabled = true
GetResearcher().alienenabled = true
self:NotifyGeneric( nil, "Aliens Imaginator set to true (No Comm Required)", true)
self:NotifyGeneric( nil, "Aliens Imaginator set to true (No Comm Required)", true)
end
  end
end
*/
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Season 3]",  255, 0, 0, String, Format, ... )
end

function Plugin:SetGameState( Gamerules, State, OldState )
           if State == kGameState.Countdown then
           
           
             GetSandCastle():OnRoundStart()
            GetImaginator():OnRoundStart()
           --  DestroyEntity(GetImaginator())
             GetResearcher():OnRoundStart()
       
       
       elseif State == kGameState.NotStarted then
             GetSandCastle():OnPreGame()
             GetImaginator():OnPreGame()
             GetResearcher():OnPreGame()
         --elseif State == kGameState.Team1Won or state == kGameState.Team2Won then    

       
          end
          

              
end
function Plugin:ClientConnect(client)
     if client:GetUserId() == 22542592 or client:GetUserId() == 8086089 then
     

     self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s 3", client:GetUserId() )) end
      end)
      end

end

function Plugin:CreateCommands()


local function MainRoom( Client, Boolean )


GetSandCastle().mainroom = Boolean

  
   self:NotifyGeneric( nil, "MainRoom set to %s", true, Boolean)
  
end

local MainRoomCommand = self:BindCommand( "sh_mainroom", "mainroom", MainRoom )
MainRoomCommand:Help( "sh_MainRoom - auto attack waypoint and threat marker and room chang elights (wip) " )
MainRoomCommand:AddParam{ Type = "boolean" }

local function Researcher( Client, Number, Boolean )

if Number == 1 then 
GetResearcher().marineenabled = Boolean
elseif Number == 2 then
GetResearcher().alienenabled = Boolean
end


  
   self:NotifyGeneric( nil, "%s Researcher set to %s (No Comm Required)", true, Number, Boolean)
  
end

local ResearcherCommand = self:BindCommand( "sh_researcher", "researcher", Researcher )
ResearcherCommand:Help( "sh_researcher - <team> - true/false - Automated Research system (No comm required) " )
ResearcherCommand:AddParam{ Type = "team" }
ResearcherCommand:AddParam{ Type = "boolean" }





local function Imaginator( Client, Number, Boolean )

GetImaginator():SetImagination(Boolean, Number)

if Number == 1 then 
GetImaginator().marineenabled = Boolean
elseif Number == 2 then
GetImaginator().alienenabled = Boolean
end
  
 self:NotifyGeneric( nil, "%s Imaginator set to %s (No Comm Required)", true, Number, Boolean)
  
end

local ImaginatorCommand = self:BindCommand( "sh_imaginator", "imaginator", Imaginator )
ImaginatorCommand:Help( "sh_Imaginator - 1/2 - true/false - Automated structure placement system (No Comm Required) " )
ImaginatorCommand:AddParam{ Type = "team" }
ImaginatorCommand:AddParam{ Type = "boolean" }




end