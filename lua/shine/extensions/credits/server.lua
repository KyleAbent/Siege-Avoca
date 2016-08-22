/*Kyle 'Avoca' Abent Credits Season 3
KyleAbent@gmail.com 
*/
local Shine = Shine
local Plugin = Plugin
local HTTPRequest = Shared.SendHTTPRequest

Shine.CreditData = {}
Shine.LinkFile = {}
Shine.BadgeFile = {}
Plugin.Version = "10.28"

local CreditsPath = "config://shine/plugins/credits.json"
local URLPath = "config://shine/CreditsLink.json"
local BadgeURLPath = "config://shine/BadgesLink.json"
local BadgesPath = "config://shine/UserConfig.json"

Shine.Hook.SetupClassHook( "ScoringMixin", "AddScore", "OnScore", "PassivePost" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )



function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.CreditAmount = 0
self.CreditUsers = {}
self.BuyUsersTimer = {}
self.marinecredits = 0
self.aliencredits = 0
self.marinebonus = 0
self.alienbonus = 0

self.UserStartOfRoundCredits = {}
self.MarineTotalSpent = 0
self.AlienTotalSpent = 0
self.Refunded = false

self.PlayerSpentAmount = {}

return true
end

function Plugin:GenereateTotalCreditAmount()
local credits = 0
Print("%s users", table.Count(self.CreditData.Users))
for i = 1, table.Count(self.CreditData.Users) do
    local table = self.CreditData.Users.credits
    credits = credits + table
end
Print("%s credits",credits)
end


local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end


function Plugin:HasLimitOf(Player, classname, teamnumbber, limit)
local entitycount = 0
local entities = {}
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnumbber)) do
        if entity:GetMapName() == classname and entity:GetOwner() == Player then entitycount = entitycount + 1 end
        table.insert(entities, entity)
    end
    
     //             <
    if entitycount ~= limit then return false end

            if #entities > 0 then
            local entity = table.random(entities)
             if string.find(classname, "Sentry") or string.find(classname, "Observatory") or string.find(classname, "ARC") then return true end
                DestroyEntity(entity)
            end
     return true
end
function Plugin:BecauseFuckSpammingCommanders(player)
if not GetGamerules():GetGameStarted() then return end
local CreditCost = 1
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
player:GiveItem(NutrientMist.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end
local function GetIsAlienInSiege(Player)
   if  Player.GetLocationName and 
   string.find(Player:GetLocationName(), "siege") or string.find(Player:GetLocationName(), "Siege") then
   return true
    end
    return false
 end
 
function Plugin:LoadBadges()
     local function UsersResponse( Response )
		local UserData = json.decode( Response )
		self.UserData = UserData
		 Shine.SaveJSONFile( self.UserData, BadgesPath  )
		 
		         self:SimpleTimer(4, function ()
        Shared.ConsoleCommand("sh_reloadusers" ) 
        end)
        
      end
       local BadgeFiley = Shine.LoadJSONFile( BadgeURLPath )
        self.BadgeFile = BadgeFiley
        HTTPRequest( self.BadgeFile.LinkToBadges, "GET", UsersResponse)
end

function Plugin:OnScore( Player, Points, Res, WasKill )
if Points ~= nil and Points ~= 0 and Player and GetGamerules():GetGameStarted() then
 local client = Player:GetClient()
 if not client then return end
         
    local addamount = Points/(10/kCreditMultiplier)      
 local controlling = client:GetControllingPlayer()
 
         if Player:GetTeamNumber() == 1 then
         self.marinecredits = self.marinecredits + addamount
        elseif Player:GetTeamNumber() == 2 then
         self.aliencredits = self.aliencredits + addamount
         end
         
self.CreditUsers[ controlling:GetClient() ] = self:GetPlayerCreditsInfo(controlling:GetClient()) + addamount
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(controlling:GetClient()) ), controlling:GetClient()) 
end
end
function Plugin:NotifySiege( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end




function Plugin:OnReset()
  if self.GameStarted and not self.Refunded then
       self:NotifyCredits( nil, "Did you spend any credits only for the round to reset? If so, then no worries! - You have just been refunded!", true )
       
              Shine.ScreenText.End("Credits")  
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)   
              Shine.ScreenText.End(87)  
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0 
              self.AlienTotalSpent = 0
              self.CreditUsers = {}
              self.PlayerSpentAmount = {}
          
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
    self.Refunded = true
   end     
