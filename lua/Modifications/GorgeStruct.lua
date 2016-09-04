local kGorgeStructMaterial = PrecacheAsset("cinematics/vfx_materials/mucousshield.material")


Script.Load("lua/Crag.lua")
class 'GorgeCrag' (Crag)
GorgeCrag.kMapName = "gorgecrag"

function GorgeCrag:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Crag
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

if Client then

    function GorgeCrag:OnUpdateRender()
          local showMaterial = true
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kGorgeStructMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client

function GorgeCrag:OnOverrideOrder(order)

    local orderType = order:GetType()
    if orderType == kTechId.Move then return  end
end
function GorgeCrag:GetTechButtons()

return {}
end

Shared.LinkClassToMap("GorgeCrag", GorgeCrag.kMapName, networkVars)

Script.Load("lua/Whip.lua")
class 'GorgeWhip' (Whip)
GorgeWhip.kMapName = "gorgewhip"

function GorgeWhip:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Whip
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end


if Client then

    function GorgeWhip:OnUpdateRender()
          local showMaterial = true
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kGorgeStructMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client


function GorgeWhip:OnOverrideOrder(order)

    local orderType = order:GetType()
    if orderType == kTechId.Move then return  end
end
function GorgeWhip:GetTechButtons()

return {}
end

Shared.LinkClassToMap("GorgeWhip", GorgeWhip.kMapName, networkVars)

Script.Load("lua/Shift.lua")
class 'GorgeShift' (Shift)
GorgeShift.kMapName = "gorgeshift"


function GorgeShift:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shift
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end



if Client then

    function GorgeShift:OnUpdateRender()
          local showMaterial = true
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kGorgeStructMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client


function GorgeShift:OnOverrideOrder(order)

    local orderType = order:GetType()
    if orderType == kTechId.Move then return  end
end
function GorgeShift:GetTechButtons()

return {}
end

Shared.LinkClassToMap("GorgeShift", GorgeShift.kMapName, networkVars)

Script.Load("lua/Shade.lua")
class 'GorgeShade' (Shade)
GorgeShade.kMapName = "gorgeshade"



function GorgeShade:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shade
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

if Client then

    function GorgeShade:OnUpdateRender()
          local showMaterial = true
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kGorgeStructMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client


Shared.LinkClassToMap("GorgeShade", GorgeShade.kMapName, networkVars)
