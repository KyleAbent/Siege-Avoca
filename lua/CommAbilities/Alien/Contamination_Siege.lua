local function TimeUp(self)
    self:Kill()
    return false
end



function Contamination:OnInitialized()

    ScriptActor.OnInitialized(self)

    InitMixin(self, InfestationMixin)
    
    self:SetModel(Contamination.kModelName, kAnimationGraph)

    local coords = Angles(0, math.random() * 2 * math.pi, 0):GetCoords()
    coords.origin = self:GetOrigin()
    
    if Server then
             if not Shared.GetCheatsEnabled() then
               if not GetFrontDoorOpen() then 
               DestroyEntity(self)
               end
           end
        InitMixin( self, StaticTargetMixin )
        self:SetCoords( coords )
        
        self:AddTimedCallback( TimeUp, kContaminationLifeSpan )
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
       
        self.infestationDecal = CreateSimpleInfestationDecal(1, coords)
    
    end

end

--messy 9.13 to test. can optimize if fun gameplay, ya dig.
function Contamination:DelayActivation()
local tospawn = {}
      local  StructureBeacon = #GetEntitiesForTeam( "StructureBeacon", 2 )
      local  EggBeacon = #GetEntitiesForTeam( "EggBeacon", 2 )
      local CommVortex = #GetEntitiesForTeam( "CommVortex", 2 )
      local BoneWall = #GetEntitiesForTeam( "CommVortex", 2 )
      
if StructureBeacon < 1 and GetHasShiftHive() then table.insert(tospawn, kTechId.StructureBeacon) end

if EggBeacon < 1 and  GetHasCragHive() then table.insert(tospawn, kTechId.EggBeacon) end


if CommVortex < 1 and  GetHasShadeHive() then table.insert(tospawn, kTechId.CommVortex) end

if BoneWall < 1 then table.insert(tospawn, kTechId.BoneWall) end

local randomlychosen = table.random(tospawn)

if  table.count(tospawn) == 0 then return end

local cost = LookupTechData(randomlychosen, kTechDataCostKey)

if TresCheck(2, cost) then 

local entity = CreateEntityForTeam(randomlychosen, FindFreeSpace(self:GetOrigin(), 1, 8), 2)
 entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)

end

return self:GetIsAlive() and not self:GetIsDestroyed()

end
function Contamination:StartBeaconTimer()

self:AddTimedCallback(Contamination.DelayActivation, 4)

end

