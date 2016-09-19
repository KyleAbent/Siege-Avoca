Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")

local origcanfire = ARC.GetCanFireAtTarget


local networkVars =

 {
 rolledout  =  "boolean",
 
 }

AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)

function ARC:GetCanFireAtTarget(target)

local boolean = origcanfire(self, target)

boolean = boolean and GetFrontDoorOpen() and not self:GetIsVortexed()

return boolean

end
if Server then
function ARC:Instruct()
   self:SpecificRules()
   return true
end

local origcreate = ARC.OnCreate

function ARC:OnCreate()
  origcreate(self)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    self.rollledout = false
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
    if player then
    who:SetOwner(player)
    end
end
function ARC:GetIsDeployed()
return  self.deployMode == ARC.kDeployMode.Deployed
end
function ARC:SetDeployed()
GiveDeploy(self) 
end
function ARC:SpecificRules()
local moving = self.mode == ARC.kMode.Moving     
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
local inradius = GetIsPointWithinChairRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
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
       MoveToRandomChair(self)
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
