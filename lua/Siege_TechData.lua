Script.Load("lua/Additions/EggBeacon.lua")
Script.Load("lua/Additions/StructureBeacon.lua")
Script.Load("lua/Additions/Convars.lua")
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

       /*
           { [kTechDataId] = kTechId.LerkMod,
    [kTechDataUpgradeCost] = kLerkUpgradeCost, 
    [kTechDataMapName] = LerkMod.kMapName, 
   [kTechDataGestateName] = LerkMod.kMapName, 
   [kTechDataGestateTime] = kLerkGestateTime, 
   [kTechDataDisplayName] = "LERK",   
   [kTechDataTooltipInfo] = "LERK_TOOLTIP",     
      [kTechDataModel] = Lerk.kModelName,
 [kTechDataCostKey] = kLerkCost, 
 [kTechDataMaxHealth] = kLerkHealth, 
 [kTechDataMaxArmor] = kLerkArmor, 
   [kTechDataEngagementDistance] = kPlayerEngagementDistance, 
  [kTechDataMaxExtents] = Vector(Lerk.XZExtents, Lerk.YExtents, Lerk.XZExtents), 
  [kTechDataPointValue] = kLerkPointValue},
  */

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