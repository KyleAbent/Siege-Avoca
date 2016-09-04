




function GetCheckShellLimit(techId, origin, normal, commander)
    local num = 0

        
        for index, shell in ientitylist(Shared.GetEntitiesWithClassname("Shell")) do
        
           -- if not spur:isa("StructureBeacon") then 
                num = num + 1
          --  end
            
    end
    
    return num < 4
    
end
function GetCheckVeilLimit(techId, origin, normal, commander)
    local num = 0

        
        for index, veil in ientitylist(Shared.GetEntitiesWithClassname("Veil")) do
        
           -- if not spur:isa("StructureBeacon") then 
                num = num + 1
          --  end
            
    end
    
    return num < 4
    
end
function GetCheckSpurLimit(techId, origin, normal, commander)
    local num = 0

        
        for index, spur in ientitylist(Shared.GetEntitiesWithClassname("Spur")) do
        
            if not spur:isa("StructureBeacon") then 
                num = num + 1
            end
            
    end
    
    return num < 4
    
end


local function GetIsACreditStructure(who)
local boolean = HasMixin(who, "Avoca") and who:GetIsACreditStructure()  or false
--Print("isacredit structure is %s", boolean)
return boolean

end

local function GetCheckArmsLabLimit()
    local num = 0

        
        for index, armslab in ientitylist(Shared.GetEntitiesWithClassname("ArmsLab")) do
        
                num = num + 1
            
    end
    
    return num < kArmsLabEntityLimit
end
local function GetCheckInfantryPortalLimit()
    local num = 0

        
        for index, infantryportal in ientitylist(Shared.GetEntitiesWithClassname("InfantryPortal")) do
               if not GetIsACreditStructure(infantryportal) then
                num = num + 1
                end
            
    end
    
    return num < kIPEntityLimit
end
local function GetCheckArmoryLimit()
    local num = 0

        
        for index, armory in ientitylist(Shared.GetEntitiesWithClassname("Armory")) do
        
               if not GetIsACreditStructure(armory) then
                num = num + 1
                end
            
            
    end
    
    return num < kArmoryEntityLimit
end
local function GetCheckPhaseGateLimit()
    local num = 0

        
        for index, phsaegate in ientitylist(Shared.GetEntitiesWithClassname("PhaseGate")) do
        
               if not GetIsACreditStructure(phsaegate) then
                num = num + 1
                end
            
    end
    
    return num < kPGEntityLimit
end
local function GetCheckObservatoryLimit()
    local num = 0

        
        for index, obs in ientitylist(Shared.GetEntitiesWithClassname("Observatory")) do
        
                num = num + 1
                
                if not GetIsACreditStructure(obs) then
                num = num + 1
                end
    end
    
    return num < kOBSEntityLimit
end
local function GetCheckRoboticsFactoryLimit()
    local num = 0

        
        for index, robo in ientitylist(Shared.GetEntitiesWithClassname("RoboticsFactory")) do
        
                num = num + 1
                
                if not GetIsACreditStructure(robo) then
                num = num + 1
                end
    end
    
    return num < kRoboEntityLimit
end
local function GetCheckPrototypeLabLimit()
    local num = 0

        
        for index, proto in ientitylist(Shared.GetEntitiesWithClassname("PrototypeLab")) do
        
                num = num + 1
                
                if not GetIsACreditStructure(proto) then
                num = num + 1
                end
    end
    
    
    return num < kProtoEntityLimit
end
 
 local function GetCheckWhipGateLimit()
     local num = 0

        for index, whip in ientitylist(Shared.GetEntitiesWithClassname("Whip")) do
        
                num = num + 1
                
                if not GetIsACreditStructure(whip) then
                num = num + 1
                end
    end
    
    
    return num < kWhipEntityLimit
end
local function GetCheckShiftLimit()
    local num = 0

        
        for index, shift in ientitylist(Shared.GetEntitiesWithClassname("Shift")) do
        
              if not GetIsACreditStructure(shift) then
                num = num + 1
                end
            
    end
    
    return num < kShiftEntityLimit
