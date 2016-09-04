----local kLeapVerticalForce = 10.8
Skulk.kMaxSpeed = 9.0

local kLeapTime = 0.2
local kLeapForce = 9.5
local kLeapVerticalForce = 10.8
function Skulk:OnLeap()

    local velocity = self:GetVelocity() * 0.5
    local forwardVec = self:GetViewAngles():GetCoords().zAxis
    local newVelocity = velocity + GetNormalizedVectorXZ(forwardVec) * kLeapForce
    
    -- Add in vertical component.
    newVelocity.y = kLeapVerticalForce * forwardVec.y + kLeapVerticalForce * 0.5 + ConditionalValue(velocity.y < 0, velocity.y, 0)
    
    self:SetVelocity(newVelocity)
    
    self.leaping = true
    self.wallWalking = false
    self:DisableGroundMove(0.2)
    
    self.timeOfLeap = Shared.GetTime()
    
end