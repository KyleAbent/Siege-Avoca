Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")




local networkVars = 


{
avocaarc = "boolean",
siegearc = "boolean",
}

AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)

function ARC:LameFixATM()
self:AddTimedCallback(ARC.Check, 8)
end
local origcanfire = ARC.GetCanFireAtTarget
function ARC:GetCanFireAtTarget(target)

local boolean = origcanfire(self, target)

boolean = boolean and GetFrontDoorOpen() and not self:GetIsVortexed()

return boolean

end
if Server then


function ARC:Instruct()
   if self.siegearc or self.avocaarc then self:SpecificRules() end
   return true
end


end
local origcreate = ARC.OnCreate

function ARC:OnCreate()
  origcreate(self)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    self.siegearc = false
    self.avocaarc = false
  if Server then  self:LameFixATM() end
end
function ARC:Check()
  local gamestarted = false 
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if gamestarted then 
         local team1Commander = GetGamerules().team1:GetCommander()
     if team1Commander then
       
      self.avocaarc = false
      if not GetSandCastle():GetIsSiegeOpen() then self.siegearc = false end
      
    end
   return true
end
function ARC:GetShowDamageIndicator()
    return true
end
local function MoveToHives(self) --Closest hive from origin
--Print("Siegearc MoveToHives")
local siegelocation = GetSiegeLocation()
if not siegelocation then return true end
local siegepower = GetPowerPointForLocation(siegelocation.name)
local hiveclosest = GetNearest(siegepower:GetOrigin(), "Hive", 2)
local origin = 0

--if hiveclosest then
--origin = siegepower:GetOrigin()
--origin = origin + hiveclosest:GetOrigin()
--origin = origin + siegelocation:GetOrigin()
--origin = origin / 3
--end
if origin == 0 then origin = FindArcHiveSpawn(siegepower:GetOrigin())  end
local where = origin
               if where then
        self:GiveOrder(kTechId.Move, nil, where, nil, true, true)
                    return
                end  
   return not self.mode == ARC.kMode.Moving  and not GetIsInSiege(self)  
end
local function MoveToRandomChair(who) --Closest hive from origin
 local commandstation = GetEntitiesForTeam( "CommandStation", 1 )
  commandstation = table.random(commandstation)
 
               if commandstation then
        local origin = commandstation:GetOrigin() -- The arc should auto deploy beforehand
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                    return
                end  
    -- Print("No closest hive????")    
end
local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTarget(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if who and player then
    who:SetOwner(player)
    end
end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
function ARC:SpecificRules()
local moving = self.mode == ARC.kMode.Moving     
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
local inradius = (self.avocaarc and GetIsPointWithinChairRadius(self:GetOrigin())) or (self.siegearc and GetIsPointWithinHiveRadius(self:GetOrigin()) ) or CheckForAndActAccordingly(self)  
local shouldstop = false
local shouldmove = not shouldstop and not moving and not inradius
local shouldstop = moving and shouldstop
local shouldattack = inradius and not attacking 
local shouldundeploy = attacking and not inradius and not moving
  
  if moving then
    
    if shouldstop or shouldattack then 
           FindNewParent(self)
       --Print("StopOrder")
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
      
         GiveUnDeploy(self)
       else 
          if self.avocaarc then MoveToRandomChair(self) end
          if self.siegearc then MoveToHives(self) end
       end
       
   elseif shouldattack then
   
     GiveDeploy(self)
    return true
    
 end
 
    end
end


end

local orig_ARC_GetTechButtons = ARC.GetTechButtons
function ARC:GetTechButtons(techId)


local origbuttons = orig_ARC_GetTechButtons(self, techId)
if not self:isa("ARCCredit") then origbuttons[9] = kTechId.Recycle end

return origbuttons

end
