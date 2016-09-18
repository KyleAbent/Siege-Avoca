-- Kyle 'Avoca' Abent
PrecacheAsset("materials/power/powered_decal.surface_shader")
local kAirLockMaterial = PrecacheAsset("materials/power/powered_decal.material")


local networkVars =
{
airlock = "boolean" 
}
local originit = Location.OnInitialized
function Location:OnInitialized()
originit(self)
self.airlock = false
end
local function IsPowerUp(self)
 local powerpoint = GetPowerPointForLocation(self.name)

   local boolean = false
 if powerpoint and not powerpoint:GetIsDisabled() then boolean = true end
  -- Print("IsPowerUp in %s is %s", self.name, boolean)
 return boolean 
end


function Location:GetIsPowerUp()
return IsPowerUp(self)
end
function Location:GetRandomMarine()

local lottery = {}
     for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 1, self:GetOrigin(), 24)) do
     
         local location = GetLocationForPoint(unit:GetOrigin())
         if location and location.name == self.name then
              table.insert(lottery, unit)
         end
     end
     
     if table.count(lottery) ~= 0 then
        local entity = table.random(lottery)
        return entity:GetOrigin()
     end
     
     return nil
end
local function GetCanSpawn(self)
          for _, conductor in ientitylist(Shared.GetEntitiesWithClassname("Conductor")) do
            return not conductor:CounterComplete()
          end
          return true
end
function Location:GetIsAirLock()
     return self.airlock
end


if Server then
function Location:GetRandomMarine()
--Because when round starts, room is empty. Have marine in room first to tell it to be eligable.
local lottery = {}
     for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 1, self:GetOrigin(), 24)) do
     
         local location = GetLocationForPoint(unit:GetOrigin())
         if location and location.name == self.name then
              table.insert(lottery, unit)
         end
     end
     
     if table.count(lottery) ~= 0 then
        local entity = table.random(lottery)
        return entity:GetOrigin()
     end
     
     return nil
end

local locorig = Location.OnTriggerEntered
 function Location:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
         locorig(self, entity, triggerEnt)
         
         if string.find(self.name, "siege") or string.find(self.name, "Siege") then
         ExploitCheck(entity)
         end
                 local powerPoint = GetPowerPointForLocation(self.name)
            if powerPoint ~= nil then
               if not powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then 
                    if entity:isa("Marine") and not entity:isa("Commander") then
                         powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)  
                         
                    if powerPoint:GetIsBuilt() and not powerPoint:GetIsDisabled() then
                     if not self.airlock then self.airlock = true end
                     end
                         
                         
                    end
                end
                
end
end

end

if Client then

    function Location:HideDank()
          --nevermind
    end
    
   
end

Shared.LinkClassToMap("Location", Location.kMapName, networkVars)
