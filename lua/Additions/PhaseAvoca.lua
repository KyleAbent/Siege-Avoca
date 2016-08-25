class 'PhaseAvoca' (PhaseGate)
PhaseAvoca.kMapName = "phaseavoca"


function PhaseAvoca:LameFixATM()
self:AddTimedCallback(PhaseAvoca.Check, 8)
end
function PhaseAvoca:Check()
  local gamestarted = false 
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   if gamestarted then DestroyEntity(self) end
   return false
end

function PhaseAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.PhaseGate
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
local function GetDestinationGate(self)
    local phaseGates = {} 
  -- Find next phase gate to teleport to
  
  if self:isa("PhaseAvoca") then  
  
    for index, payload  in ipairs( GetEntitiesForTeam("AvocaArc", self:GetTeamNumber()) ) do
        if GetIsUnitActive(payload) then
            return payload
        end
    end 
    
   end
   
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) and not phaseGate:isa("PhaseAvoca") then
            table.insert(phaseGates, phaseGate)
        end
    end    
    
    
     
    if table.count(phaseGates) < 2 then
        return nil
    end
    -- Find our index and add 1
    local index = table.find(phaseGates, self)
    if (index ~= nil) then
    
        local nextIndex = ConditionalValue(index == table.count(phaseGates), 1, index + 1)
        ASSERT(nextIndex >= 1)
        ASSERT(nextIndex <= table.count(phaseGates))
        return phaseGates[nextIndex]
        
    end
    
    return nil 
end

--So that we can teleport to the payload without having to run to it all the time :P
local function ComputeDestinationLocationId(self, destGate)

    local destLocationId = Entity.invalidId
    if destGate then
    
        local location = GetLocationForPoint(destGate:GetOrigin())
        if location then
            destLocationId = location:GetId()
        end
        
    end
    
    return destLocationId
    
end
if Server then
local orig_Phase_Update = PhaseGate.Update
    function PhaseGate:Update()
     if self:isa("PhaseAvoca") then
        self.phase = (self.timeOfLastPhase ~= nil) and (Shared.GetTime() < (self.timeOfLastPhase + 0.3))

        local destinationPhaseGate = GetDestinationGate(self)
        if destinationPhaseGate ~= nil and GetIsUnitActive(self) and self.deployed and (destinationPhaseGate.deployed or destinationPhaseGate:isa("ARC") ) then        
        
            self.destinationEndpoint = destinationPhaseGate:GetOrigin()
            self.linked = true
            self.targetYaw = destinationPhaseGate:GetAngles().yaw
            self.destLocationId = ComputeDestinationLocationId(self, destinationPhaseGate)
            
        else
            self.linked = false
            self.targetYaw = 0
            self.destLocationId = Entity.invalidId
        end
    
        return true
       else return orig_Phase_Update(self) end 
    end
end



Shared.LinkClassToMap("PhaseAvoca", PhaseAvoca.kMapName, networkVars)