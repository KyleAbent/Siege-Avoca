class 'LerkMod' (Lerk)
LerkMod.kMapName = "lerkmod"


Script.Load("lua/Additions/PrimalScream.lua") --thanks ns2c/dragon


local networkVars =
{

}

local origlerk  = Lerk.OnInitialized
function Lerk:OnInitialized()
  origlerk(self)
    if not self:isa("LerkMod") then
    self:AddTimedCallback( function () if Server and self then self:Replace(LerkMod.kMapName)  return false end end, 1)
    end
end
function Lerk:GetClassName()
return "Lerk"
end
function LerkMod:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Lerk
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("LerkMod", LerkMod.kMapName, networkVars)