end
local function GetCheckShadeFactoryLimit()
    local num = 0

        
        for index, shade in ientitylist(Shared.GetEntitiesWithClassname("Shade")) do
        
                if not GetIsACreditStructure(shade) then
                num = num + 1
                end
            
    end
    
    return num < kShadeEntityLimit
end
local function GetCheckCragLabLimit()
    local num = 0

        
        for index, crag in ientitylist(Shared.GetEntitiesWithClassname("Crag")) do
        
                 if not GetIsACreditStructure(crag) then
                num = num + 1
                end
            
    end
    
    return num < kCragEntityLimit
end
local function GetCheckCommandStationLimit()
    local num = 0

        
        for index, commandstation in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        
                num = num + 1
            
    end
    
    return num < 3
end
SetCachedTechData(kTechId.Sentry, kStructureBuildNearClass, false)
SetCachedTechData(kTechId.Sentry, kStructureAttachRange, 999)
SetCachedTechData(kTechId.Sentry, kTechDataSpecifyOrientation, false)

SetCachedTechData(kTechId.SentryBattery, kTechDataHint, "Powers structures without power!")
SetCachedTechData(kTechId.SentryBattery,kTechDataDisplayName, "Backup Battery")


SetCachedTechData(kTechId.Spur, kTechDataBuildMethodFailedMessage, "Trying to crash the server?")
SetCachedTechData(kTechId.Veil, kTechDataBuildMethodFailedMessage, "Trying to crash the server?")
SetCachedTechData(kTechId.Shell, kTechDataBuildMethodFailedMessage, "Trying to crash the server?")


