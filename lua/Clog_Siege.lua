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




local originit = Clog.PreOnKill
function Clog:PreOnKill(attacker, doer, point, direction)
    --for i = 1, 8 do
     --Print("Clog on kill")
    --end
    // trigger receed
 if self:isa("ClogMod") then
    self:SetDesiredInfestationRadius(0)
    
      for _, structure in ipairs(GetEntitiesWithMixinForTeamWithinRange("InfestationTracker", 1, self:GetOrigin(), 8)) do
      structure:AddTimedCallback(function() structure:SetGameEffectMask(kGameEffect.OnInfestation, false) end, 4)
      end
      
      end
      
      if Server and originit ~= nil  then originit(self, attacker, doer, point, direction) end
end

Shared.LinkClassToMap("ClogMod", ClogMod.kMapName, networkVars)