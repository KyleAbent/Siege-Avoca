// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIMinimap.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages displaying the minimap and icons on the minimap.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIMinimapConnection.lua")
Script.Load("lua/MinimapMappableMixin.lua")

class 'GUIMinimap' (GUIScript)

-- activity is rechecked with this intervals, immobile blips will be updated at this interval too
local kActivityUpdateInterval = 0.5

 -- how often we update for each activity level
local kBlipActivityUpdateInterval = {}
kBlipActivityUpdateInterval[kMinimapActivity.Static] = kActivityUpdateInterval
kBlipActivityUpdateInterval[kMinimapActivity.Low] = 0.2
kBlipActivityUpdateInterval[kMinimapActivity.Medium] = 0.05
kBlipActivityUpdateInterval[kMinimapActivity.High] = 0.001

-- allow update rate to be controlled by console (minimap_rate). 0 = full rate
GUIMinimap.kUpdateIntervalMultipler = 1


-- update the "other stuff" at 25Hz 
local kMiscUpdateInterval = 0.04

local kPlayerNameLayer = 7
local kPlayerNameFontSize = 8
local kPlayerNameFontName = Fonts.kAgencyFB_Tiny
local kPlayerNameOffset = Vector(11.5, -5, 0)
local kPlayerNameColorAlien = Color(127/255, 255/255, 0/255, 1)
local kPlayerNameColorMarine = Color(164/255, 241/255, 1, 1)

local kBlipSize = GUIScale(30)

local kWaypointColor = Color(1, 1, 1, 1)
local kEtherealGateColor = Color(0.8, 0.6, 1, 1)
local kOverviewColor = Color(1, 1, 1, 0.85)

// colors are defined in the dds
local kTeamColors = { }
kTeamColors[kMinimapBlipTeam.Friendly] = Color(1, 1, 1, 1)
kTeamColors[kMinimapBlipTeam.Enemy] = Color(1, 0, 0, 1)
kTeamColors[kMinimapBlipTeam.Neutral] = Color(1, 1, 1, 1)
kTeamColors[kMinimapBlipTeam.Alien] = Color(127/255, 255/255, 0/255, 1)
kTeamColors[kMinimapBlipTeam.Marine] = Color(0, 216/255, 1, 1)
// steam friend colors
kTeamColors[kMinimapBlipTeam.FriendAlien] = Color(1, 189/255, 111/255, 1)
kTeamColors[kMinimapBlipTeam.FriendMarine] = Color(164/255, 241/255, 1, 1)

kTeamColors[kMinimapBlipTeam.InactiveAlien] = Color(85/255, 46/255, 0, 1, 1)
kTeamColors[kMinimapBlipTeam.InactiveMarine] = Color(0, 72/255, 85/255, 1)

local kPowerNodeColor = Color(1, 1, 0.7, 1)
local kDestroyedPowerNodeColor = Color(0.5, 0.5, 0.35, 1)

local kDrifterColor = Color(1, 1, 0, 1)
local kMACColor = Color(0, 1, 0.2, 1)

local kBlinkInterval = 1

local kScanColor = Color(0.2, 0.8, 1, 1)
local kScanAnimDuration = 2

local kFullColor = Color(1,1,1,1)

local kInfestationColor = { }
kInfestationColor[kMinimapBlipTeam.Friendly] = Color(1, 1, 0, .25)
kInfestationColor[kMinimapBlipTeam.Enemy] = Color(1, 0.67, 0.06, .25)
kInfestationColor[kMinimapBlipTeam.Neutral] = Color(0.2, 0.7, 0.2, .25)
kInfestationColor[kMinimapBlipTeam.Alien] = Color(0.2, 0.7, 0.2, .25)
kInfestationColor[kMinimapBlipTeam.Marine] = Color(0.2, 0.7, 0.2, .25)
kInfestationColor[kMinimapBlipTeam.InactiveAlien] = Color(0.2 /3, 0.7/3, 0.2/3, .25)
kInfestationColor[kMinimapBlipTeam.InactiveMarine] = Color(0.2/3, 0.7/3, 0.2/3, .25)

local kInfestationDyingColor = { }
kInfestationDyingColor[kMinimapBlipTeam.Friendly] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Enemy] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Neutral] =Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Alien] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.Marine] = Color(1, 0.2, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.InactiveAlien] = Color(1/3, 0.2/3, 0, .25)
kInfestationDyingColor[kMinimapBlipTeam.InactiveMarine] = Color(1/3, 0.2/3, 0, .25)

local kShrinkingArrowInitSize

local kIconFileName = "ui/minimap_blip.dds"

local kLargePlayerArrowFileName = PrecacheAsset("ui/minimap_largeplayerarrow.dds")

local kCommanderPingMinimapSize

local kIconWidth = 32
local kIconHeight = 32

local kInfestationBlipsLayer = 0
local kBackgroundBlipsLayer = 1
local kStaticBlipsLayer = 2
local kDynamicBlipsLayer = 3
local kLocationNameLayer = 4
local kPingLayer = 5
local kPlayerIconLayer = 6

local kBlipTexture = "ui/blip.dds"

local kBlipTextureCoordinates = { }
kBlipTextureCoordinates[kAlertType.Attack] = { X1 = 0, Y1 = 0, X2 = 64, Y2 = 64 }

local kAttackBlipMinSize
local kAttackBlipMaxSize
local kAttackBlipPulseSpeed = 6
local kAttackBlipTime = 5
local kAttackBlipFadeInTime = 4.5
local kAttackBlipFadeOutTime = 1

local kLocationFontSize = 8
local kLocationFontName = Fonts.kAgencyFB_Smaller_Bordered

local kPlayerIconSize

local kBlipColorType = enum( { 'Team', 'Infestation', 'InfestationDying', 'Waypoint', 'PowerPoint', 'DestroyedPowerPoint', 'Scan', 'Drifter', 'MAC', 'EtherealGate', 'HighlightWorld', 'FullColor' } )
local kBlipSizeType = enum( { 'Normal', 'TechPoint', 'Infestation', 'Scan', 'Egg', 'Worker', 'EtherealGate', 'HighlightWorld', 'Waypoint', 'BoneWall', 'UnpoweredPowerPoint' } )

local kBlipInfo = {}
kBlipInfo[kMinimapBlipType.TechPoint] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.ResourcePoint] = { kBlipColorType.Team, kBlipSizeType.Normal, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.Scan] = { kBlipColorType.Scan, kBlipSizeType.Scan, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.CommandStation] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.Hive] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.Egg] = { kBlipColorType.Team, kBlipSizeType.Egg, kStaticBlipsLayer, "Infestation" }
kBlipInfo[kMinimapBlipType.PowerPoint] = { kBlipColorType.PowerPoint, kBlipSizeType.Normal, kStaticBlipsLayer, "PowerPoint" }
kBlipInfo[kMinimapBlipType.DestroyedPowerPoint] = { kBlipColorType.DestroyedPowerPoint, kBlipSizeType.Normal, kStaticBlipsLayer, "PowerPoint" }
kBlipInfo[kMinimapBlipType.UnsocketedPowerPoint] = { kBlipColorType.FullColor, kBlipSizeType.UnpoweredPowerPoint, kStaticBlipsLayer, "UnsocketedPowerPoint" }
kBlipInfo[kMinimapBlipType.BlueprintPowerPoint] = { kBlipColorType.Team, kBlipSizeType.UnpoweredPowerPoint, kStaticBlipsLayer, "UnsocketedPowerPoint" }
kBlipInfo[kMinimapBlipType.Infestation] = { kBlipColorType.Infestation, kBlipSizeType.Infestation, kInfestationBlipsLayer, "Infestation" }
kBlipInfo[kMinimapBlipType.InfestationDying] = { kBlipColorType.InfestationDying, kBlipSizeType.Infestation, kInfestationBlipsLayer, "Infestation" }
kBlipInfo[kMinimapBlipType.MoveOrder] = { kBlipColorType.Waypoint, kBlipSizeType.Waypoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.AttackOrder] = { kBlipColorType.Waypoint, kBlipSizeType.Waypoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.BuildOrder] = { kBlipColorType.Waypoint, kBlipSizeType.Waypoint, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.Drifter] = { kBlipColorType.Drifter, kBlipSizeType.Worker, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.MAC] = { kBlipColorType.MAC, kBlipSizeType.Worker, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.EtherealGate] = { kBlipColorType.EtherealGate, kBlipSizeType.EtherealGate, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.HighlightWorld] = { kBlipColorType.HighlightWorld, kBlipSizeType.HighlightWorld, kBackgroundBlipsLayer }
kBlipInfo[kMinimapBlipType.BoneWall] = { kBlipColorType.FullColor, kBlipSizeType.BoneWall, kBackgroundBlipsLayer }

