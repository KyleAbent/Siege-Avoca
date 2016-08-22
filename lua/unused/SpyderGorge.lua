class 'SpyderGorge' (Gorge)
SpyderGorge.kMapName = "spydergorge"

Script.Load("lua/WallMovementMixin.lua")


local networkVars =
{
wallWalking = "compensated boolean",
timeLastWallWalkCheck = "private compensated time",
}

local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3
local kJumpWallRange = 0.4
local kJumpWallFeelerSize = 0.1
local kWallJumpInterval = 0.4
local kWallJumpForce = 5.2 // scales down the faster you are
local kMinWallJumpForce = 0.1
local kVerticalWallJumpForce = 4.3

local origgorge = Gorge.OnInitialized
function Gorge:OnInitialized()
 Print("Derpdsdsdsds")
  origgorge(self)
    if not self:isa("SpyderGorge") then
    self:AddTimedCallback( function () if Server and self then self:Replace(SpyderGorge.kMapName)  return false end end, 1)
    end
end
function SpyderGorge:OnCreate()
Gorge.OnCreate(self)
InitMixin(self, WallMovementMixin)
end
function SpyderGorge:GetClassName()
return "Gorge"
end

function SpyderGorge:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Gorge
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end


function SpyderGorge:OnCreate()
Gorge.OnCreate(self)
InitMixin(self, WallMovementMixin)
end

function SpyderGorge:OnInitialized()
Gorge.OnInitialized(self)
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    self.wallWalking = false
self.wallWalkingNormalGoal = Vector.yAxis
 self.timeLastWallJump = 0
end
function SpyderGorge:GetCanJump()
    local canWallJump = self:GetCanWallJump()
    return self:GetIsOnGround() or canWallJump
end
function SpyderGorge:GetIsWallWalking()
    return self.wallWalking
end
function SpyderGorge:GetIsWallWalkingPossible() 
    return not self:GetRecentlyJumped() and not self:GetCrouching()
end
local function PredictGoal(self, velocity)

    PROFILE("Gorge:PredictGoal")

    local goal = self.wallWalkingNormalGoal
    if velocity:GetLength() > 1 and not self:GetIsOnSurface() then

        local movementDir = GetNormalizedVector(velocity)
        local trace = Shared.TraceCapsule(self:GetOrigin(), movementDir * 2.5, Skulk.kXExtents, 0, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))

        if trace.fraction < 1 and not trace.entity then
            goal = trace.normal    
        end

    end

    return goal

end
local function UpdateGorgeSliding(self, input)

    PROFILE("Gorge:UpdateGorgeSliding")
    
    local slidingDesired = GetIsSlidingDesired(self, input)
    if slidingDesired and not self.sliding and self:GetIsOnGround() and not self:GetIsOnLadder() and self:GetEnergy() >= kBellySlideCost and not self:GetIsWallWalking() then
    
        self.sliding = true
        self.startedSliding = true
        
        if Server then
            if (GetHasSilenceUpgrade(self) and ConditionalValue(self.RTDSilence == true, 3, GetVeilLevel(self:GetTeamNumber())) == 0) or not GetHasSilenceUpgrade(self) then
                self.slideLoopSound:Start()
            end
        end
        
        self:DeductAbilityEnergy(kBellySlideCost)
        self:PrimaryAttackEnd()
        self:SecondaryAttackEnd()
        
    end
    
    if not slidingDesired and self.sliding then
    
        self.sliding = false
        
        if Server then
            self.slideLoopSound:Stop()
        end
        
        self.timeSlideEnd = Shared.GetTime()
    
    end

    // Have Gorge lean into turns depending on input. He leans more at higher rates of speed.
    if self:GetIsBellySliding() then

        local desiredBellyYaw = 2 * (-input.move.x / kSlidingMoveInputScalar) * (self:GetVelocity():GetLength() / self:GetMaxSpeed())
        self.bellyYaw = Slerp(self.bellyYaw, desiredBellyYaw, input.time * kGorgeLeanSpeed)
        
    end
    
end
function SpyderGorge:GetMaxSpeed(possible)
    if possible then return 6 end //* size end
    
    local maxspeed = 6
    if self:GetIsWallWalking() then
        maxspeed = maxspeed - 2
    end
    
    if self.movementModiferState then
        maxspeed = maxspeed * 0.5
    end
    
    return maxspeed //* size
    
