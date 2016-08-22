--Thanks Last Stand
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/Siege_TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/Siege_TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/Siege_MarineTeam.lua", "post" )--Thanks modular exo
ModLoader.SetupFileHook( "lua/AlienTeam.lua", "lua/Siege_AlienTeam.lua", "post" )--Thanks modular exo
ModLoader.SetupFileHook( "lua/ConstructMixin.lua", "lua/MixinMods/FastBuildSetup.lua", "post" )


ModLoader.SetupFileHook( "lua/GUIInsight_TopBar.lua", "lua/Siege_GUIInsight_TopBar.lua", "replace" )