local kClassToGrid = BuildClassToGrid()

GUIMinimap.kBackgroundWidth = GUIScale(300)
GUIMinimap.kBackgroundHeight = GUIMinimap.kBackgroundWidth

local function UpdateItemsGUIScale(self)
    kBlipSize = GUIScale(30)
    kShrinkingArrowInitSize = Vector(kBlipSize * 10, kBlipSize * 10, 0)
    kAttackBlipMinSize = Vector(GUIScale(25), GUIScale(25), 0)
    kAttackBlipMaxSize = Vector(GUIScale(100), GUIScale(100), 0)

    kCommanderPingMinimapSize = GUIScale(Vector(80, 80, 0))
    
    kPlayerIconSize = Vector(kBlipSize, kBlipSize, 0)
    self.playerIcon:SetSize(kPlayerIconSize)
    
    GUIMinimap.kBackgroundWidth = GUIScale(300)
    GUIMinimap.kBackgroundHeight = GUIMinimap.kBackgroundWidth
    self.background:SetSize(Vector(GUIMinimap.kBackgroundWidth, GUIMinimap.kBackgroundHeight, 0))
    
    local scale = self:GetScale()
    self:SetScale(scale)
    
    local size = Vector(GUIMinimap.kBackgroundWidth * scale, GUIMinimap.kBackgroundHeight * scale, 0)
    self.minimap:SetSize(size)
    self.minimap:SetPosition(size * -0.5)
    
    for _,v in pairs(self.nameTagMap) do
        GUI.DestroyItem(v)
    end
    self.nameTagMap = {}
end

function GUIMinimap:PlotToMap(posX, posZ)

    local plottedX = (posX + self.plotToMapConstX) * self.plotToMapLinX
    local plottedY = (posZ + self.plotToMapConstY) * self.plotToMapLinY
    
    // The world space is oriented differently from the GUI space, adjust for that here.
    // Return 0 as the third parameter so the results can easily be added to a Vector.
    return plottedY, -plottedX, 0
    
end

local gLocationItems = {}

function GUIMinimap:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
end

function GUIMinimap:Initialize()
    
    // we update the minimap at full rate, but internally we spread out the
    // actual load of updating the map so we only do a little bit of work each frame
    self.updateInterval = kUpdateIntervalFull
   
    self.nextMiscUpdateInterval = 0
    self.nextActivityUpdateTime = 0
  
    self.staticBlipData = {}
    self.iconMap = {}
    self.freeIcons = {}
    self.localBlipData = {}
    
    for k,v in pairs(kMinimapActivity) do
        self.staticBlipData[k] = {}
        self.staticBlipData[k].blipIds = {}
        self.staticBlipData[k].count = 0
        self.staticBlipData[k].workIndex = 1
    end
    
    local player = Client.GetLocalPlayer()
    self.showPlayerNames = false
    self.spectating = false
    self.clientIndex = player:GetClientIndex()
    -- infinite radius; set to > 0 for marine HUD; stops processing blips at > radius
    self.updateRadius = 0 
    self.updateRadiusSquared = 0
    -- individual update rate multiplier. Set to run at full rate (all intervals are multipled by zero). Set to 1 to run 
    -- at CPU saving rate
    self.updateIntervalMultipler = 0
    self.nameTagMap = {}
    -- the rest is untouched in rewrite
  
    self.locationItems = { }
    self.timeMapOpened = 0
    self.stencilFunc = GUIItem.Always
    self.iconFileName = kIconFileName
    self.inUseStaticBlipCount = 0
    self.reuseDynamicBlips = { }
    self.inuseDynamicBlips = { }
    self.scanColor = Color(kScanColor.r, kScanColor.g, kScanColor.b, kScanColor.a)
    self.scanSize = Vector(0, 0, 0)
    self.highlightWorldColor = Color(0, 1, 0, 1)
    self.highlightWorldSize = Vector(0, 0, 0)
    self.etherealGateColor = Color(kEtherealGateColor.r, kEtherealGateColor.g, kEtherealGateColor.b, kEtherealGateColor.a)
    self.blipSizeTable = { }
    self.minimapConnections = { }

    self.playerNameItems = {}
    self.playerNameItemsLookup = {}
    
    self:SetScale(1) // Compute plot to map transformation
    self:SetBlipScale(1) // Compute blipSizeTable
    self.blipSizeTable[kBlipSizeType.Scan] = self.scanSize
    self.blipSizeTable[kBlipSizeType.HighlightWorld] = self.highlightWorldSize
    
    // Initialize blip info lookup table
    local blipInfoTable = {}
    for blipType, _ in ipairs(kMinimapBlipType) do
        local blipInfo = kBlipInfo[blipType]
        local iconCol, iconRow = GetSpriteGridByClass((blipInfo and blipInfo[4]) or EnumToString(kMinimapBlipType, blipType), kClassToGrid)
        local texCoords = table.pack(GUIGetSprite(iconCol, iconRow, kIconWidth, kIconHeight))
        if blipInfo then
          blipInfoTable[blipType] = { texCoords, blipInfo[1], blipInfo[2], blipInfo[3] }
        else
          blipInfoTable[blipType] = { texCoords, kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer }
        end
    end
    self.blipInfoTable = blipInfoTable
    
    // Generate blip color lookup table
    local blipColorTable = {}
    for blipTeam, _ in ipairs(kMinimapBlipTeam) do
        local colorTable = {}
        colorTable[kBlipColorType.Team] = kTeamColors[blipTeam]
        colorTable[kBlipColorType.Infestation] = kInfestationColor[blipTeam]
        colorTable[kBlipColorType.InfestationDying] = kInfestationDyingColor[blipTeam]
        colorTable[kBlipColorType.Waypoint] = kWaypointColor
        colorTable[kBlipColorType.PowerPoint] = kPowerNodeColor
        colorTable[kBlipColorType.DestroyedPowerPoint] = kDestroyedPowerNodeColor
        colorTable[kBlipColorType.Scan] = self.scanColor
        colorTable[kBlipColorType.HighlightWorld] = self.highlightWorldColor
        colorTable[kBlipColorType.Drifter] = kDrifterColor
        colorTable[kBlipColorType.MAC] = kMACColor
        colorTable[kBlipColorType.EtherealGate] = self.etherealGateColor
        colorTable[kBlipColorType.FullColor] = kFullColor
        blipColorTable[blipTeam] = colorTable
    end
    self.blipColorTable = blipColorTable

    self:InitializeBackground()
    
    self.minimap = GUIManager:CreateGraphicItem()
    self.minimap:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.minimap:SetPosition(Vector(0, 0, 0))
    self.minimap:SetTexture("maps/overviews/" .. Shared.GetMapName() .. ".tga")
    self.minimap:SetColor(kOverviewColor)
    self.background:AddChild(self.minimap)
    
    // Used for commander / spectator.
    self:InitializeCameraLines()
    // Used for normal players.
    self:InitializePlayerIcon()
    
    // initialize commander ping
    self.commanderPing = GUICreateCommanderPing()
    self.commanderPing.Frame:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.commanderPing.Frame:SetLayer(kPingLayer)
    self.minimap:AddChild(self.commanderPing.Frame)
    
    UpdateItemsGUIScale(self)
