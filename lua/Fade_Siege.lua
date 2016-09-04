function Fade:GetCanMetabolizeHealth()
    return GetHasTech(self, kTechId.MetabolizeHealth)
end
if Server then
function Fade:GetTierOneTechId()
    return kTechId.MetabolizeEnergy
end

function Fade:GetTierTwoTechId()
    return kTechId.MetabolizeHealth
end

function Fade:GetTierThreeTechId()
    return kTechId.Stab
end

function Fade:GetTierFourTechId()
    return  kTechId.FadeWall
end

end


--overwrite to test


local kBlinkAcceleration = 50
local kBlinkAddAcceleration = 4 -- LOLNO but lets see
local kBlinkSpeed = 17 -- lolno but lets see

function Fade:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsBlinking() then
    
        local wishDir = self:GetViewCoords().zAxis
        local maxSpeedTable = { maxSpeed = kBlinkSpeed }
        self:ModifyMaxSpeed(maxSpeedTable, input)  
        local prevSpeed = velocity:GetLength()
        local maxSpeed = math.max(prevSpeed, maxSpeedTable.maxSpeed)
        local maxSpeed = math.min(25, maxSpeed)    
        
        velocity:Add(wishDir * kBlinkAcceleration * deltaTime)
        
        if velocity:GetLength() > maxSpeed then

            velocity:Normalize()
            velocity:Scale(maxSpeed)
            
        end 
        
        -- additional acceleration when holding down blink to exceed max speed
        velocity:Add(wishDir * kBlinkAddAcceleration * deltaTime)
        
    end

end