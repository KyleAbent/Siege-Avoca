--Kyle 'Avoca' Abent


Script.Load("lua/TechTreeButtons.lua")

local gTechIdToString = {}

local function createTechIdEnum(table)

    for i = 1, #table do    
        gTechIdToString[table[i]] = i  
    end
    
    
    return enum(table)

end

local oldtechid = kTechId
    --This was SO FUN TO WRITE
    --Can somebody pat my back on this one? Thanks
local function GetConstants() --So this just overwrites the default ones by... grabbing default values, and adding my own values xD
local tabley = {}
  Print("thenname is %s", thenname)
       -----------Additions-----------
      table.insert(tabley, 'AdvancedBeacon' ) 
      -----------------------------------

  for index,record in ipairs(oldtechid) do 
       local name = EnumToString(oldtechid, EnumToString(oldtechid, record) )
          table.insert(tabley,name)
    end
    
        for i = 1, #tabley  do
     local content = tabley[i]
       --   Print("%s set as techtreeconstant", content)
    end
    

    return tabley

end


kTechId = createTechIdEnum(GetConstants())

--Thanks modular exo
local function AddTechChanges(techData)				

	table.insert(techData, { 	[kTechDataId] = kTechId.AdvancedBeacon,
								 [kTechDataCostKey] = 10,
                              [kTechDataCooldown] = 10,
                              [kTechDataTooltipInfo] =  "Revives dead players as well."})
					
end

local oldBuildTechData = BuildTechData
function BuildTechData()
	local techData = oldBuildTechData()
	AddTechChanges(techData)
	return techData
end
*/
local oldbuttonthing = GetMaterialXYOffset
    
local function GetMatching(techId)

  for index,record in ipairs(kTechId) do 
       local name = EnumToString(kTechId, EnumToString(kTechId, record) )
       --if techId == name then return EnumToString(kTechId, record ) end
    end
    
end

function GetMaterialXYOffset(techId)

    local index = nil
    --Print("techid is %s", techId)
    local columns = 12
    --index = 1--GetMatching( EnumToString(kTechId, EnumToString(kTechId, techId) ))
    Print("Index for techid %s is %s", techId, index)
   -- if techId == kTechId.AdvancedBeacon then index =  52 end
    if not index then
        DebugPrint("Warning: %s did not define kTechIdToMaterialOffset ", EnumToString(kTechId, techId) )
    else
    
        local x = index % columns
        local y = math.floor(index / columns)
        return x, y
        
    end
    
    return nil, nil


end