end

function GUIMinimap:InitializeBackground()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetPosition(Vector(0, 0, 0))
    self.background:SetColor(Color(1, 1, 1, 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetLayer(kGUILayerMinimap)
    
    // Non-commander players assume the map isn't visible by default.
    if not PlayerUI_IsACommander() then
        self.background:SetIsVisible(false)
    end

end

function GUIMinimap:InitializeCameraLines()

    self.cameraLines = GUIManager:CreateLinesItem()
    self.cameraLines:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.cameraLines:SetLayer(kPlayerIconLayer)
    self.minimap:AddChild(self.cameraLines)
    
end

function GUIMinimap:InitializePlayerIcon()
    
    self.playerIcon = GUIManager:CreateGraphicItem()
    self.playerIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.playerIcon:SetTexture(self.iconFileName)
    iconCol, iconRow = GetSpriteGridByClass(PlayerUI_GetPlayerClass(), kClassToGrid)
    self.playerIcon:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, kIconWidth, kIconHeight))
    self.playerIcon:SetIsVisible(false)
    self.playerIcon:SetLayer(kPlayerIconLayer)
    self.minimap:AddChild(self.playerIcon)

    self.playerShrinkingArrow = GUIManager:CreateGraphicItem()
    self.playerShrinkingArrow:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.playerShrinkingArrow:SetTexture(kLargePlayerArrowFileName)
    self.playerShrinkingArrow:SetLayer(kPlayerIconLayer)
    self.playerIcon:AddChild(self.playerShrinkingArrow)
    
end

local function SetupLocationTextItem(item)

    item:SetScale(GetScaledVector())
    item:SetFontIsBold(false)
    item:SetFontName(kLocationFontName)
    item:SetAnchor(GUIItem.Middle, GUIItem.Center)
    item:SetTextAlignmentX(GUIItem.Align_Center)
    item:SetTextAlignmentY(GUIItem.Align_Center)
    item:SetLayer(kLocationNameLayer)

end

local function SetLocationTextPosition( item, mapPos )

    item.text:SetPosition( Vector(mapPos.x, mapPos.y, 0) )
    local offset = 1

end
local function SetLocationTextColor( item, color )

    item.text:SetColor( color )

end
function OnCommandSetMapLocationColor()


        
        
    if gLocationItems ~= nil then
    //Change Siege/Front names to Red, Blue for rooms with built powernode and Green for Rooms with unbuilt/killed node. 

        for _, locationItem in ipairs(gLocationItems) do
        
       //  locationItem.text:SetColor(Color(232/255, 129/255, 23/255, 1))
             
             local powerpoint = GetPowerPointForLocation(locationItem.Name)
                if powerpoint ~= nil then 
                    if powerpoint:GetIsBuilt() then 
                      locationItem.text:SetColor(Color(44.0, 106.0, 426, 1))
                    else
                      locationItem.text:SetColor(Color(1.0, 255.0, 31.0, 1))
                     end
                else
               locationItem.text:SetColor(Color(1.0, 1.0, 1.0, 0.65))
               end
               
        
          end

    end
        
end


function GUIMinimap:InitializeLocationNames()

    self:UninitializeLocationNames()
    local locationData = PlayerUI_GetLocationData()
    
    // Average the position of same named locations so they don't display
    // multiple times.
    local multipleLocationsData = { }
    for i, location in ipairs(locationData) do
    
        // Filter out the ready room.
        if location.Name ~= "Ready Room" then
        
            local locationTable = multipleLocationsData[location.Name]
            if locationTable == nil then
            
                locationTable = { }
                multipleLocationsData[location.Name] = locationTable
                
            end
            table.insert(locationTable, location.Origin)
            
        end
        
    end
    
    local uniqueLocationsData = { }
    for name, origins in pairs(multipleLocationsData) do
    
        local averageOrigin = Vector(0, 0, 0)
        table.foreachfunctor(origins, function (origin) averageOrigin = averageOrigin + origin end)
        table.insert(uniqueLocationsData, { Name = name, Origin = averageOrigin / table.count(origins), IsSiege =  string.find(name, "Siege"), IsFront = string.find(name, "Front") })
        
    end
    
    
    
    for i, location in ipairs(uniqueLocationsData) do

        local posX, posY = self:PlotToMap(location.Origin.x, location.Origin.z)

        // Locations only supported on the big mode.
        local locationText = GUIManager:CreateTextItem()
        local color = Color(1.0, 1.0, 1.0, 0.65)
        color = ConditionalValue(location.IsSiege, Color(1, 0, 0), color)
        color = ConditionalValue(location.isFront, Color(1, 0, 0), color)
        locationText:SetColor(color)
        SetupLocationTextItem(locationText)
        locationText:SetText(location.Name)
        locationText:SetPosition( Vector(posX, posY, 0) )

        self.minimap:AddChild(locationText)

        local locationItem = {name = location.Name, text = locationText, origin = location.Origin, IsSiege = location.IsSiege, IsFront = location.IsFront }
        table.insert(self.locationItems, locationItem)
        
        

    end
    gLocationItems = self.locationItems

end

function GUIMinimap:UninitializeLocationNames()

    for _, locationItem in ipairs(self.locationItems) do
        GUI.DestroyItem(locationItem.text)
    end
    
    self.locationItems = {}

end

function GUIMinimap:Uninitialize()

    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end
    
end

