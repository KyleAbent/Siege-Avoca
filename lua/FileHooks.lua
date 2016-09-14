--https://github.com/KyleAbent/
--Thanks Last Stand
--Thanks modular exo
--thanks dragon
-- thanks EEM
--Hello Ghoul! IronHorse, whomever else really, the unnamed.
--For my own organizational sake it will be easier to have each file the same as ns2 with a simple _Siege at the end.

-- is /pre/post limited with networkvar modification? hm



ModLoader.SetupFileHook( "lua/Globals.lua", "lua/Globals_Siege.lua", "post" )

ModLoader.SetupFileHook( "lua/ArmsLab.lua", "lua/ArmsLab_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/InfantryPortal.lua", "lua/InfantryPortal_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/PhaseGate.lua", "lua/PhaseGate_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/PrototypeLab.lua", "lua/PrototypeLab_Siege.lua", "post" )

ModLoader.SetupFileHook( "lua/Tunnel.lua", "lua/Tunnel_Siege.lua", "post" )


ModLoader.SetupFileHook( "lua/NetworkMessages.lua", "lua/NetworkMessages_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/NetworkMessages_Server.lua", "lua/NetworkMessages_Server_Siege.lua", "post" )

ModLoader.SetupFileHook( "lua/GUIGorgeBuildMenu.lua", "lua/GUIGorgeStructBuildMenu.lua", "post" )


ModLoader.SetupFileHook( "lua/JetpackMarine.lua", "lua/JetpackMarine_Siege.lua", "post" ) 


ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/MarineTeam_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienTeam.lua", "lua/AlienTeam_Siege.lua", "post" )
--ModLoader.SetupFileHook( "lua/PlayingTeam.lua", "lua/PlayingTeam_Siege.lua", "post" )
--ModLoader.SetupFileHook( "lua/ConstructMixin.lua", "lua/ConstructMixin_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/Lerk.lua", "lua/Additions/PrimalScream.lua", "pre" ) 
ModLoader.SetupFileHook( "lua/Crag.lua", "lua/Crag_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Clog.lua", "lua/Clog_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Whip.lua", "lua/Whip_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Shift.lua", "lua/Shift_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Shade.lua", "lua/Shade_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/CommandStation.lua", "lua/CommandStation_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Location.lua", "lua/Location_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Observatory.lua", "lua/Observatory_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Armory.lua", "lua/Armory_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Lerk.lua", "lua/Lerk_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/Fade.lua", "lua/Fade_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/Gorge.lua", "lua/Gorge_Pre.lua", "pre" )
ModLoader.SetupFileHook( "lua/Gorge.lua", "lua/Gorge_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/Onos.lua", "lua/Onos_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/Sentry.lua", "lua/Sentry_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Hydra.lua", "lua/Hydra_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/ARC.lua", "lua/ARC_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/MAC.lua", "lua/MAC_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/MAC.lua", "lua/MAC_Credits.lua", "post" ) 
ModLoader.SetupFileHook( "lua/ARC.lua", "lua/ARC_Credits.lua", "post" )
ModLoader.SetupFileHook( "lua/GhostModel.lua", "lua/GhostModel_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/AlienCommander.lua", "lua/AlienCommander_Siege.lua", "post" ) 
ModLoader.SetupFileHook( "lua/Alien.lua", "lua/Alien_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/Hive.lua", "lua/Hive_Siege.lua", "post" ) --lulz
ModLoader.SetupFileHook( "lua/Skulk.lua", "lua/Skulk_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/Marine_Siege.lua", "post" ) --lulz, hive siege
--ModLoader.SetupFileHook( "lua/MarineOutlineMixin.lua", "lua/MarineOutlineMixin_Siege.lua", "post" )
--ModLoader.SetupFileHook( "lua/HiveVisionMixin.lua", "lua/HiveVisionMixin_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/RoboticsFactory.lua", "lua/RoboticsFactory_Siege.lua", "replace" ) -- for now anyway
--ModLoader.SetupFileHook( "lua/PowerPointLightHandler.lua", "lua/PowerPointLightHandler_Siege.lua", "post" ) -- for now anyway
--ModLoader.SetupFileHook( "lua/AchievementReceiverMixin.lua", "lua/AchievementReceiverMixin_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/Balance_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceHealth.lua", "lua/BalanceHealth_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/PowerPoint.lua", "lua/PowerPoint_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/NS2Utility_Siege.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/NS2Gamerules.lua", "lua/NS2Gamerules_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/CommAbilities/Alien/Contamination.lua", "lua/CommAbilities/Alien/Contamination_Siege.lua", "post" )
--ModLoader.SetupFileHook( "lua/ARC.lua", "lua/AvocaArc.lua", "post" ) --includes server
ModLoader.SetupFileHook( "lua/Alien_Client.lua", "lua/Alien_Client_Siege.lua", "post" ) 



ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/TechTreeConstants_Siege.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/TechData_Siege.lua", "post" )