end

function Plugin:OnFirstThink() 
local CreditsFile = Shine.LoadJSONFile( CreditsPath )
self.CreditData = CreditsFile

// for double credit weekend change 1 to 2 :P

     //   local date = os.date("*t", Shared.GetSystemTime())
     //   local day = date.day
     //   if string.find(day, "Friday") or string.find(day, "Saturday") or day == string.find(day, "Sunday") then
       // kCreditMultiplier = 1
     //   else
        //kCreditMultiplier = 1
      //  end
        

/*
     local function UsersResponse( Response )
		local UserData = json.decode( Response )
		self.UserData = UserData
		 Shine.SaveJSONFile( self.UserData, BadgesPath  )
		 
		         self:SimpleTimer(4, function ()
        Shared.ConsoleCommand("sh_reloadusers" ) 
        end)
        
      end
       local BadgeFiley = Shine.LoadJSONFile( BadgeURLPath )
        self.BadgeFile = BadgeFiley
        HTTPRequest( self.BadgeFile.LinkToBadges, "GET", UsersResponse)
        */
//end

        if not Shine.Timer.Exists("SeedTimer") then
        	Shine.Timer.Create( "SeedTimer", 600, -1, function() self:SeedCredits() end )
      end

end
 function Plugin:SeedCredits()
             
 self:GiveSeedCredits() 
 
 end
 function Plugin:GiveSeedCredits()
 local credits = 10 * kCreditMultiplier
   if kCreditMultiplier == 1 then
 self:NotifyCredits( nil, "%s Credits", true, credits)
 elseif kCreditMultiplier == 2 then
  self:NotifyCreditsDC( nil, "%s Credits", true, credits)
 end
 
  local Players = Shine.GetAllPlayers()
   for i = 1, #Players do
    local player = Players[ i ]
     if player then
      self.CreditUsers[ player:GetClient() ] = self:GetPlayerCreditsInfo(player:GetClient()) + credits
          if self.GameStarted then
          Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(player:GetClient()) ), player:GetClient()) 
          end
      end
   end
 end
 
function Plugin:SaveCredits(Client)
       local Data = self:GetCreditData( Client )
       if Data and Data.credits then 
         if not Data.name or Data.name ~= Client:GetControllingPlayer():GetName() then
           Data.name = Client:GetControllingPlayer():GetName()
           end        
       Data.credits = self:GetPlayerCreditsInfo(Client) 
       else 
      self.CreditData.Users[Client:GetUserId() ] = {credits = self:GetPlayerCreditsInfo(Client), name = Client:GetControllingPlayer():GetName() }
       end
     Shine.SaveJSONFile( self.CreditData, CreditsPath  )
end
function Plugin:ClientDisconnect(Client)
self:SaveCredits(Client)
end
function Plugin:GetPlayerCreditsInfo(Client)
   local Credits = 0
       if self.CreditUsers[ Client ] then
          Credits = self.CreditUsers[ Client ]
       elseif not self.CreditUsers[ Client ] then 
          local Data = self:GetCreditData( Client )
           if Data and Data.credits then 
           Credits = Data.credits 
           end
       end
return math.round(Credits, 2)
end
local function GetIDFromClient( Client )
	return Shine.IsType( Client, "number" ) and Client or ( Client.GetUserId and Client:GetUserId() ) // or nil //or nil was blocked but im testin
 end