local function UpdatePlayerIcon(self)
    
    if PlayerUI_IsOverhead() and not PlayerUI_IsCameraAnimated() then -- Handle overhead viewplane points

        self.playerIcon:SetIsVisible(false)
        self.cameraLines:SetIsVisible(true)
        
        local topLeftPoint, topRightPoint, bottomLeftPoint, bottomRightPoint = OverheadUI_ViewFarPlanePoints()
        if topLeftPoint == nil then
            return
        end
        
        topLeftPoint = Vector(self:PlotToMap(topLeftPoint.x, topLeftPoint.z))
        topRightPoint = Vector(self:PlotToMap(topRightPoint.x, topRightPoint.z))
        bottomLeftPoint = Vector(self:PlotToMap(bottomLeftPoint.x, bottomLeftPoint.z))
        bottomRightPoint = Vector(self:PlotToMap(bottomRightPoint.x, bottomRightPoint.z))
        
        self.cameraLines:ClearLines()
        local lineColor = Color(1, 1, 1, 1)
        self.cameraLines:AddLine(topLeftPoint, topRightPoint, lineColor)
        self.cameraLines:AddLine(topRightPoint, bottomRightPoint, lineColor)
        self.cameraLines:AddLine(bottomRightPoint, bottomLeftPoint, lineColor)
        self.cameraLines:AddLine(bottomLeftPoint, topLeftPoint, lineColor)

    elseif PlayerUI_IsAReadyRoomPlayer() then
    
        // No icons for ready room players.
        self.cameraLines:SetIsVisible(false)
        self.playerIcon:SetIsVisible(false)

    else
    
        // Draw a player icon representing this player's position.
        local playerOrigin = PlayerUI_GetPositionOnMinimap()
        local playerRotation = PlayerUI_GetMinimapPlayerDirection()

        local posX, posY = self:PlotToMap(playerOrigin.x, playerOrigin.z)

        self.cameraLines:SetIsVisible(false)
        self.playerIcon:SetIsVisible(true)
        
        local playerIconColor = self.playerIconColor
        if playerIconColor ~= nil then
            playerIconColor = Color(playerIconColor.r, playerIconColor.g, playerIconColor.b, playerIconColor.a)
        elseif PlayerUI_IsOnMarineTeam() then
            playerIconColor = Color(kMarineTeamColorFloat)
        elseif PlayerUI_IsOnAlienTeam() then
            playerIconColor = Color(kAlienTeamColorFloat)
        else
            playerIconColor = Color(1, 1, 1, 1)
        end

        local animFraction = 1 - Clamp((Shared.GetTime() - self.timeMapOpened) / 0.5, 0, 1)
        playerIconColor.r = playerIconColor.r + animFraction
        playerIconColor.g = playerIconColor.g + animFraction
        playerIconColor.b = playerIconColor.b + animFraction
        playerIconColor.a = playerIconColor.a + animFraction
        
        local blipScale = self.blipScale
        local overLaySize = kShrinkingArrowInitSize * (animFraction * blipScale)
        local playerIconSize = Vector(kBlipSize * blipScale, kBlipSize * blipScale, 0)
        
        self.playerShrinkingArrow:SetSize(overLaySize)
        self.playerShrinkingArrow:SetPosition(-overLaySize * 0.5)
        local shrinkerColor = Color(playerIconColor.r, playerIconColor.g, playerIconColor.b, 0.35)
        self.playerShrinkingArrow:SetColor(shrinkerColor)

        self.playerIcon:SetSize(playerIconSize)        
        self.playerIcon:SetColor(playerIconColor)

        // move the background instead of the playericon in zoomed mode
        if self.moveBackgroundMode then
            local size = self.minimap:GetSize()
            local pos = Vector(-posX + size.x * -0.5, -posY + size.y * -0.5, 0)
            self.background:SetPosition(pos)
        end

        posX = posX - playerIconSize.x * 0.5
        posY = posY - playerIconSize.y * 0.5
        
        self.playerIcon:SetPosition(Vector(posX, posY, 0))
        
        local rotation = Vector(0, 0, playerRotation)
        
        self.playerIcon:SetRotation(rotation)
        self.playerShrinkingArrow:SetRotation(rotation)

        local playerClass = PlayerUI_GetPlayerClass()
        if self.playerClass ~= playerClass then

            local iconCol, iconRow = GetSpriteGridByClass(playerClass, kClassToGrid)
            self.playerIcon:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, kIconWidth, kIconHeight))
            self.playerClass = playerClass

        end

    end
    
end

function GUIMinimap:LargeMapIsVisible()
    return self.background:GetIsVisible() and self.comMode == GUIMinimapFrame.kModeBig
end 



local function CreateNewNameTag(self)
    local nameTag = GUIManager:CreateTextItem()

    nameTag:SetFontSize(kPlayerNameFontSize)
    nameTag:SetFontIsBold(false)
    nameTag:SetFontName(kPlayerNameFontName)
    nameTag:SetInheritsParentScaling(false)
    nameTag:SetScale(GetScaledVector())
    GUIMakeFontScale(nameTag)
    nameTag:SetAnchor(GUIItem.Middle, GUIItem.Center)
    nameTag:SetTextAlignmentX(GUIItem.Align_Center)
    nameTag:SetTextAlignmentY(GUIItem.Align_Center)
    nameTag:SetLayer(kPlayerNameLayer)
    nameTag:SetIsVisible(false)
    nameTag.lastUsed = Shared.GetTime()

    self.minimap:AddChild(nameTag)

    return nameTag
end

-- reuse nametags if they have not been used lately
local kNameTagReuseTimeout = 0.2

local function GetFreeNameTag(self, clientIndex)

    local now = Shared.GetTime()
    local nameTag = nil
    for _,v in pairs(self.nameTagMap) do
        if now - v.lastUsed > kNameTagReuseTimeout then
            nameTag = v
            self.nameTagMap[nameTag.clientIndex] = nil
            break
        end
    end
    if nameTag == nil then
        nameTag = CreateNewNameTag(self)
    end
    nameTag.clientIndex = clientIndex
    self.nameTagMap[clientIndex] = nameTag
    return nameTag
end

local function HideUnusedNameTags(self)
    local now = Shared.GetTime()
    local nameTag = nil
    for _,v in pairs(self.nameTagMap) do
        if now - v.lastUsed > kNameTagReuseTimeout then
            v:SetIsVisible(false)
        end
    end
    
end

-- Get the nameTag guiItem for the client
local function GetNameTag(self, clientIndex)
    local nameTag = self.nameTagMap[clientIndex]
    
    if not nameTag then
        nameTag = GetFreeNameTag(self, clientIndex)
    end
    
    return nameTag
    
end

local namePos = Vector(0, 0, 0)
function GUIMinimap:DrawMinimapName(item, blipTeam, clientIndex, isParasited)
  
    local drawName = self.spectating or MinimapMappableMixin.OnSameMinimapBlipTeam(self.playerTeam, blipTeam)
    
    if drawName and self.showPlayerNames and clientIndex > 0 then
        
        local record = Scoreboard_GetPlayerRecord( clientIndex )            

        if record and record.Name then
          
            local nameTag = GetNameTag(self, clientIndex)
            
            nameTag:SetIsVisible(true)    
            nameTag:SetText(record.Name)
            nameTag.lastUsed = Shared.GetTime()
            
            local nameColor = Color(1, 1, 1)
            if isParasited then
                nameColor.b = 0
            elseif self.spectating then
                if MinimapMappableMixin.OnSameMinimapBlipTeam(kMinimapBlipTeam.Marine, blipTeam) then
                    nameColor = kPlayerNameColorMarine
                else
                    nameColor = kPlayerNameColorAlien
                end
            elseif record.IsRookie then
                nameColor = Color( 0, 1, 0 )
            end

            nameTag:SetColor(nameColor)

            namePos = item:GetPosition() + GUIScale(kPlayerNameOffset)
            nameTag:SetPosition(namePos)

        end

    end

end
         

local function CreateIcon(self)

    local icon = table.remove(self.freeIcons)
    if not icon then
        icon = GUIManager:CreateGraphicItem()
        icon:SetAnchor(GUIItem.Middle, GUIItem.Center)
        icon:SetIsVisible(false)
        self.minimap:AddChild(icon)
    end
    -- will cause it to initialize on next call to update.
    icon.resetMinimapItem = true
    return icon
   
end

local function CreateIconForEntity(self, entity)
    local icon = CreateIcon(self)
    -- will cause it to initialize on next call to update.
    icon.resetMinimapItem = true
    -- save the entity this icon was created for; allows us to check if the entityId has been recycled
    icon.entity = entity
    return icon
end

local function CreateIconForKey(self, key)
    local icon = CreateIcon(self)
    icon.key = key
    return icon
end

local function FreeIcon(self, icon)
    icon:SetIsVisible(false)
    table.insert(self.freeIcons, icon)
end


