local kGorgeStructMaterial = PrecacheAsset("cinematics/vfx_materials/mucousshield.material")


Script.Load("lua/Crag.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")



class 'GorgeCrag' (Crag)
GorgeCrag.kMapName = "gorgecrag"

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)

function GorgeCrag:PreOnKill(attacker, doer, point, direction)
    self:SetDesiredInfestationRadius(0)
    
      for _, structure in ipairs( GetEntitiesWithMixinWithinRange("InfestationTracker", self:GetOrigin(), 8)) do
      structure:AddTimedCallback(function() structure:SetGameEffectMask(kGameEffect.OnInfestation, false) end, 1)
      end
      
      
end
    function GorgeCrag:OnInitialized()
         Crag.OnInitialized(self)
        InitMixin(self, AvocaMixin)
          InitMixin(self, InfestationMixin)
                self.isacreditstructure = true
    end
    function GorgeCrag:GetInfestationRadius()
  return 1
end
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

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
    function GorgeWhip:OnInitialized()
         Whip.OnInitialized(self)
        InitMixin(self, AvocaMixin)
          InitMixin(self, InfestationMixin)
                self.isacreditstructure = true
    end
    function GorgeWhip:PreOnKill(attacker, doer, point, direction)
    self:SetDesiredInfestationRadius(0)
    
      for _, structure in ipairs( GetEntitiesWithMixinWithinRange("InfestationTracker", self:GetOrigin(), 8)) do
      structure:AddTimedCallback(function() structure:SetGameEffectMask(kGameEffect.OnInfestation, false) end, 1)
      end
      
      
end
 function GorgeWhip:GetInfestationRadius()
  return 1
end
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


local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
 function GorgeShift:GetInfestationRadius()
  return 1
end
    function GorgeShift:PreOnKill(attacker, doer, point, direction)
    self:SetDesiredInfestationRadius(0)
    
      for _, structure in ipairs( GetEntitiesWithMixinWithinRange("InfestationTracker", self:GetOrigin(), 8)) do
      structure:AddTimedCallback(function() structure:SetGameEffectMask(kGameEffect.OnInfestation, false) end, 1)
      end
      
      
end
    function GorgeShift:OnInitialized()
         Shift.OnInitialized(self)
        InitMixin(self, AvocaMixin)
          InitMixin(self, InfestationMixin)
                self.isacreditstructure = true
    end
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

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
 function GorgeShade:GetInfestationRadius()
  return 1
end
    function GorgeShade:PreOnKill(attacker, doer, point, direction)
    self:SetDesiredInfestationRadius(0)
    
      for _, structure in ipairs( GetEntitiesWithMixinWithinRange("InfestationTracker", self:GetOrigin(), 8)) do
      structure:AddTimedCallback(function() structure:SetGameEffectMask(kGameEffect.OnInfestation, false) end, 1)
      end
      
      
end
    function GorgeShade:OnInitialized()
     Shade.OnInitialized(self)
        InitMixin(self, AvocaMixin)
          InitMixin(self, InfestationMixin)
        self.isacreditstructure = true
    end
    
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