end
function SpyderGorge:GetRecentlyWallJumped()
    return self.timeLastWallJump + kWallJumpInterval > Shared.GetTime()
end

function SpyderGorge:GetCanWallJump()

    local wallWalkNormal = self:GetAverageWallWalkingNormal(kJumpWallRange, kJumpWallFeelerSize)
    if wallWalkNormal and self:GetHasThreeHives() then
        return wallWalkNormal.y < 0.5
    end
    
    return false

end
function SpyderGorge:ModifyGravityForce(gravityTable)

    if self:GetIsWallWalking() and not self:GetCrouching() or self:GetIsOnGround() then
        gravityTable.gravity = 0
    end
    
end
function SpyderGorge:ModifyJump(input, velocity, jumpVelocity)

    if self:GetCanWallJump() then
    
        local direction = input.move.z == -1 and -1 or 1
    
        // we add the bonus in the direction the move is going
        local viewCoords = self:GetViewAngles():GetCoords()
        self.bonusVec = viewCoords.zAxis * direction
        self.bonusVec.y = 0
        self.bonusVec:Normalize()
        
        jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2

        local celerityMod = (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.4
        local currentSpeed = velocity:GetLengthXZ()
        local fraction = 1 - Clamp( currentSpeed / (11 + celerityMod), 0, 1)        
        
        local force = math.max(kMinWallJumpForce, (kWallJumpForce + celerityMod) * fraction)
          
        self.bonusVec:Scale(force)      

        if not self:GetRecentlyWallJumped() then
        
            self.bonusVec.y = viewCoords.zAxis.y * kVerticalWallJumpForce
            jumpVelocity:Add(self.bonusVec)

        end
        
        self.timeLastWallJump = Shared.GetTime()
        
    end
    
end
function SpyderGorge:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end
function SpyderGorge:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end
function SpyderGorge:GetDesiredAngles()

    local desiredAngles = Alien.GetDesiredAngles(self)
    
    if self:GetIsBellySliding() then
        desiredAngles.pitch = - self.verticalVelocity / 10 
        desiredAngles.roll = GetNormalizedVectorXZ(self:GetVelocity()):DotProduct(self:GetViewCoords().xAxis) * kMaxSlideRoll
    end
   if self:GetIsWallWalking() then return self.currentWallWalkingAngles end
       return desiredAngles
end
function SpyderGorge:GetHeadAngles()

    if self:GetIsWallWalking() then
        return self.currentWallWalkingAngles
    else
        return self:GetViewAngles()
    end

end
function SpyderGorge:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end

function SpyderGorge:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end
function SpyderGorge:OnJump()

    self.wallWalking = false

    local material = self:GetMaterialBelowPlayer()    
    local velocityLength = self:GetVelocity():GetLengthXZ()
    
    if velocityLength > 11 then
        self:TriggerEffects("jump_best", {surface = material})          
    elseif velocityLength > 8.5 then
        self:TriggerEffects("jump_good", {surface = material})       
    end

    self:TriggerEffects("jump", {surface = material})
    
end
function SpyderGorge:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Gorge:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5
    
end
function SpyderGorge:PreUpdateMove(input, runningPrediction)
    PROFILE("Gorge:PreUpdateMove")
    self.prevY = self:GetOrigin().y
        if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        // Most of the time, it returns a fraction of 0, which means
        // trace started outside the world (and no normal is returned)           
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize)
        if goal ~= nil and self:GetHasThreeHives() then //and not self:GetEnergy() < kWallWalkEnergyCost then 
        
            self.wallWalkingNormalGoal = goal
            self.wallWalking = true

        else
            self.wallWalking = false
        end
    
    end
    
    if not self:GetIsWallWalking() then
        // When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end

  //  if self.leaping and Shared.GetTime() > self.timeOfLeap + kLeapTime then
  //      self.leaping = false
  //  end
    
    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles


end
function SpyderGorge:GetMoveSpeedIs2D()
    return not self:GetIsWallWalking()
end
function SpyderGorge:GetCanStep()
    return not self:GetIsWallWalking()
end
Shared.LinkClassToMap("SpyderGorge", SpyderGorge.kMapName, networkVars)