local function UpdateBlipActivity(self)
    -- used to get a unique number to check if icons are in use
    local version = Shared.GetTime()
    
    for k,v in pairs(kMinimapActivity) do
        self.staticBlipData[k].blipIds = {}
        self.staticBlipData[k].count = 0
        self.staticBlipData[k].workIndex = 1
    end
    
    for index, entity in ientitylist(Shared.GetEntitiesWithTag("MinimapMappable")) do
        local id = entity:GetId()
        local icon = self.iconMap[id]
        if icon and icon.entity ~= entity then
            -- entity id has been recycled
            self.iconMap[id] = nil
            icon.entity = nil
            FreeIcon(self, icon)
        end
        if not self.iconMap[id] then
            self.iconMap[id] = CreateIconForEntity(self, entity)
        end
        local activity = entity:UpdateMinimapActivity(self, self.iconMap[id])
        if activity then
            local addBlip = true
            -- don't add things outside the update radius; saves CPU for marine HUD
            if self.updateRadius > 0 then
                local dist = self.playerOrigin - entity:GetMapBlipOrigin()
                addBlip = dist:GetLengthSquared() < self.updateRadiusSquared
            end
            if addBlip then 
                local data = self.staticBlipData[activity]
                table.insert(data.blipIds, id)
                data.count = data.count + 1             
                self.iconMap[id].version = version
            end
        end
    end
    
    -- clear out any icons no longer in use
    for id,icon in pairs(self.iconMap) do
        if icon.version ~= version then
            self.iconMap[id] = nil
            FreeIcon(self, icon)
        end
    end
 
    -- Log("ActivityUpdate, data %s, numIcons %s, numFreeIcons %s", self.staticBlipData, table.countkeys(self.iconMap), #self.freeIcons)
end

local function UpdateStaticIcon(self, entityId)
    local icon = entityId and self.iconMap[entityId]
    if icon then
        local entity = Shared.GetEntity(entityId)
        -- need to make sure that the entity has not been destroyed and replaced by another entity
        -- can happen in intense games...
        if not entity or icon.entity ~= entity then
            icon:SetIsVisible(false)
        else
            entity:UpdateMinimapItem(self, icon)
        end
    end
end

local function UpdateActivityBlips_While(self, deltaTime, activity)
    local data = self.staticBlipData[activity]
    if data.workIndex > data.count then
        data.workIndex = 1
    end
    local updateInterval = kBlipActivityUpdateInterval[activity] * GUIMinimap.kUpdateIntervalMultipler * self.updateIntervalMultipler
    local numBlipsToUpdateThisTime = 0
    if updateInterval > deltaTime then
        -- partial update
        numBlipsToUpdateThisTime = 1 + math.floor(deltaTime * data.count / updateInterval )
    else
        -- full update; reset workIndex
        numBlipsToUpdateThisTime = data.count            
        data.workIndex = 1    
    end
    local startIndex = data.workIndex
    local endIndex = math.min(data.count, data.workIndex + numBlipsToUpdateThisTime)
    if self.resetAll then
        startIndex = 1
        endIndex = data.count
    end
    -- Log("Update %s %s-%s (%s), ui %s", EnumToString(kMinimapActivity, activity), startIndex, endIndex, data.count, updateInterval)
    // Try to avoid issues with LuaJIT (may skip this??)
    TraceStopPoint()
    // using a foor loop here causes LuaJIT issues for some reason
    local i = startIndex
    while (i <= endIndex) do
        UpdateStaticIcon(self, data.blipIds[i])
        i = i + 1
    end
    data.workIndex = data.workIndex + numBlipsToUpdateThisTime
end


/* For profiling 
local function UpdateStatic(self, deltaTime)
    PROFILE("GUIMinimap:UpdateStaticBlips:Static")
    UpdateActivityBlips(self, deltaTime, kMinimapActivity.Static)
end

local function UpdateLow(self, deltaTime)
    PROFILE("GUIMinimap:UpdateStaticBlips:Low")
    UpdateActivityBlips(self, deltaTime, kMinimapActivity.Low)
end

local function UpdateMedium(self, deltaTime)
    PROFILE("GUIMinimap:UpdateStaticBlips:Medium")
    UpdateActivityBlips(self, deltaTime, kMinimapActivity.Medium)
end

local function UpdateHigh(self, deltaTime)
    PROFILE("GUIMinimap:UpdateStaticBlips:High")
    UpdateActivityBlips(self, deltaTime, kMinimapActivity.High)
end
*/


local function UpdateStaticBlips(self, deltaTime)
    -- update icons for each activity level
    -- loop unrolling to avoid trigger a presumed LuaJIT bug
    UpdateActivityBlips_While(self, deltaTime, kMinimapActivity.Static )
    UpdateActivityBlips_While(self, deltaTime, kMinimapActivity.Low )
    UpdateActivityBlips_While(self, deltaTime, kMinimapActivity.Medium )
    UpdateActivityBlips_While(self, deltaTime, kMinimapActivity.High )
  
    /*
    -- do like this just to get profiling
    UpdateStatic(self, deltaTime)
    UpdateLow(self, deltaTime)
    UpdateMedium(self, deltaTime)
    UpdateHigh(self, deltaTime)
    */
    
end

local function UpdateScansAndHighlight(self)
    local blipSize = self.blipSizeTable[kBlipSizeType.Normal]
    
    // Update scan blip size and color.    
    do 
        local scanAnimFraction = (Shared.GetTime() % kScanAnimDuration) / kScanAnimDuration        
        local scanBlipScale = 1.0 + scanAnimFraction * 9.0 // size goes from 1.0 to 10.0
        local scanAnimAlpha = 1 - scanAnimFraction
        scanAnimAlpha = scanAnimAlpha * scanAnimAlpha
        
        self.scanColor.a = scanAnimAlpha
        self.scanSize.x = blipSize.x * scanBlipScale // do not change blipSizeTable reference
        self.scanSize.y = blipSize.y * scanBlipScale // do not change blipSizeTable reference
    end
    
    local highlightPos, highlightTime = GetHighlightPosition()
    if highlightTime then
    
        local createAnimFraction = 1 - Clamp((Shared.GetTime() - highlightTime) / 1.5, 0, 1)
        local sizeAnim = (1 + math.sin(Shared.GetTime() * 6)) * 0.25 + 2
    
        local blipScale = createAnimFraction * 15 + sizeAnim

        self.highlightWorldSize.x = blipSize.x * blipScale
        self.highlightWorldSize.y = blipSize.y * blipScale
        
        self.highlightWorldColor.a = 0.7 + 0.2 * math.sin(Shared.GetTime() * 5) + createAnimFraction
    
    end
    
    local etherealGateAnimFraction = 0.25 + (1 + math.sin(Shared.GetTime() * 10)) * 0.5 * 0.75
    self.etherealGateColor.a = etherealGateAnimFraction
    
    self.blipSizeTable[kBlipSizeType.Scan] = self.scanSize
    self.blipSizeTable[kBlipSizeType.HighlightWorld] = self.highlightWorldSize
    
end

local function GetFreeDynamicBlip(self, xPos, yPos, blipType)

    local returnBlip
    if table.count(self.reuseDynamicBlips) > 0 then
    
        returnBlip = table.remove(self.reuseDynamicBlips)
        table.insert(self.inuseDynamicBlips, returnBlip)
        
    else
        
        local returnBlipItem = GUIManager:CreateGraphicItem()
        returnBlipItem:SetLayer(kDynamicBlipsLayer) // Make sure these draw a layer above the minimap so they are on top.
        returnBlipItem:SetTexture(kBlipTexture)
        returnBlipItem:SetBlendTechnique(GUIItem.Add)
        returnBlipItem:SetAnchor(GUIItem.Middle, GUIItem.Center)
        self.minimap:AddChild(returnBlipItem)
        
        returnBlip = { Item = returnBlipItem }
        table.insert(self.inuseDynamicBlips, returnBlip)
        
    end
    
    returnBlip.X = xPos
    returnBlip.Y = yPos
    returnBlip.Type = blipType
    
    local returnBlipItem = returnBlip.Item
    
    returnBlipItem:SetIsVisible(true)
    returnBlipItem:SetColor(Color(1, 1, 1, 1))
    returnBlipItem:SetPosition(Vector(self:PlotToMap(xPos, yPos)))
    GUISetTextureCoordinatesTable(returnBlipItem, kBlipTextureCoordinates[blipType])
    returnBlipItem:SetStencilFunc(self.stencilFunc)
    
    return returnBlip
    
end

local function AddDynamicBlip(self, xPos, yPos, blipType)

    /**
     * Blip types - kAlertType
     * 
     * 0 - Attack
     * Attention-getting spinning squares that start outside the minimap and spin down to converge to point 
     * on map, continuing to draw at point for a few seconds).
     * 
     * 1 - Info
     * Research complete, area blocked, structure couldn't be built, etc. White effect, not as important to
     * grab your attention right away).
     * 
     * 2 - Request
     * Soldier needs ammo, asking for order, etc. Should be yellow or green effect that isn't as 
     * attention-getting as the under attack. Should draw for a couple seconds.)
     */
    
    if blipType == kAlertType.Attack then
    
        addedBlip = GetFreeDynamicBlip(self, xPos, yPos, blipType)
        addedBlip.Item:SetSize(Vector(0, 0, 0))
        addedBlip.Time = Shared.GetTime() + kAttackBlipTime
        
    end
    
end

// Initialize a minimap item (icon) from a blipType
function GUIMinimap:InitMinimapIcon(item, blipType, blipTeam)
  
    local blipInfo = self.blipInfoTable[blipType]
    local texCoords, colorType, sizeType, layer = unpack(blipInfo)
    
    item.blipType = blipType
    item.blipSizeType = sizeType
    item.blipSize = self.blipSizeTable[item.blipSizeType]
    item.blipTeam = blipTeam      
    item.blipColor = self.blipColorTable[item.blipTeam][colorType]
    
    item:SetLayer(layer)
    item:SetTexturePixelCoordinates(unpack(texCoords))
    item:SetSize(item.blipSize)
    item:SetColor(item.blipColor)
    item:SetStencilFunc(self.stencilFunc)
    item:SetTexture(self.iconFileName)
    item:SetIsVisible(true)
    
    item.resetMinimapItem = false
    
    return item
end

local _blipPos = Vector(0,0,0) -- avoid GC
function GUIMinimap:UpdateBlipPosition(item, origin)
    if origin ~= item.prevBlipOrigin then
        item.prevBlipOrigin = origin
        local xPos, yPos = self:PlotToMap(origin.x, origin.z)
        _blipPos.x = xPos - item.blipSize.x * 0.5
        _blipPos.y = yPos - item.blipSize.y * 0.5
        item:SetPosition(_blipPos)
    end
end
     

local function AddLocalBlip(self, key, position, blipType, blipTeam)
  
    local blip = {}
    blip.key = key
    blip.position = position
    blip.blipType = blipType
    blip.blipTeam = blipTeam
    blip.icon = CreateIconForKey(self, key)
    
    self.localBlipData[key] = blip
    
    return blip
    
end

local function RemoveLocalBlip(self, key)
    local blip = self.localBlipData[key]
    if blip then
        local icon = blip.icon
        if icon then
            FreeIcon(self, icon)
        end
        self.localBlipData[key] = nil
    end
end

local function DrawLocalBlip(self, blipData)
    
    local icon = blipData.icon
    if icon.resetMinimapItem then
        self:InitMinimapIcon(icon, blipData.blipType, blipData.blipTeam)
    end
    
    self:UpdateBlipPosition(icon, blipData.position)
    
end

local function DrawLocalBlips(self)
    for key,blipData in pairs(self.localBlipData) do
        DrawLocalBlip(self, blipData)
    end
    
end


// update the list of non-entity related mapblips
local function UpdateLocalBlips(self)
  
    local key = "spawn"
    local blip = self.localBlipData[key]
    local active = false
    if GetPlayerIsSpawning() then
        local spawnPosition = GetDesiredSpawnPosition()        
        if spawnPosition then
            if not blip then
                blip = AddLocalBlip(self, key, spawnPosition, kMinimapBlipType.MoveOrder, kMinimapBlipTeam.Friendly)   
            end
            active = true      
            blip.position = spawnPosition
        end
    end
    if not active and blip then
        RemoveLocalBlip(self, key)
    end
    
    key = "highlight"
    blip = self.localBlipData[key] 
    active = false
    local highlightPos = GetHighlightPosition()
    if highlightPos then
        if not blip then
            blip = AddLocalBlip(self, key, highlightPos, kMinimapBlipType.HighlightWorld, kMinimapBlipTeam.Friendly)
        end        
    end
    if not active and blip then

        RemoveLocalBlip(self, key) 
    end
    
end
   
local function RemoveDynamicBlip(self, blip)

    blip.Item:SetIsVisible(false)
    table.removevalue(self.inuseDynamicBlips, blip)
    table.insert(self.reuseDynamicBlips, blip)
    
end

local function UpdateAttackBlip(self, blip)
    local blipLifeRemaining = blip.Time - Shared.GetTime()
    local blipItem = blip.Item
    // Fade in.
    if blipLifeRemaining >= kAttackBlipFadeInTime then
    
        local fadeInAmount = ((kAttackBlipTime - blipLifeRemaining) / (kAttackBlipTime - kAttackBlipFadeInTime))
        blipItem:SetColor(Color(1, 1, 1, fadeInAmount))
        
    else
        blipItem:SetColor(Color(1, 1, 1, 1))
    end
    
    // Fade out.
    if blipLifeRemaining <= kAttackBlipFadeOutTime then
    
        if blipLifeRemaining <= 0 then
            return true
        end
        blipItem:SetColor(Color(1, 1, 1, blipLifeRemaining / kAttackBlipFadeOutTime))
        
    end
    
    local pulseAmount = (math.sin(blipLifeRemaining * kAttackBlipPulseSpeed) + 1) / 2
    local blipSize = LerpGeneric(kAttackBlipMinSize, kAttackBlipMaxSize / 2, pulseAmount)
    
    blipItem:SetSize(blipSize)
    // Make sure it is always centered.
    local sizeDifference = kAttackBlipMaxSize - blipSize
    local xOffset = (sizeDifference.x / 2) - kAttackBlipMaxSize.x / 2
    local yOffset = (sizeDifference.y / 2) - kAttackBlipMaxSize.y / 2
    local plotX, plotY = self:PlotToMap(blip.X, blip.Y)
    blipItem:SetPosition(Vector(plotX + xOffset, plotY + yOffset, 0))
    
    // Not done yet.
    return false
    
end

local function UpdateDynamicBlips(self)
    PROFILE("GUIMinimap:UpdateDynamicBlips")
    
    local newDynamicBlips = CommanderUI_GetDynamicMapBlips()
    local blipItemCount = 3
    local numBlips = table.count(newDynamicBlips) / blipItemCount
    local currentIndex = 1
    
    while numBlips > 0 do
    
        local blipType = newDynamicBlips[currentIndex + 2]
        AddDynamicBlip(self, newDynamicBlips[currentIndex], newDynamicBlips[currentIndex + 1], blipType)
        currentIndex = currentIndex + blipItemCount
        numBlips = numBlips - 1
        
    end
    
    local removeBlips = { }
    for _, blip in ipairs(self.inuseDynamicBlips) do
    
        if blip.Type == kAlertType.Attack then
        
            if UpdateAttackBlip(self, blip) then
                table.insert(removeBlips, blip)
            end
            
        end
    end
    
    for _, blip in ipairs(removeBlips) do
        RemoveDynamicBlip(self, blip)
    end
    
end
local function UpdateColorNames(self)

    if self.locationItems ~= nil then
    //Change Siege/Front names to Red, Blue for rooms with built powernode and Green for Rooms with unbuilt/killed node. 

        for _, locationItem in ipairs(self.locationItems) do
       local room = locationItem.name
    //   local built = false
       local color = Color(1.0, 1.0, 1.0, 0.65)
             local powerpoint = GetPowerPointForLocation(room)
             if powerpoint ~= nil then
                if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then 
                   //     built = true
                        color = Color(20/255, 127/255, 209/55, 1)
                elseif powerpoint:GetIsDisabled() or  powerpoint:GetIsSocketed() then     
                        color = Color(18/255, 231/255, 22/255, 1)
                end
                   SetLocationTextColor( locationItem, color )
                   //Print("Room is %s, built is %s", room, built )
              end
        end
    end
    
end

local function UpdateMapClick(self)

    if PlayerUI_IsOverhead() then
    
        // Don't teleport if the command is dragging a selection or pinging.
        if PlayerUI_IsACommander() and (not CommanderUI_GetUIClickable() or GetCommanderPingEnabled()) then
            return
        end
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if self.mouseButton0Down then
        
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.minimap, mouseX, mouseY)
            if containsPoint then
            
                local minimapSize = self:GetMinimapSize()
                local backgroundScreenPosition = self.minimap:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
                
                local cameraPosition = Vector(mouseX, mouseY, 0)
                
                cameraPosition.x = cameraPosition.x - backgroundScreenPosition.x
                cameraPosition.y = cameraPosition.y - backgroundScreenPosition.y
                
                local horizontalScale = OverheadUI_MapLayoutHorizontalScale()
                local verticalScale = OverheadUI_MapLayoutVerticalScale()
                
                local moveX = (cameraPosition.x / minimapSize.x) * horizontalScale
                local moveY = (cameraPosition.y / minimapSize.y) * verticalScale
                
                OverheadUI_MapMoveView(moveX, moveY)
                
            end
            
        end
        
    end
    
