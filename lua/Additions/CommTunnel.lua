--Kyle 'Avoca' Abent -- though basically just a shell --- oblitrators idea i just wrote out ;)
Script.Load("lua/TunnelEntrance.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/AlienStructureMoveMixin.lua")

class 'CommTunnel' (TunnelEntrance)

CommTunnel.kMapName = "commtunnel"




local networkVars = { }

AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)

function CommTunnel:OnCreate()
TunnelEntrance.OnCreate(self)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = Whip.kWalkingSound })
end
function CommTunnel:GetMaxSpeed()
    return kAlienStructureMoveSpeed
end
function CommTunnel:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.TunnelEntrance
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function CommTunnel:GetTechButtons(techId)
    local techButtons = nil
    
        techButtons = { kTechId.Move, kTechId.None, kTechId.None, kTechId.None,  
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }
                    
      if self.moving then
      techButtons[2] = kTechId.Stop
      end
    
    return techButtons
end

if Server then
function CommTunnel:OnOverrideOrder(order)
    if order:GetType() == kTechId.Default or order:GetType() == kTechId.Move then
             order:SetType(kTechId.Move)
             self:SetInfestationRadius(0)
    elseif order:GetType() == kTechId.Stop then
             order:SetType(kTechId.Stop)
             self:SetInfestationRadius(0)
    end
             
end
    function CommTunnel:UpdateConnectedTunnel()

  if hasValidTunnel or self:GetOwnerClientId() == nil or not self:GetIsBuilt() then
            return
        end

        // register if a tunnel entity already exists or a free tunnel has been found
        for index, tunnel in ientitylist( Shared.GetEntitiesWithClassname("Tunnel") ) do
        
            if tunnel:GetOwnerClientId() == self:GetOwnerClientId() or tunnel:GetOwnerClientId() == nil then
                
                tunnel:AddExit(self)
                self.tunnelId = tunnel:GetId()
                tunnel:SetOwnerClientId(self:GetOwnerClientId())
                return
                
            end
            
        end
        
        // no tunnel entity present, check if there is another tunnel entrance to connect with
        local tunnel = CreateEntity(Tunnel.kMapName, nil, self:GetTeamNumber())
        tunnel:SetOwnerClientId(self:GetOwnerClientId()) 
        tunnel:AddExit(self)
        self.tunnelId = tunnel:GetId()

    end
    
  end
Shared.LinkClassToMap("CommTunnel", CommTunnel.kMapName, networkVars)