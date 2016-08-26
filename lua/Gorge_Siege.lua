function Gorge:GetTierOneTechId()
    return kTechId.BileBomb
end





local kSlidingMoveInputScalar = 0.1
local kGorgeLeanSpeed = 2


local kStartSlideSpeed = 8.9

function Gorge:ModifyVelocity(input, velocity, deltaTime)
    
    -- Give a little push forward to make sliding useful
    if self.startedSliding then
    
       -- if self:GetIsOnGround() then
         velocity.y = velocity.y * 0.5 + 5
        
       -- end
        
        self.startedSliding = false

    end
    
    if self:GetIsBellySliding() then
    
  local flapForce = 4
                local move = Vector(input.move)
                move.x = move.x * 0.75
                -- flap only at 50% speed side wards
                
                local wishDir = self:GetViewCoords():TransformVector(move)
                wishDir:Normalize()

                -- the speed we already have in the new direction
                local currentSpeed = move:DotProduct(velocity)
                -- prevent exceeding max speed of kMaxSpeed by flapping
                local maxSpeedTable = { maxSpeed = 8 }
                self:ModifyMaxSpeed(maxSpeedTable, input)
                
                local maxSpeed = math.max(currentSpeed, maxSpeedTable.maxSpeed)
                
              --  if input.move.z ~= 1 and velocity.y < 0 then
                -- apply vertical flap
                    velocity.y = velocity.y * 0.5 + 3.8     
                --elseif input.move.z == 1 and input.move.x == 0 then
                    flapForce = 3 + flapForce + (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.3               
               -- elseif input.move.z == 0 and input.move.x ~= 0 then
                 --   velocity.y = velocity.y + 3.5
               -- end
                
                -- directional flap
                velocity:Scale(0.65)
                velocity:Add(wishDir * flapForce)
                
                if velocity:GetLength() > maxSpeed then
                    velocity:Normalize()
                    velocity:Scale(maxSpeed)
                end
                
 
            --self:DeductAbilityEnergy(kLerkFlapEnergyCost)
           -- self.lastTimeFlapped = Shared.GetTime()
            self.onGround = false
            --self:TriggerEffects("flap")

    end
    
end

local kMaxSlideRoll = math.rad(20)

function Gorge:GetDesiredAngles()

    local desiredAngles = Alien.GetDesiredAngles(self)
    /*
    if self:GetIsBellySliding() then
        desiredAngles.pitch = - self.verticalVelocity / 10 
        desiredAngles.roll = GetNormalizedVectorXZ(self:GetVelocity()):DotProduct(self:GetViewCoords().xAxis) * kMaxSlideRoll
    end
    */
    return desiredAngles

end

local kMaxSlidingSpeed = 13
function Gorge:PostUpdateMove(input, runningPrediction)
/*

*/

end
local function GetIsSlidingDesired(self, input)

    if bit.band(input.commands, Move.MovementModifier) == 0 then
        return false
    end
    
    if self.crouching then
        return false
    end
    
    if not self:GetHasMovementSpecial() then
        return false
    end
    
    --if self:GetVelocity():GetLengthXZ() < 3 or self:GetIsJumping() then
    
        if self:GetIsBellySliding() then    
            return false
        end 
           
    --else
        
     --   local zAxis = self:GetViewCoords().zAxis
     --   zAxis.y = 0
     --   zAxis:Normalize()
        
     --   if GetNormalizedVectorXZ(self:GetVelocity()):DotProduct( zAxis ) < 0.2 then
     --       return false
     --   end
    
    --end
    
    return true

end
-- Handle transitions between starting-sliding, sliding, and ending-sliding
local function UpdateGorgeSliding(self, input)

    PROFILE("Gorge:UpdateGorgeSliding")
    
    local slidingDesired = GetIsSlidingDesired(self, input)
    if slidingDesired and not self.sliding  and self:GetEnergy() >= kBellySlideCost  then
    
        self.sliding = true
        self.startedSliding = true
        
        if Server then
            if (GetHasSilenceUpgrade(self) and GetVeilLevel(self:GetTeamNumber()) == 0) or not GetHasSilenceUpgrade(self) then
                self.slideLoopSound:Start()
            end
        end
        
        self:DeductAbilityEnergy(kBellySlideCost * .10)
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

    -- Have Gorge lean into turns depending on input. He leans more at higher rates of speed.
    if self:GetIsBellySliding() then

        local desiredBellyYaw = 2 * (-input.move.x / kSlidingMoveInputScalar) * (self:GetVelocity():GetLength() / self:GetMaxSpeed())
        self.bellyYaw = Slerp(self.bellyYaw, desiredBellyYaw, input.time * kGorgeLeanSpeed)
        
    end
    
end

function Gorge:HandleButtons(input)

    PROFILE("Gorge:HandleButtons")
    
    Alien.HandleButtons(self, input)
    
    UpdateGorgeSliding(self, input)
    
end