end

local function UpdateConnections(self)
    local mapConnectors = Shared.GetEntitiesWithClassname("MapConnector")
    local numConnectors = 0
    for index, connector in ientitylist(mapConnectors) do

        if not self.minimapConnections[index] then
            self.minimapConnections[index] = GUIMinimapConnection()
            self.minimapConnections[index]:SetStencilFunc(self.stencilFunc)
        end
        
        local startPoint = Vector(self:PlotToMap(connector:GetOrigin().x, connector:GetOrigin().z))
        local endPoint = Vector(self:PlotToMap(connector:GetEndPoint().x, connector:GetEndPoint().z))
        
        self.minimapConnections[index]:Setup(startPoint, endPoint, self.minimap)
        
        self.minimapConnections[index]:UpdateAnimation(connector:GetTeamNumber(), self.comMode == GUIMinimapFrame.kModeMini)
        
        numConnectors = numConnectors + 1
        
    end
    
    local numMinimapConnections = #self.minimapConnections    
    if numConnectors < numMinimapConnections then
    
        for i = 1, numMinimapConnections - numConnectors do
        
            local lastIndex = #self.minimapConnections
            local minimapConnection = self.minimapConnections[lastIndex]
            minimapConnection:Uninitialize()
            self.minimapConnections[lastIndex] = nil
        
        end
    
    end

    //Print("num minimap connections %s", ToString(#self.minimapConnections))

