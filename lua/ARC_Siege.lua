Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")

local origcanfire = ARC.GetCanFireAtTarget

function ARC:GetCanFireAtTarget(target)

local boolean = origcanfire(self, target)

boolean = boolean and GetFrontDoorOpen() and not self:GetIsVortexed()

return boolean

end

/*
local orig_ARC_GetTechButtons = ARC.GetTechButtons
function ARC:GetTechButtons()


local origbuttons = {}
origbuttons = orig_ARC_GetTechButtons(self)
if not self:isa("ARCCredit") then  origbuttons[9] = kTechId.Recycle end

return origbuttons

end
*/