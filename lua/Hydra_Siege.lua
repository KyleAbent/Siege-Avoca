
class 'HydraAvoca' (Hydra)
HydraAvoca.kMapName = "hydraavoca"

local networkVars = {}

    
local orighydra  = Hydra.OnInitialized
function Hydra:OnInitialized()
  orighydra(self)
  
      --    self.targetSelector = TargetSelector():Init(
      --          self,
      --          17.78 * (self.level/100) + 17.78, 
      --          true,
      --          { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) } )   
                
               --messy 

end

    function HydraAvoca:OnInitialized()
         Hydra.OnInitialized(self)
         self:SetTechId(kTechId.Hydra)
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


Shared.LinkClassToMap("HydraAvoca", HydraAvoca.kMapName, networkVars)
