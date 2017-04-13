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


local origcreate = ARC.OnCreate

function ARC:OnCreate()
  origcreate(self)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    self.rollledout = false
end


 function ARC:OnOrderComplete(currentOrder)
    if not self:isa("AvocaArc") and not self:isa("SiegeArc") then
      self:GiveOrder(kTechId.ARCDeploy, self:GetId(), self:GetOrigin(), nil, true, true)
    end
  end

end

function ARC:GetIsDeployed()
return  self.deployMode == ARC.kDeployMode.Deployed
end
function ARC:SetDeployed()
GiveDeploy(self) 
end

local orig_ARC_GetTechButtons = ARC.GetTechButtons
function ARC:GetTechButtons(techId)


local origbuttons = orig_ARC_GetTechButtons(self, techId)
if not self:isa("ARCCredit") then origbuttons[9] = kTechId.Recycle end

return origbuttons

end
