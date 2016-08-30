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
       local mod = CreateEntity(ClogMod.kMapName, self:GetOrigin(), 2) 
       local owner = self:GetOwner()
       if owner ~= nil then mod:SetOwner(owner) owner:GetTeam():UpdateClientOwnedStructures(self:GetId()) owner:GetTeam():AddGorgeStructure(owner, mod)   end 
       DestroyEntity(self) end , .5)
    end
end
function ClogMod:OnInitialized()
     originit(self)
  InitMixin(self, InfestationMixin)
end
function ClogMod:GetTechId()
return kTechId.Clog
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
    
      for _, structure in ipairs( GetEntitiesWithMixinWithinRange("InfestationTracker", self:GetOrigin(), 8)) do
      structure:AddTimedCallback(function() structure:SetGameEffectMask(kGameEffect.OnInfestation, false) end, 4)
      end
      
      end
      
      if Server and originit ~= nil  then originit(self, attacker, doer, point, direction) end
end

Shared.LinkClassToMap("ClogMod", ClogMod.kMapName, networkVars)