end

local function UpdateCommanderPing(self)
    // update commander ping
    if self.commanderPing then
      
        for index, entity in ientitylist(Shared.GetEntitiesWithClassname("TeamInfo")) do
          
            local pingTime = entity:GetPingTime()
            
            if pingTime ~= self.commanderPing.expiredPingTime then
              
                local player = Client.GetLocalPlayer()
                local timeSincePing, position, distance, locationName = PlayerUI_GetPingInfo(player, entity, true)
                local posX, posY = self:PlotToMap(position.x, position.z)
                self.commanderPing.Frame:SetPosition(Vector(posX, posY, 0))
                self.commanderPing.Frame:SetIsVisible(timeSincePing <= kCommanderPingDuration)
                
                local expired = GUIAnimateCommanderPing(self.commanderPing.Mark, self.commanderPing.Border, self.commanderPing.Location, kCommanderPingMinimapSize, timeSincePing, Color(1, 0, 0, 1), Color(1, 1, 1, 1))
                if expired then
                    -- block ping animation now that it has expired
                    self.commanderPing.expiredPingTime = pingTime
                end
                
            end
            -- only do it for the first found TeamInfo - should be only one?
            break               
        end
    end
end

-- once we hit the misc update time, we step through each function and do them one per frame... spreads the load a bit
local kMiscUpdateStepFunctions = {
    UpdateDynamicBlips,         
    UpdateConnections,
    UpdateScansAndHighlight,
    UpdateCommanderPing,
    UpdateLocalBlips,
}

function GUIMinimap:Update(deltaTime)
    Client.SetDebugText("GUIMinimap:Update")
    if self.background:GetIsVisible() then
    
        PROFILE("GUIMinimap:Update")
                    
        local now = Shared.GetTime()
        local player = Client.GetLocalPlayer()
        
        // need to recalc the player team because it may have changed
        // maybe smarter to rebuild gui scripts on team change...
        local playerTeam = player:GetTeamNumber()
        if playerTeam == kMarineTeamType then
            playerTeam = kMinimapBlipTeam.Marine
        elseif playerTeam == kAlienTeamType then
            playerTeam = kMinimapBlipTeam.Alien
        end
        self.playerTeam = playerTeam
        
        self.playerOrigin = player:GetOrigin()
        
        if now > self.nextMiscUpdateInterval and not self.miscUpdateStep then
          
            self.nextMiscUpdateInterval = now + kMiscUpdateInterval * GUIMinimap.kUpdateIntervalMultipler * self.updateIntervalMultipler
            self.miscUpdateStep = 1
        
        end
        
        if self.miscUpdateStep then
          
            kMiscUpdateStepFunctions[self.miscUpdateStep](self)
            self.miscUpdateStep = self.miscUpdateStep + 1
            if self.miscUpdateStep > #kMiscUpdateStepFunctions then
                self.miscUpdateStep = nil
            end
            
        end   
        

        UpdatePlayerIcon(self)
        UpdateMapClick(self)
        
       UpdateColorNames(self)
                 
        UpdateStaticBlips(self, deltaTime)  
        DrawLocalBlips(self)
        
        if now > self.nextActivityUpdateTime then
            self.nextActivityUpdateTime = now + kActivityUpdateInterval * GUIMinimap.kUpdateIntervalMultipler * self.updateIntervalMultipler 
            UpdateBlipActivity(self)
            -- do other things we only need to do very rarely..
            HideUnusedNameTags(self)
            local optionsMinimapNames = Client.GetOptionBoolean("minimapNames", true)
            self.showPlayerNames = optionsMinimapNames == true and self:LargeMapIsVisible()
            self.spectating = player:GetTeamType() == kNeutralTeamType
            self.clientIndex = player:GetClientIndex()
            local r = self.updateRadius / self.scale
            self.updateRadiusSquared = r*r
        end
        
        self.resetAll = false
        
    end
    
end

