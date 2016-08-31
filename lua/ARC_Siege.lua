/*
local orig_ARC_GetTechButtons = ARC.GetTechButtons
function ARC:GetTechButtons()


local origbuttons = {}
origbuttons = orig_ARC_GetTechButtons(self)
if not self:isa("ARCCredit") then  origbuttons[9] = kTechId.Recycle end

return origbuttons

end
*/