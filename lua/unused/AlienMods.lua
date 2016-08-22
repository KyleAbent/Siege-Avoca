class 'AlienMod' (Alien)
AlienMod.kMapName = "alienmod"


local networkVars = 
{
 primaled = "boolean",
}



local origalien  = Alien.OnInitialized
function Alien:OnInitialized()
 -- origalien(self)
    if not self:isa("AlienMod") then
    self:AddTimedCallback( function () if Server and self then self:Replace(AlienMod.kMapName)  return false end end, .5)
    end

end

function AlienMod:OnInitialized()
    Alien.OnInitialized(self)
    self.primaled = false
end
local function CheckPrimalScream(self)
	self.primaled = self.primalGiveTime - Shared.GetTime() > 0
	return self.primaled
end
function AlienMod:GetCanPhase()
    return self:isa("Fade") and self:GetIsAlive() and Shared.GetTime() > self.timeOfLastPhase + 2
end
if Server then

    function AlienMod:PrimalScream(duration)
        if not self.primaled then
			self:AddTimedCallback(CheckPrimalScream, duration)
		end
        self.primaled = true
        self.primalGiveTime = Shared.GetTime() + duration
    end

end
function AlienMod:GetHasPrimalScream()
    return self.primaled
end
function AlienMod:CancelPrimal()

    if self.primalGiveTime > Shared.GetTime() or self:GetIsOnFire() then 
        self.primalGiveTime = Shared.GetTime()
        self.primaledID = Entity.invalidI
    end
    
end
function AlienMod:OnUpdateAnimationInput(modelMixin)
    Alien.OnUpdateAnimationInput(self, modelMixin)
    local scale = 1
  //  if self.modelsize > 1 then scale = self.modelsize end
    local attackSpeed = self:GetIsEnzymed() and kEnzymeAttackSpeed or kDefaultAttackSpeed
    attackSpeed = attackSpeed + ( self:GetHasPrimalScream() and kPrimalScreamROFIncrease or 0)
     
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeed * attackSpeedTable.attackSpeed
        
    end
    
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
    
end
Shared.LinkClassToMap("AlienMod", AlienMod.kMapName, networkVars)