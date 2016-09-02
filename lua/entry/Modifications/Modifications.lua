kMaxTeamResources = 999
kMaxResources = 999


Script.Load("lua/Modifications/FrontDoorOpenConvars.lua")
Script.Load("lua/Modifications/PreGameConvars.lua")
Script.Load("lua/Modifications/RoundStartConvars.lua")
Script.Load("lua/Modifications/WelderMod.lua")
Script.Load("lua/Modifications/CustomLightRules.lua")
Script.Load("lua/Modifications/FastBuildSpeed.lua")


SetCachedTechData(kTechId.Hydra, kTechDataMapName, HydraAvoca.kMapName)
SetCachedTechData(kTechId.Sentry, kTechDataMapName, SentryAvoca.kMapName)
SetCachedTechData(kTechId.Crag, kTechDataMapName, CragAvoca.kMapName)
SetCachedTechData(kTechId.ArmsLab, kTechDataMapName, ArmsLabAvoca.kMapName)
SetCachedTechData(kTechId.Armory, kTechDataMapName, ArmoryAvoca.kMapName)
SetCachedTechData(kTechId.PhaseGate, kTechDataMapName, PhaseGateAvoca.kMapName)
SetCachedTechData(kTechId.PrototypeLab, kTechDataMapName, PrototypeLabAvoca.kMapName)
SetCachedTechData(kTechId.Observatory, kTechDataMapName, ObservatoryAvoca.kMapName)
SetCachedTechData(kTechId.Shift, kTechDataMapName, ShiftAvoca.kMapName)
SetCachedTechData(kTechId.Shade, kTechDataMapName,ShadeAvoca.kMapName)
SetCachedTechData(kTechId.Whip, kTechDataMapName,WhipAvoca.kMapName)
SetCachedTechData(kTechId.RoboticsFactory, kTechDataMapName,RoboticsFactory.kMapName)

function LeapMixin:GetHasSecondary(player)
    return GetHasTech(player, kTechId.Leap)
end
function StompMixin:GetHasSecondary(player)
    return  GetHasTech(player, kTechId.Stomp)
end
function AchievementReceiverMixin:OnUpdatePlayer(deltaTime)
 return -- I cringed when this was introduced. Thinking of the Perf onupdate tick whatever you wanna call it. No place for Siege, mate.
end







   local function GetMaxDistanceFor(player)
    
        if player:isa("AlienCommander") then
            return 63
        end

        return 33
    
    end
if Client then
 function HiveVisionMixin:OnUpdate(deltaTime)   
        PROFILE("HiveVisionMixin:OnUpdate")
        // Determine if the entity should be visible on hive sight
        local visible = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
        local player = Client.GetLocalPlayer()
        local now = Shared.GetTime()
        
       if   ( self:isa("SiegeDoor") and self:GetIsLocked() ) then
        visible = true
        end
        
        if Client.GetLocalClientTeamNumber() == kSpectatorIndex
              and self:isa("Alien") 
              and Client.GetOutlinePlayers()
              and not self.hiveSightVisible then

            local model = self:GetRenderModel()
            if model ~= nil then
            
                HiveVision_AddModel( model )
                   
                self.hiveSightVisible = true    
                self.timeHiveVisionChanged = now
                
            end
        
        end
        
        // check the distance here as well. seems that the render mask is not correct for newly created models or models which get destroyed in the same frame
        local playerCanSeeHiveVision = player ~= nil and (player:GetOrigin() - self:GetOrigin()):GetLength() <= GetMaxDistanceFor(player) and (player:isa("Alien") or player:isa("AlienCommander") or player:isa("AlienSpectator"))

        if not visible and playerCanSeeHiveVision and self:isa("Player") then
        
            // Make friendly players always show up - even if not obscured     
            visible = player ~= self and GetAreFriends(self, player)
            
        end
        
        if visible and not playerCanSeeHiveVision then
            visible = false
        end
        
        // Update the visibility status.
        if visible ~= self.hiveSightVisible and self.timeHiveVisionChanged + 1 < now then
        
            local model = self:GetRenderModel()
            if model ~= nil then
            
                if visible then
                    HiveVision_AddModel( model )
                    //DebugPrint("%s add model", self:GetClassName())
                else
                    HiveVision_RemoveModel( model )
                    //DebugPrint("%s remove model", self:GetClassName())
                end 
                   
                self.hiveSightVisible = visible    
                self.timeHiveVisionChanged = now
                
            end
            
        end
            
    end
end



 if Client then
