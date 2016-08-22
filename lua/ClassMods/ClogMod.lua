Script.Load("lua/InfestationMixin.lua")

class 'ClogMod' (Clog)
ClogMod.kMapName = "clogmod"

local networkVars = {}
AddMixinNetworkVars(InfestationMixin, networkVars)

local originit = Clog.OnInitialized
function Clog:OnInitialized()
  originit(self)
    if Server and not self:isa("ClogMod") then
    self:AddTimedCallback( function ()
       CreateEntity(ClogMod.kMapName, self:GetOrigin(), 2) DestroyEntity(self) end , .5)
    end
end
function ClogMod:OnInitialized()
   Clog.OnInitialized(self)
  InitMixin(self, InfestationMixin)
end
function ClogMod:GetInfestationRadius()
  local frontdoor = GetEntitiesWithinRange("FrontDoor", self:GetOrigin(), 7)
   if #frontdoor >=1 then return 0
   else
    return 3.5
   end
end
function ClogMod:GetInfestationGrowthRate()
 return 0.5
end
function Clog:GetAttached()
return false
end
Shared.LinkClassToMap("ClogMod", ClogMod.kMapName, networkVars)