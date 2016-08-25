
local orig_Marine_OnCreate = Marine.OnCreate
function Marine:OnCreate()
    orig_Marine_OnCreate(self)
    if Server then
    elseif Client then
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
end