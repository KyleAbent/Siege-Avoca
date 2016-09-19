--Kyle 'Avoca' Abent
class 'AvocaArc' (ARC)
AvocaArc.kMapName = "avocaarc"
local kNanoshieldMaterial = PrecacheAsset("cinematics/vfx_materials/nanoshield.material")
local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

function AvocaArc:OnCreate()
 ARC.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
  if Server then  self:LameFixATM() end
end

function AvocaArc:GetMaxHealth()
    return kARCHealth
end
function AvocaArc:GetMaxArmor()
    return kARCArmor
end

function ARC:GetShowDamageIndicator()
    return true
end
function AvocaArc:LameFixATM()
self:AddTimedCallback(AvocaArc.Check, 8)
end
function AvocaArc:Check()
  local gamestarted = false 
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if gamestarted then 
         local team1Commander = GetGamerules().team1:GetCommander()
     if team1Commander then ChangeArcTo(self, ARC.kMapName) end
    end
   return true
end
local function MoveToHives(who) --Closest hive from origin
local where = who:GetOrigin()
 local hive =  GetNearest(where, "Hive", 2, function(ent) return not ent:GetIsDestroyed() end)

 
               if hive then
        local origin = hive:GetOrigin() -- The arc should auto deploy beforehand
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

local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
function AvocaArc:SpecificRules()
local moving = self.mode == ARC.kMode.Moving     
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
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
       MoveToHives(self)
       end
       
   elseif shouldattack then
   
     GiveDeploy(self)
    return true
    
 end
 
    end
end
function AvocaArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

function AvocaArc:GetDamageType()
return kDamageType.StructuresOnly
end

function AvocaArc:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.ARC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
function AvocaArc:Waypoint()
    for _, marine in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 9999)) do
                     if  marine:GetClient():GetIsVirtual() and  marine:GetIsAlive() and not marine:isa("Commander") then
                     marine:GiveOrder(kTechId.Defend, self:GetId(), self:GetOrigin(), nil, true, true)
                     end
    end
    return true
end
function AvocaArc:Scan()
  if not GetIsPointWithinHiveRadius(self:GetOrigin()) then CreateEntity(Scan.kMapName, self:GetOrigin(), 1) end
    return true
end
function AvocaArc:Instruct()
   self:SpecificRules()
   return true
end




end



if Client then

    function AvocaArc:OnUpdateRender()
          local showMaterial = not self:GetInAttackMode()
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client


Shared.LinkClassToMap("AvocaArc", AvocaArc.kMapName, networkVars)