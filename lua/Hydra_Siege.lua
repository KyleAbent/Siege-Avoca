


Script.Load("lua/Additions/LevelsMixin.lua")

class 'HydraAvoca' (Hydra)
HydraAvoca.kMapName = "hydraavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)

    
local orighydra  = Hydra.OnInitialized
function Hydra:OnInitialized()
  orighydra(self)
  
      --    self.targetSelector = TargetSelector():Init(
      --          self,
      --          17.78 * (self.level/100) + 17.78, 
      --          true,
      --          { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) } )   
                
               --messy 
    if Server and not self:isa("HydraAvoca") then
    self:AddTimedCallback( function ()
       local hydra = CreateEntity(HydraAvoca.kMapName, self:GetOrigin(), 2) 
       local owner = self:GetOwner()
       if owner ~= nil then 
         hydra:SetAngles(self:GetAngles())
       hydra:SetOwner(owner) owner:GetTeam():UpdateClientOwnedStructures(self:GetId()) owner:GetTeam():AddGorgeStructure(owner, hydra)  
         end 
      if self:GetIsBuilt() then hydra:SetConstructionComplete() end
        DestroyEntity(self) end , .5)
    end

end

    function HydraAvoca:OnInitialized()
         Hydra.OnInitialized(self)
        InitMixin(self, LevelsMixin)
          self:AdjustMaxHealth(self:GetMaxHealth())
         self:AdjustMaxArmor(self:GetMaxArmor())
    end
        function HydraAvoca:GetTechId()
         return kTechId.Hydra
    end
    function HydraAvoca:GetMaxHealth()
    return kHydraHealth
end
function HydraAvoca:GetMaxArmor()
    return kMatureHydraArmor
end
    function HydraAvoca:GetMaxLevel()
    return 30
    end
    function HydraAvoca:GetAddXPAmount()
    return 1
    end

function HydraAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Hydra
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function Hydra:GetLevelPercentage()
return self.level / self:GetMaxLevel() * 2
end
function Hydra:GetMaxLevel()
return 30
end
function HydraAvoca:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end

Shared.LinkClassToMap("HydraAvoca", HydraAvoca.kMapName, networkVars)