function Plugin:GetCreditData(Client)
  if not self.CreditData then return nil end
  if not self.CreditData.Users then return nil end
  local ID = GetIDFromClient( Client )
  if not ID then return nil end
  local User = self.CreditData.Users[ tostring( ID ) ] 
  if not User then 
     local SteamID = Shine.NS2ToSteamID( ID )
     User = self.CreditData.Users[ SteamID ]
     if User then
     return User, SteamID
     end
     local Steam3ID = Shine.NS2ToSteam3ID( ID )
     User = self.CreditData.Users[ ID ]
     if User then
     return User, Steam3ID
     end
     return nil, ID
   end
return User, ID
end

 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 

  if GetGamerules():GetGameStarted() then

  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.85,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    self.PlayerSpentAmount[Client] = 0
    
end
    
 end
 function Plugin:SaveAllCredits()
               local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self:SaveCredits(Player:GetClient())
                  end
             end
 end
function Plugin:SetGameState( Gamerules, State, OldState )
       if State == kGameState.Countdown then
      
          
        self.GameStarted = true
        self.Refunded = false
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)
              Shine.ScreenText.End(87)  
          Shine.ScreenText.End("Credits")    
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0
              self.AlienTotalSpent = 0
              self.PlayerSpentAmount = {}
              
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self.PlayerSpentAmount[Player:GetClient()] = 0
                  //Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = "Loading Credits...",Duration = 1800,R = 255, G = 0, B = 0,Alignment = 0,Size = 3,FadeIn = 0,}, Player )
                  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     
      self.GameStarted = false
          
                 self:SimpleTimer(4, function ()
       
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                 // self:SaveCredits(Player:GetClient())
                     if Player:GetTeamNumber() == 1 or Player:GetTeamNumber() == 2 then
                    Shine.ScreenText.Add( 80, {X = 0.40, Y = 0.15,Text = "Total Credits Earned:".. math.round((Player:GetScore() / 10 + ConditionalValue(Player:GetTeamNumber() == 1, self.marinebonus, self.alienbonus)), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                    Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.20,Text = "Total Credits Spent:".. self.PlayerSpentAmount[Player:GetClient()], Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                     end
                  end
             end
      end)
      
      
            self:SimpleTimer( 16, function() 
       local LinkFiley = Shine.LoadJSONFile( URLPath )
        self.LinkFile = LinkFiley
            HTTPRequest( self.LinkFile.LinkToUpload, "POST", {data = json.encode(self.CreditData)}, function() 
            self:SaveAllCredits()
            self:NotifyCredits( nil, "http://credits.ns2siege.com - credit ranking updated", true)
            end)
            end)
            
            
           //   local Time = Shared.GetTime()
          //   if not Time > kMaxServerAgeBeforeMapChange then
                 self:SimpleTimer( 25, function() 
                 self:LoadBadges()
                 end)
       

    //  self:SimpleTimer(3, function ()    
    //  Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.10,Text = "End of round Stats:",Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    // Shine.ScreenText.Add( 83, {X = 0.40, Y = 0.25,Text = "(Server Wide)Total Credits Earned:".. math.round((self.marinecredits + self.aliencredits), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 84, {X = 0.40, Y = 0.25,Text = "(Marine)Total Credits Earned:".. math.round(self.marinecredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 85, {X = 0.40, Y = 0.30,Text = "(Alien)Total Credits Earned:".. math.round(self.aliencredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 86, {X = 0.40, Y = 0.35,Text = "(Marine)Total Credits Spent:".. math.round(self.MarineTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 87, {X = 0.40, Y = 0.40,Text = "(Alien)Total Credits Spent:".. math.round(self.AlienTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
  //    end)
  end
     
end

function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyMarine( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[redits Season 3]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyAlien( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[redits Season 3]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyCredits( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Credits]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyCreditsDC( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Double Credit Weekend]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyBuy( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Credits Season 3]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end
local function GetIsAlienInSiege(Player)
   if  Player.GetLocationName and 
   string.find(Player:GetLocationName(), "siege") or string.find(Player:GetLocationName(), "Siege") then
   return true
    end
    return false
 end
local function PerformBuy(self, who, whoagain, cost, reqlimit, reqground,reqpathing, setowner, delayafter, mapname,limitof)
   local autobuild = false 
   local success = false
   if self:GetPlayerCreditsInfo(who) < cost then 
self:NotifyCredits( who, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, cost, self:GetPlayerCreditsInfo(who))
return
end

 

if self:HasLimitOf(whoagain, mapname, whoagain:GetTeamNumber(), limitof) then 
self:NotifyCredits(who, "Limit of %s per %s per player ya noob", true, limitof, mapname)
return
end

if reqground then

if not whoagain:GetIsOnGround() then
 self:NotifyCredits( who, "You must be on the ground.s", true)
 return
 end
 
 end
 
 if reqpathing then 
 if not GetPathingRequirementsMet(Vector( whoagain:GetOrigin() ),  GetExtents(kTechId.MAC) ) then
self:NotifyCredits( who, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
 end
 

self.CreditUsers[ who ] = self:GetPlayerCreditsInfo(who) - cost
local entity = CreateEntity(mapname, whoagain:GetOrigin(), whoagain:GetTeamNumber()) 

if not entity then self:NotifyCredits( who, "Invalid Purchase Request of %s.", true, String) return end



if whoagain:GetTeamNumber() == 1 then
self.MarineTotalSpent = self.MarineTotalSpent + cost
        if entity.SetConstructionComplete then 
        entity:SetOwner(whoagain)
             if not whoagain:GetGameEffectMask(kGameEffect.OnInfestation) then
             entity:SetConstructionComplete()
               else
                self:NotifyCredits( who, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
                entity.isGhostStructure = false
            end --
         end  --
elseif whoagain:GetTeamNumber() == 2 then
entity:SetOwner(whoagain)
    self.AlienTotalSpent = self.AlienTotalSpent + cost
      if not GetIsAlienInSiege(whoagain) then
      if entity.SetConstructionComplete then  entity:SetConstructionComplete() end
       else
       self:NotifyCredits( who, "%s placed IN siege, therefore it is not autobuilt.", true, String)
        end --
end --



local supply = LookupTechData(entity:GetTechId(), kTechDataSupply, nil) or 0
whoagain:GetTeam():RemoveSupplyUsed(supply)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(who) ), who) 
self.BuyUsersTimer[who] = Shared.GetTime() + delayafter
Shared.ConsoleCommand(string.format("sh_addpool %s", cost)) 
   self.PlayerSpentAmount[who] = self.PlayerSpentAmount[who]  + cost
   self.CreditUsers[ who ] = self:GetPlayerCreditsInfo(who) - cost



end
local function FirstCheckRulesHere(self, Client, Player, String)
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifyCredits( Client, "Please wait %s seconds before purchasing %s. Thanks.", true, string.TimeToString( NextUse - Time ), String)
return true
end

if not GetGamerules():GetGameStarted() then
self:NotifyCredits( Client, "Buying in pregame is not supported right now. It's a waste of credits unless determined pregame to be free spending later on.", true)
return true
end
/*
local gameRules = GetGamerules()
if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then
self:NotifyCredits( Client, "Buying in suddendeath is not supported right now.", true)
return
end
*/
if Player:isa("Commander") or not Player:GetIsAlive() then 
      self:NotifyCredits( Client, "Either you're dead, or a commander... Really no difference between the two.. anyway, no credit spending for you.", true)
return true
end

/*
if Player then
 self:NotifyCredits( Client, "Purchases currently disabled. ", true)
 return
end
*/
end
local function TeamOneBuyRules(self, Client, Player, String)

local bought = false
local mapnameof = nil
local delay = 12
local reqpathing = true
local CreditCost = 1
local limit = 3

if String == "Observatory"  then
mapnameof = Observatory.kMapName
bought = true
CreditCost = 10
elseif String == "Armory"  then
CreditCost = 12
mapnameof = Armory.kMapName
bought = true
elseif String == "SentryAvoca"  then
mapnameof = SentryAvoca.kMapName
bought = true
limit = 1
CreditCost = 8
elseif String == "PhaseGate" then
CreditCost = 15
mapnameof = PhaseGate.kMapName
bought = true
elseif String == "InfantryPortal" then
mapnameof = InfantryPortal.kMapName
bought = true
elseif  String == "RoboticsFactory" then
CreditCost = 10
mapnameof = RoboticsFactory.kMapName
bought = true 
end

return bought, mapnameof, delay, reqpathing, CreditCost, limit

end

local function TeamTwoBuyRules(self, Client, Player, String)

local bought = false
local mapnameof = nil
local delay = 12
local reqpathing = true
local CreditCost = 2
local limit = 3


if String == "NutrientMist" then
CreditCost = 4
mapnameof = NutrientMist.kMapName
bought = true   
reqpathing = false
elseif String == "Contamination"  then
CreditCost = 2
mapnameof = Contamination.kMapName
bought = true     
elseif String == "EnzymeCloud" then
CreditCost = 1.5
reqpathing = false
mapnameof = EnzymeCloud.kMapName
bought = true
elseif String == "Ink" then
CreditCost = 4
reqpathing = false
mapnameof = ShadeInk.kMapName
bought = true
elseif String == "Hallucination" then
CreditCost = 1.75
reqpathing = false
 mapnameof = HallucinationCloud.kMapName
bought = true
elseif String == "Shade" then
CreditCost = 10
mapnameof = Shade.kMapName
bought = true
elseif String == "Crag" then
CreditCost = 10
mapnameof = Crag.kMapName
bought = true
elseif String == "Whip" then
CreditCost = 10
mapnameof = Whip.kMapName
bought = true
elseif String == "Shift" then
CreditCost = 10
mapnameof = Shift.kMapName
bought = true
elseif String == "Hydra" then
CreditCost = 1
mapnameof = Hydra.kMapName
bought = true
end

return bought, mapnameof, delay, reqpathing, CreditCost, limit

end

function Plugin:CreateCommands()

local function Buy(Client, String)

local Player = Client:GetControllingPlayer()
local mapnameof = nil
local bought = false
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
local reqpathing = true
 if FirstCheckRulesHere(self, Client, Player, String ) == true then return end
local CreditCost = 1

if Player:GetTeamNumber() == 1 then 
  bought, mapnameof, delay, reqpathing, CreditCost, limit = TeamOneBuyRules(self, Client, Player, String)
elseif Player:GetTeamNumber() == 2 then
bought, mapnameof, delay, reqpathing, CreditCost, limit = TeamTwoBuyRules(self, Client, Player, String)
end // end of team numbers

if bought and mapnameof then
 PerformBuy(self, Client, Player, CreditCost, true, true,reqpathing, true, delay, mapnameof, limit) 
end

end



local BuyCommand = self:BindCommand("sh_buy", "buy", Buy, true)
BuyCommand:Help("sh_buy <item name>")
BuyCommand:AddParam{ Type = "string" }

local function Credits(Client, Targets)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self:NotifyCredits( Client, "%s has a total of %s credits", true, Player:GetName(), self:GetPlayerCreditsInfo(Player:GetClient()))
end
end

local CreditsCommand = self:BindCommand("sh_credits", "credits", Credits, true, false)
CreditsCommand:Help("sh_credits <name>")
CreditsCommand:AddParam{ Type = "clients" }

local function AddCredits(Client, Targets, Number, Display)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self.CreditUsers[ Player:GetClient() ] = self:GetPlayerCreditsInfo(Player:GetClient()) + Number
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ), Player:GetClient()) 
   if Display == true then
   self:NotifyGeneric( nil, "gave %s credits to %s (who now has a total of %s)", true, Number, Player:GetName(), self:GetPlayerCreditsInfo(Player:GetClient()))
   end
end
end

local AddCreditsCommand = self:BindCommand("sh_addcredits", "addcredits", AddCredits)
AddCreditsCommand:Help("sh_addcredits <player> <number>")
AddCreditsCommand:AddParam{ Type = "clients" }
AddCreditsCommand:AddParam{ Type = "number" }
AddCreditsCommand:AddParam{ Type = "boolean", Optional = true, Default = true }

end