function MarineOutlineMixin:OnUpdate(deltaTime)   
        PROFILE("MarineOutlineMixin:OnUpdate")
        local player = Client.GetLocalPlayer()
        
        local model = self:GetRenderModel()
        if model ~= nil then 
        
            local outlineModel = Client.GetOutlinePlayers() and 
                                    ( ( Client.GetLocalClientTeamNumber() == kSpectatorIndex ) or 
                                      ( player:isa("MarineCommander") and self.catpackboost ) )
                                                            or
                               ( self:isa("SiegeDoor") and self:GetIsLocked() )
                                    
            local outlineColor
            if self.catpackboost then
                outlineColor = kEquipmentOutlineColor.Fuchsia
            elseif HasMixin(self, "ParasiteAble") and self:GetIsParasited() then
                outlineColor = kEquipmentOutlineColor.Yellow
            else
                outlineColor = kEquipmentOutlineColor.TSFBlue
            end

            if outlineModel ~= self.marineOutlineVisible or outlineColor ~= self.marineOutlineColor then

                EquipmentOutline_RemoveModel( model )
                if outlineModel then
                    EquipmentOutline_AddModel( model, outlineColor )
                    self.marineOutlineColor = outlineColor
                end

                self.marineOutlineVisible = outlineModel
            end

        end
            
    end


end

local function CorrodeOnInfestation(self)

    if self:GetMaxArmor() == 0 then
        return false
    end

    if self.updateInitialInfestationCorrodeState and GetIsPointOnInfestation(self:GetOrigin()) then
    
        self:SetGameEffectMask(kGameEffect.OnInfestation, true)
        self.updateInitialInfestationCorrodeState = false
        
    end

    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self:GetCanTakeDamage() and (not HasMixin(self, "GhostStructure") or not self:GetIsGhostStructure()) then
        
        self:SetCorroded()
        
        if self:isa("PowerPoint") and self:GetArmor() == 0 then
            self:DoDamageLighting()
        end
        
        if not self:isa("PowerPoint") or self:GetArmor() > 0 then 
            -- stop damaging power nodes when armor reaches 0... gets annoying otherwise.
            self:DeductHealth(kInfestationCorrodeDamagePerSecond, nil, nil, false, true, true)
        end
        
        if not self:isa("PowerPoint") and self:GetArmor() == 0 and not self:isa("ARC")  and GetIsRoomPowerDown(self) then
           local damage = kInfestationCorrodeDamagePerSecond * 4
                    self:DeductHealth(damage, nil, nil, true, false, true)
        end
        
    end

    return true

end

function CorrodeMixin:__initmixin()

    if Server then
        
        self.isCorroded = false
        self.timeCorrodeStarted = 0
        
        if not self:isa("Player") and not self:isa("MAC") and not self:isa("Exosuit") and kCorrodeMarineStructureArmorOnInfestation then
        
            self:AddTimedCallback(CorrodeOnInfestation, 1)
            self.updateInitialInfestationCorrodeState = true
            
        end
        
    end
    
end

/*
function JetpackMarine:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsJetpacking() then
        
        local verticalAccel = 44
        
        if self:GetIsWebbed() then
            verticalAccel = 5
        elseif input.move:GetLength() == 0 then
            verticalAccel = 56
        end
    
        self.onGround = false
        local thrust = math.max(0, -velocity.y) / 12
        velocity.y = math.min(5, velocity.y + verticalAccel * deltaTime * (1 + thrust * 5))
 
    end
    
    if not self.onGround then
    
        -- do XZ acceleration
        local prevXZSpeed = velocity:GetLengthXZ()
        local maxSpeedTable = { maxSpeed = math.max(kFlySpeed, prevXZSpeed) }
        self:ModifyMaxSpeed(maxSpeedTable)
        local maxSpeed = maxSpeedTable.maxSpeed        
        
        if not self:GetIsJetpacking() then
            maxSpeed = prevXZSpeed
        end
        
        local wishDir = self:GetViewCoords():TransformVector(input.move)
        local acceleration = 0
        wishDir.y = 0
        wishDir:Normalize()
        
        acceleration = kFlyAcceleration
        
        velocity:Add(wishDir * acceleration * self:GetInventorySpeedScalar() * deltaTime)

        if velocity:GetLengthXZ() > maxSpeed then
        
            local yVel = velocity.y
            velocity.y = 0
            velocity:Normalize()
            velocity:Scale(maxSpeed)
            velocity.y = yVel
            
        end 
        
        if self:GetIsJetpacking() then
            velocity:Add(wishDir * kJetpackingAccel * deltaTime)
        end
    
    end

end
*/

/*
function SupplyUserMixin:__initmixin()
    
    assert(Server)    
    
    local team = self:GetTeam()
    if team and team.AddSupplyUsed then
        local supply = LookupTechData(self:GetTechId(), kTechDataSupply, 0)
        team:AddSupplyUsed(supply)
        Print("%s adding supply of %s", self:GetClassName(), supply)
        self.supplyAdded = true   
 
    end
    
end

local function RemoveSupply(self)

    if self.supplyAdded then
        
        local team = self:GetTeam()
        if team and team.RemoveSupplyUsed then
        local supply = LookupTechData(self:GetTechId(), kTechDataSupply, 0)
        team:RemoveSupplyUsed(supply)     
            Print("%s removing supply of %s", self:GetClassName(), supply)
            self.supplyAdded = false
            
        end
        
    end
    
end

function SupplyUserMixin:OnKill()
    RemoveSupply(self)
end

function SupplyUserMixin:OnDestroy()
    RemoveSupply(self)
end
*/