SetCachedTechData(kTechId.Whip, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.Crag, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.Shade, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.Shift, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")

SetCachedTechData(kTechId.CommandStation, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.InfantryPortal, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.Sentry, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.Armory, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")

SetCachedTechData(kTechId.ArmsLab, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.InfantryPortal, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.PhaseGate, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.Observatory, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.RoboticsFactory, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")
SetCachedTechData(kTechId.PrototypeLab, kTechDataBuildMethodFailedMessage, "Limit reached for Commander ents of this type")



SetCachedTechData(kTechId.ArmsLab, kTechDataBuildRequiresMethod, GetCheckArmsLabLimit)
SetCachedTechData(kTechId.InfantryPortal, kTechDataBuildRequiresMethod, GetCheckInfantryPortalLimit)
SetCachedTechData(kTechId.Armory, kTechDataBuildRequiresMethod, GetCheckArmoryLimit)
SetCachedTechData(kTechId.PhaseGate, kTechDataBuildRequiresMethod, GetCheckPhaseGateLimit)
SetCachedTechData(kTechId.Observatory, kTechDataBuildRequiresMethod, GetCheckObservatoryLimit)
SetCachedTechData(kTechId.RoboticsFactory, kTechDataBuildRequiresMethod, GetCheckRoboticsFactoryLimit)
SetCachedTechData(kTechId.PrototypeLab, kTechDataBuildRequiresMethod, GetCheckPrototypeLabLimit)

SetCachedTechData(kTechId.CommandStation, kTechDataBuildRequiresMethod, GetCheckCommandStationLimit)

SetCachedTechData(kTechId.Whip, kTechDataBuildRequiresMethod, GetCheckWhipGateLimit)
SetCachedTechData(kTechId.Shift, kTechDataBuildRequiresMethod, GetCheckShiftLimit)
SetCachedTechData(kTechId.Shade, kTechDataBuildRequiresMethod, GetCheckShadeFactoryLimit)
SetCachedTechData(kTechId.Crag, kTechDataBuildRequiresMethod, GetCheckCragLabLimit)

SetCachedTechData(kTechId.CommandStation, kStructureAttachClass, false)
SetCachedTechData(kTechId.Spur, kTechDataBuildRequiresMethod, GetCheckSpurLimit)
SetCachedTechData(kTechId.Veil, kTechDataBuildRequiresMethod, GetCheckVeilLimit)
SetCachedTechData(kTechId.Shell, kTechDataBuildRequiresMethod, GetCheckShellLimit)


Script.Load("lua/Additions/Convars.lua")
Script.Load("lua/Additions/EggBeacon.lua")
Script.Load("lua/Additions/StructureBeacon.lua")
Script.Load("lua/Additions/PrimalScream.lua")
Script.Load("lua/Additions/FadeWall.lua")
Script.Load("lua/Additions/OnoLow.lua")
Script.Load("lua/Additions/OnoGrow.lua")

Script.Load("lua/Modifications/GorgeStruct.lua")

local kSiege_TechData =
{        

 
  { [kTechDataId] = kTechId.AdvancedBeacon,   
   [kTechDataBuildTime] = 0.1,   
   [kTechDataCooldown] = kAdvancedBeaconCoolDown,
    [kTechDataDisplayName] = "Advanced Beacon",   
   [kTechDataHotkey] = Move.B, 
    [kTechDataCostKey] = kAdvancedBeaconCost, 
   [kTechDataTooltipInfo] =  "Revives Dead Players as well."},
   
   
        { [kTechDataId] = kTechId.MacSpawnOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Automatically spawn up to 8 macs for you",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "8 is currently the max amount to automatically spawn this way. Turning this on will automatically spawn up to this many for you"},
         
          { [kTechDataId] = kTechId.MacSpawnOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Disables automatic small mac spawning",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "For those who prefer micro-micro management"},
         
         { [kTechDataId] = kTechId.ArcSpawnOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Automatically spawn up to 12 arcs for you",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "12 is currently the max amount of commander arcs. Turning this on will automatically spawn up to this many for you"},
         
          { [kTechDataId] = kTechId.ArcSpawnOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Disables automatic arc spawning",       
         [kTechDataCostKey] = 0, 
          [kTechDataTooltipInfo] = "For those who prefer micro-micro management"},

       
        { [kTechDataId] = kTechId.EggBeacon, 
        [kTechDataCooldown] = kEggBeaconCoolDown, [kTechDataBioMass] = kShellBiomass, 
         [kTechDataHint] = "Eggs Spawn approximately at the placed Egg Beacon. Be careful as infestation is required.", 
        [kTechDataGhostModelClass] = "AlienGhostModel",   
            [kTechDataMapName] = EggBeacon.kMapName,        
                 [kTechDataDisplayName] = "Egg Beacon",  [kTechDataCostKey] = kEggBeaconCost,   
            [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,   
         [kTechDataBuildTime] = 8, [kTechDataModel] = Shell.kModelName,   
         [kVisualRange] = 7,
[kTechDataMaxHealth] = kShellHealth, [kTechDataMaxArmor] = kShellArmor},

        { [kTechDataId] = kTechId.StructureBeacon, 
        [kTechDataCooldown] = kStructureBeaconCoolDown, [kTechDataBioMass] = kShellBiomass, 
         [kTechDataHint] = "Structures move approximately at the placed Egg Beacon", 
        [kTechDataGhostModelClass] = "AlienGhostModel",   
            [kTechDataMapName] = StructureBeacon.kMapName,        
                 [kTechDataDisplayName] = "Structure Beacon",  [kTechDataCostKey] = kStructureBeaconCost,   
            [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,   
         [kTechDataBuildTime] = 8, [kTechDataModel] = Spur.kModelName,   
         [kVisualRange] = 7,
[kTechDataMaxHealth] = kShiftHealth, [kTechDataMaxArmor] = kShiftArmor},

                  --Thanks dragon ns2c
       { [kTechDataId] = kTechId.PrimalScream,  
         [kTechDataCategory] = kTechId.Lerk,
       [kTechDataDisplayName] = "Primal Scream",
        [kTechDataMapName] =  Primal.kMapName,
         --[kTechDataCostKey] = kPrimalScreamCostKey, 
       -- [kTechDataResearchTimeKey] = kPrimalScreamTimeKey, 
 [kTechDataTooltipInfo] = "Season 3 - More Exciting. PBAOE Extinguish Fire, +Energy to teammates, random drifter buff (hallucinate/enzyme/mucous)"},
 
 
     
  { [kTechDataId] = kTechId.FadeWall,        
  [kTechDataCategory] = kTechId.Fade,   
     [kTechDataMapName] = FadeWall.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
 --   [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "FadeWall",
 [kTechDataTooltipInfo] = "Spawns bonewall @ origin. try blocking marines with it. Be careful you dont get stuck, or block your own team."},
 
   { [kTechDataId] = kTechId.OnoLow,        
  [kTechDataCategory] = kTechId.Onos,   
     [kTechDataMapName] = OnoLow.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
 --   [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "OnoLow",
 [kTechDataTooltipInfo] = "wip"},
 
   { [kTechDataId] = kTechId.OnoGrow,        
  [kTechDataCategory] = kTechId.Onos,   
     [kTechDataMapName] = OnoGrow.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
 --   [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "OnoGrow",
 [kTechDataTooltipInfo] = "wip"},
           /*
                    { [kTechDataId] = kTechId.LayStructures,  
         [kTechDataMaxHealth] = kMarineWeaponHealth, 
       [kTechDataMapName] = LayStructures.kMapName,         
            [kTechDataDisplayName] = "LayStructure",    
      [kTechDataModel] = Welder.kModelName, 
     [kTechDataDamageType] = kWelderDamageType, 
          [kTechDataCostKey] = kWelderCost   },
        */
        
        
          { [kTechDataId] = kTechId.GorgeCrag, [kTechDataAllowConsumeDrop] = true, [kTechDataMaxAmount] = 3, [kTechDataBioMass] = kCragBiomass, [kTechDataSupply] = kCragSupply, [kTechDataHint] = "CRAG_HINT", [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMapName] = GorgeCrag.kMapName,                         [kTechDataDisplayName] = "GorgeCRAG",  [kTechDataCostKey] = kCragCost,     [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,       [kTechDataBuildTime] = kCragBuildTime, [kTechDataModel] = Crag.kModelName,           [kTechDataMaxHealth] = kCragHealth, [kTechDataMaxArmor] = kCragArmor,   [kTechDataInitialEnergy] = kCragInitialEnergy,      [kTechDataMaxEnergy] = kCragMaxEnergy, [kTechDataPointValue] = kCragPointValue, [kVisualRange] = Crag.kHealRadius, [kTechDataTooltipInfo] = "CRAG_TOOLTIP", [kTechDataGrows] = true},

        { [kTechDataId] = kTechId.GorgeWhip, [kTechDataAllowConsumeDrop] = true, [kTechDataMaxAmount] = 3, [kTechDataBioMass] = kWhipBiomass, [kTechDataSupply] = kWhipSupply, [kTechDataHint] = "WHIP_HINT", [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMapName] = GorgeWhip.kMapName,                         [kTechDataDisplayName] = "GorgeWHIP",  [kTechDataCostKey] = kWhipCost,    [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.W,        [kTechDataBuildTime] = kWhipBuildTime, [kTechDataModel] = Whip.kModelName,           [kTechDataMaxHealth] = kWhipHealth, [kTechDataMaxArmor] = kWhipArmor,   [kTechDataDamageType] = kDamageType.Structural, [kTechDataInitialEnergy] = kWhipInitialEnergy,      [kTechDataMaxEnergy] = kWhipMaxEnergy, [kVisualRange] = Whip.kRange, [kTechDataPointValue] = kWhipPointValue, [kTechDataTooltipInfo] = "WHIP_TOOLTIP", [kTechDataGrows] = true},

        { [kTechDataId] = kTechId.GorgeShift, [kTechDataAllowConsumeDrop] = true, [kTechDataMaxAmount] = 3, [kTechDataBioMass] = kShiftBiomass, [kTechDataSupply] = kShiftSupply, [kTechDataHint] = "SHIFT_HINT", [kTechDataGhostModelClass] = "ShiftGhostModel",    [kTechDataMapName] = GorgeShift.kMapName,                        [kTechDataDisplayName] = "GorgeSHIFT",  [kTechDataRequiresInfestation] = true, [kTechDataCostKey] = kShiftCost,    [kTechDataHotkey] = Move.S,        [kTechDataBuildTime] = kShiftBuildTime, [kTechDataModel] = Shift.kModelName,           [kTechDataMaxHealth] = kShiftHealth,  [kTechDataMaxArmor] = kShiftArmor,  [kTechDataInitialEnergy] = kShiftInitialEnergy,      [kTechDataMaxEnergy] = kShiftMaxEnergy, [kTechDataPointValue] = kShiftPointValue, [kVisualRange] = kEchoRange, [kTechDataTooltipInfo] = "SHIFT_TOOLTIP", [kTechDataGrows] = true },
        
        { [kTechDataId] = kTechId.GorgeShade, [kTechDataAllowConsumeDrop] = true, [kTechDataMaxAmount] = 3, [kTechDataBioMass] = kShadeBiomass, [kTechDataSupply] = kShadeSupply, [kTechDataHint] = "SHADE_HINT", [kTechDataGhostModelClass] = "AlienGhostModel",    [kTechDataMapName] = GorgeShade.kMapName,                        [kTechDataDisplayName] = "GorgeSHADE",  [kTechDataCostKey] = kShadeCost,      [kTechDataRequiresInfestation] = true,     [kTechDataBuildTime] = kShadeBuildTime, [kTechDataHotkey] = Move.D, [kTechDataModel] = Shade.kModelName,           [kTechDataMaxHealth] = kShadeHealth, [kTechDataMaxArmor] = kShadeArmor,   [kTechDataInitialEnergy] = kShadeInitialEnergy,      [kTechDataMaxEnergy] = kShadeMaxEnergy, [kTechDataPointValue] = kShadePointValue, [kVisualRange] = Shade.kCloakRadius, [kTechDataMaxExtents] = Vector(1, 1.3, .4), [kTechDataTooltipInfo] = "SHADE_TOOLTIP", [kTechDataGrows] = true },
 

}   

local kSiege_TechIdToMaterialOffset = {}
kSiege_TechIdToMaterialOffset[kTechId.AdvancedBeacon] = 52
kSiege_TechIdToMaterialOffset[kTechId.EggBeacon] = 52

local getmaterialxyoffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)

    local index
    index = kSiege_TechIdToMaterialOffset[techId]
    
    if not index then
        return getmaterialxyoffset(techId)
    end
    
    local columns = 12
    index = kSiege_TechIdToMaterialOffset[techId]
    
    if index == nil then
        Print("Warning: %s did not define kTechIdToMaterialOffset ", EnumToString(kTechId, techId) )
    end

    if(index ~= nil) then
    
        local x = index % columns
        local y = math.floor(index / columns)
        return x, y
        
    end
    
    return nil, nil
    
end

local buildTechData = BuildTechData
function BuildTechData()

    local defaultTechData = buildTechData()
    local moddedTechData = {}
    local usedTechIds = {}
    
    for i = 1, #kSiege_TechData do
        local techEntry = kSiege_TechData[i]
        table.insert(moddedTechData, techEntry)
        table.insert(usedTechIds, techEntry[kTechDataId])
    end
    
    for i = 1, #defaultTechData do
        local techEntry = defaultTechData[i]
        if not table.contains(usedTechIds, techEntry[kTechDataId]) then
            table.insert(moddedTechData, techEntry)
        end
    end
    
    return moddedTechData

end

