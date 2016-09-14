--Kyle 'Avoca' Abent -- though basically just a spur --- goes well with egg beacon :)
Script.Load("lua/Spur.lua")
class 'StructureBeacon' (Spur)

StructureBeacon.kMapName = "structurebeacon"

local kLifeSpan = 12

local networkVars = { }

local function TimeUp(self)

    self:Kill()
    return false

end
function Spur:GetMinRangeAC()
return  9999   
end
local function GetIsACreditStructure(who)
local boolean = HasMixin(who, "Avoca") and who:GetIsACreditStructure()  or false
--Print("isacredit structure is %s", boolean)
return boolean

end
function StructureBeacon:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Spur
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then

    function StructureBeacon:OnConstructionComplete()
        self:AddTimedCallback(TimeUp, kLifeSpan + 0.5)  
        self:TeleportFractionHere()
         self:AddTimedCallback(StructureBeacon.TeleportFractionHere, 2)
    end
    function StructureBeacon:TeleportFractionHere()
      local eligable = {}
      local entity = GetEntitiesWithMixinForTeam( "Supply", 2 )
      
      for i = 1, #entity do
         local structure = entity[i]
         local distance = self:GetDistance(structure)
         local locationsmatch = GetLocationForPoint(self:GetOrigin()) ==  GetLocationForPoint(structure:GetOrigin()) 
           local restrictions = (not locationsmatch or distance >= 8) and not structure:isa("Drifter") and not structure:isa("DrifterEgg") and not  ( structure.GetIsMoving and structure:GetIsMoving()  and not GetIsACreditStructure(structure) )
            if restrictions then
                       if locationsmatch and self:GetDistance(structure) >= 12 or
                        not locationsmatch and self:GetDistance(structure) <= 25 then 
                         structure:ClearOrders()
                         structure:GiveOrder(kTechId.Move, self:GetId(), self:GetOrigin(), nil, true, true) 
                         break
                       end
                       
                       
                       if distance >= 26 and structure:GetIsBuilt() then
                       if self:GetDistance(structure) >= 26 and structure:GetIsBuilt() then
                          if HasMixin(entity, "Obstacle") then  entity:RemoveFromMesh()end
                         structure:SetOrigin(FindFreeSpace(self:GetOrigin(), .5, 7))
                             if HasMixin(structure, "Obstacle") then
                                     if structure.obstacleId == -1 then structure:AddToMesh() end
                             end
                             
                             break
                       end 
                       end //
                       
                       
            end
      end
return true
  end
  
         function StructureBeacon:OnDestroy()
        ScriptActor.OnDestroy(self)
         end 
end //
Shared.LinkClassToMap("StructureBeacon", StructureBeacon.kMapName, networkVars)