function GUIMinimap:GetMinimapSize()
    return Vector(GUIMinimap.kBackgroundWidth * self.scale, GUIMinimap.kBackgroundHeight * self.scale, 0)
end

// Shows or hides the big map.
function GUIMinimap:ShowMap(showMap)

    if self.background:GetIsVisible() ~= showMap then
    
        self.background:SetIsVisible(showMap)
        if showMap then
        
            self.timeMapOpened = Shared.GetTime()
            self:Update(0)
            
        end
        
    end
    
end

function GUIMinimap:OnLocalPlayerChanged(newPlayer)
    self:ShowMap(false)
end

function GUIMinimap:SendKeyEvent(key, down)

    if PlayerUI_IsOverhead() then
    
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.minimap, mouseX, mouseY)
        
        if key == InputKey.MouseButton0 then
            self.mouseButton0Down = down
        elseif PlayerUI_IsACommander() and key == InputKey.MouseButton1 then
        
            if down and containsPoint then
            
                if self.buttonsScript then
                
                    // Cancel just in case the user had a targeted action selected before this press.
                    CommanderUI_ActionCancelled()
                    self.buttonsScript:SetTargetedButton(nil)
                    
                end
                
                OverheadUI_MapClicked(withinX / self:GetMinimapSize().x, withinY / self:GetMinimapSize().y, 1, nil)
                return true
                
            end
            
        end
        
    end
    
    return false

end

function GUIMinimap:ContainsPoint(pointX, pointY)
    return GUIItemContainsPoint(self.background, pointX, pointY) or GUIItemContainsPoint(self.minimap, pointX, pointY)
end

function GUIMinimap:GetBackground()
    return self.background
end

function GUIMinimap:GetMinimapItem()
    return self.minimap
end

function GUIMinimap:SetButtonsScript(setButtonsScript)
    self.buttonsScript = setButtonsScript
end

function GUIMinimap:SetLocationNamesEnabled(enabled)
    for _, locationItem in ipairs(self.locationItems) do
        locationItem.text:SetIsVisible(enabled)
    end
end

-- set the resetAll flag; next Update() all blips will be fully updated (avoids uglyness when zooming)
function GUIMinimap:ResetAll()
    self.resetAll = true
    for id, icon in pairs(self.iconMap) do
        icon.resetMinimapItem = true
    end
end

function GUIMinimap:SetScale(scale)
    if scale ~= self.scale then
        self.scale = scale
        self:ResetAll()
        
        // compute map to minimap transformation matrix
        local xFactor = 2 * self.scale
        local mapRatio = ConditionalValue(Client.minimapExtentScale.z > Client.minimapExtentScale.x, Client.minimapExtentScale.z / Client.minimapExtentScale.x, Client.minimapExtentScale.x / Client.minimapExtentScale.z)
        local zFactor = xFactor / mapRatio
        self.plotToMapConstX = -Client.minimapExtentOrigin.x
        self.plotToMapConstY = -Client.minimapExtentOrigin.z
        self.plotToMapLinX = GUIMinimap.kBackgroundHeight / (Client.minimapExtentScale.x / xFactor)
        self.plotToMapLinY = GUIMinimap.kBackgroundWidth / (Client.minimapExtentScale.z / zFactor)
        
        // update overview size
        if self.minimap then
          local size = Vector(GUIMinimap.kBackgroundWidth * scale, GUIMinimap.kBackgroundHeight * scale, 0)
          self.minimap:SetSize(size)
        end

        // reposition location names
        if self.locationItems then
          for _, locationItem in ipairs(self.locationItems) do
            local mapPos = Vector(self:PlotToMap(locationItem.origin.x, locationItem.origin.z ))
            SetLocationTextPosition( locationItem, mapPos )
          end
        end
      
    end
end

function GUIMinimap:GetScale()
    return self.scale
end

function GUIMinimap:SetBlipScale(blipScale)

    if blipScale ~= self.blipScale then
    
        self.blipScale = blipScale
        self:ResetAll()
    
        local blipSizeTable = self.blipSizeTable
        local blipSize = Vector(kBlipSize, kBlipSize, 0)
        blipSizeTable[kBlipSizeType.Normal] = blipSize * (0.7 * blipScale)
        blipSizeTable[kBlipSizeType.TechPoint] = blipSize * blipScale
        blipSizeTable[kBlipSizeType.Infestation] = blipSize * (2 * blipScale)
        blipSizeTable[kBlipSizeType.Egg] = blipSize * (0.7 * 0.5 * blipScale)
        blipSizeTable[kBlipSizeType.Worker] = blipSize * (blipScale)
        blipSizeTable[kBlipSizeType.EtherealGate] = blipSize * (1.5 * blipScale)
        blipSizeTable[kBlipSizeType.Waypoint] = blipSize * (1.5 * blipScale)
        blipSizeTable[kBlipSizeType.BoneWall] = blipSize * (1.5 * blipScale)
        blipSizeTable[kBlipSizeType.UnpoweredPowerPoint] = blipSize * (0.45 * blipScale)
                
    end
    
end

function GUIMinimap:GetBlipScale(blipScale)
    return self.blipScale
end

function GUIMinimap:SetMoveBackgroundEnabled(enabled)
    self.moveBackgroundMode = enabled
end

function GUIMinimap:SetStencilFunc(stencilFunc)

    self.stencilFunc = stencilFunc
    
    self.minimap:SetStencilFunc(stencilFunc)
    self.commanderPing.Mark:SetStencilFunc(stencilFunc)
    self.commanderPing.Border:SetStencilFunc(stencilFunc)
    
    for _, blip in ipairs(self.inuseDynamicBlips) do
        blip.Item:SetStencilFunc(stencilFunc)
    end
    
    for id,icon in pairs(self.iconMap) do
        icon:SetStencilFunc(stencilFunc)
    end
    
    for _, connectionLine in ipairs(self.minimapConnections) do
        connectionLine:SetStencilFunc(stencilFunc)
    end
    
end

function GUIMinimap:SetPlayerIconColor(color)
    self.playerIconColor = color
end

function GUIMinimap:SetIconFileName(fileName)
    local iconFileName = ConditionalValue(fileName, fileName, kIconFileName)
    self.iconFileName = iconFileName
    
    self.playerIcon:SetTexture(iconFileName)
    for id,icon in pairs(self.iconMap) do
        icon:SetTexture(iconFileName)
    end
end

function OnToggleMinimapNames()
    if Client.GetOptionBoolean("minimapNames", true) then
        Client.SetOptionBoolean("minimapNames", false)
        Shared.Message("Minimap Names is now set to OFF")
    else
        Client.SetOptionBoolean("minimapNames", true)
        Shared.Message("Minimap Names is now set to ON")
    end
end

function OnChangeMinimapUpdateRate(mul)
    if Client then
        if mul then
            GUIMinimap.kUpdateIntervalMultipler = Clamp(tonumber(mul), 0, 5)
        end
        Log("Minimap update interval multipler: %s", GUIMinimap.kUpdateIntervalMultipler)
    end
end

function OnCommandUseLoop()
    if Client then
        GUIMinimap.kDebugIndex = GUIMinimap.kDebugIndex == 2 and 0 or GUIMinimap.kDebugIndex + 1
        Log("DebugIndex = %s (0 = unrolled (ok), 1 == loop/while (ok), 2 = loop/for (freeze sometimes))", GUIMinimap.kDebugIndex)
    end
end

Event.Hook("Console_minimap_rate", OnChangeMinimapUpdateRate)
Event.Hook("Console_minimapnames", OnToggleMinimapNames)
Event.Hook("Console_setmaplocationcolor", OnCommandSetMapLocationColor)
