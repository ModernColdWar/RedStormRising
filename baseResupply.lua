---- Name: Client-Transport Resupply 
-- Author: Wildcat (Chandawg) with significant help from Wingthor#5182 on the moose Discord
-- Date Created: 11 May 2020

----Templates for the re-enforcements, these are late activated and near sevasatapol ukraine in the mission editor
--

Spawn_Red_Defenses = { 'SAM HQ-7',
                      'SAM SA-13',
                      'SAM SA-15',
                      'SAM SA-19',
                      'MBT T90',
                      'IFV BMP-3',
                      'SPAAA Shilka',
                      'SAM SA-11 Buk',
                      'SAM SA-10'
                      } 
Spawn_Blue_Defenses = { 'SAM Roland',
                      'SAM Gepard',
                      'SAM Linebacker',
                      'SAM Avenger',
                      'MBT M1A2',
                      'SPG M1128',
                      'SAM Hawk',
                      'SAM Patriot'
                      } 

----This finds 6 units on the map and establishes the HQ which issue the tasks, they are not late activated but placed near sevastapol as well to keep them from influencing RSR capture logic. If they are destroyed they can't issue tasks, in the future, we could make regional command centers/radio towers that spawn on restart based on the previous base ownership, but that is a ways off.
RedHQ_North = GROUP:FindByName( "Northern Red HQ" )
RedHQ_South = GROUP:FindByName( "Southern Red HQ" )
--Blue
BlueHQ_North = GROUP:FindByName( "Northern Blue HQ" )
BlueHQ_South = GROUP:FindByName( "Southern Blue HQ" )

RedCommandCenterNorth = COMMANDCENTER
  :New( RedHQ_North, "Northern Command" )
RedCommandCenterSouth = COMMANDCENTER
  :New( RedHQ_South, "Southern Command" )
--Blue
BlueCommandCenterNorth = COMMANDCENTER
  :New( BlueHQ_North, "Northern Command" )
BlueCommandCenterSouth = COMMANDCENTER
  :New( BlueHQ_South, "Southern Command" )
----This designates the Missions/Tasks
-- Red_KrasC_Resupply_Mission = MISSION
  -- :New( RedCommandCenterNorth, "Resupply from Kras-C", " ", " ", coalition.side.RED )
Red_Maykop_Resupply_Mission = MISSION
  :New( RedCommandCenterNorth, "Resupply from Maykop", " ", " ", coalition.side.RED )
Red_Sochi_Resupply_Mission = MISSION
  :New( RedCommandCenterSouth, "Resupply from Sochi", " ", " ", coalition.side.RED )
-- Red_Anapa_Resupply_Mission = MISSION
  -- :New( RedCommandCenterNorth, "Resupply from Anapa", " ", " ", coalition.side.RED )
-- Red_Gelendzhik_Resupply_Mission = MISSION
  -- :New( RedCommandCenterNorth, "Resupply from Gelendzhik", " ", " ", coalition.side.RED )
Red_MineralnyeVody_Resupply_Mission = MISSION
  :New( RedCommandCenterNorth, "Resupply from MineralnyeVody", " ", " ", coalition.side.RED )
Red_Nalchik_Resupply_Mission = MISSION
  :New( RedCommandCenterNorth, "Resupply from Nalchik", " ", " ", coalition.side.RED )
Red_Mozdok_Resupply_Mission = MISSION
  :New( RedCommandCenterNorth, "Resupply from Mozdok", " ", " ", coalition.side.RED )
Red_Vaziani_Resupply_Mission = MISSION
  :New( RedCommandCenterSouth, "Resupply from Vaziani", " ", " ", coalition.side.RED )
Red_Sukhumi_Resupply_Mission = MISSION
  :New( RedCommandCenterSouth, "Resupply from Sukhumi", " ", " ", coalition.side.RED )
Red_Senaki_Resupply_Mission = MISSION
  :New( RedCommandCenterSouth, "Resupply from Senaki", " ", " ", coalition.side.RED )
Red_Batumi_Resupply_Mission = MISSION
  :New( RedCommandCenterSouth, "Resupply from Batumi", " ", " ", coalition.side.RED )
--Blue
-- Blue_KrasC_Resupply_Mission = MISSION
  -- :New( BlueCommandCenterNorth, "Resupply from Kras-C", " ", " ", coalition.side.BLUE )
Blue_Maykop_Resupply_Mission = MISSION
  :New( BlueCommandCenterNorth, "Resupply from Maykop", " ", " ", coalition.side.BLUE )
Blue_Sochi_Resupply_Mission = MISSION
  :New( BlueCommandCenterSouth, "Resupply from Sochi", " ", " ", coalition.side.BLUE )
-- Blue_Anapa_Resupply_Mission = MISSION
  -- :New( BlueCommandCenterNorth, "Resupply from Anapa", " ", " ", coalition.side.BLUE )
-- Blue_Gelendzhik_Resupply_Mission = MISSION
  -- :New( BlueCommandCenterNorth, "Resupply from Gelendzhik", " ", " ", coalition.side.BLUE )
Blue_MineralnyeVody_Resupply_Mission = MISSION
  :New( BlueCommandCenterNorth, "Resupply from MineralnyeVody", " ", " ", coalition.side.BLUE )
Blue_Nalchik_Resupply_Mission = MISSION
  :New( BlueCommandCenterNorth, "Resupply from Nalchik", " ", " ", coalition.side.BLUE )
Blue_Mozdok_Resupply_Mission = MISSION
  :New( BlueCommandCenterNorth, "Resupply from Mozdok", " ", " ", coalition.side.BLUE )
Blue_Vaziani_Resupply_Mission = MISSION
  :New( BlueCommandCenterSouth, "Resupply from Vaziani", " ", " ", coalition.side.BLUE )
Blue_Sukhumi_Resupply_Mission = MISSION
  :New( BlueCommandCenterSouth, "Resupply from Sukhumi", " ", " ", coalition.side.BLUE )
Blue_Senaki_Resupply_Mission = MISSION
  :New( BlueCommandCenterSouth, "Resupply from Senaki", " ", " ", coalition.side.BLUE )
Blue_Batumi_Resupply_Mission = MISSION
  :New( BlueCommandCenterSouth, "Resupply from Batumi", " ", " ", coalition.side.BLUE )  
----This Identifies the transports to be used for the tasks  
RedTransportGroups = SET_GROUP:New()
  :FilterCoalitions( "red" )
  :FilterPrefixes( {"Cargo", "Transport", "Helos"} )
  :FilterStart()
--Blue
BlueTransportGroups = SET_GROUP:New()
  :FilterCoalitions( "blue" )
  :FilterPrefixes( {"Cargo", "Transport", "Helos"} )
  :FilterStart()
----This activates the Moose Dispatcher function for the missions/tasks  
-- Red_Task_Dispatcher_KrasC = TASK_CARGO_DISPATCHER:New( Red_KrasC_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Maykop = TASK_CARGO_DISPATCHER:New( Red_Maykop_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Sochi = TASK_CARGO_DISPATCHER:New( Red_Sochi_Resupply_Mission, RedTransportGroups )
-- Red_Task_Dispatcher_Anapa = TASK_CARGO_DISPATCHER:New( Red_Anapa_Resupply_Mission, RedTransportGroups )
-- Red_Task_Dispatcher_Gelendzhik = TASK_CARGO_DISPATCHER:New( Red_Gelendzhik_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_MineralnyeVody = TASK_CARGO_DISPATCHER:New( Red_MineralnyeVody_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Nalchik = TASK_CARGO_DISPATCHER:New( Red_Nalchik_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Mozdok = TASK_CARGO_DISPATCHER:New( Red_Mozdok_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Vaziani = TASK_CARGO_DISPATCHER:New( Red_Vaziani_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Sukhumi = TASK_CARGO_DISPATCHER:New( Red_Sukhumi_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Senaki= TASK_CARGO_DISPATCHER:New( Red_Senaki_Resupply_Mission, RedTransportGroups )
Red_Task_Dispatcher_Batumi= TASK_CARGO_DISPATCHER:New( Red_Batumi_Resupply_Mission, RedTransportGroups )
--Blue
-- Blue_Task_Dispatcher_KrasC = TASK_CARGO_DISPATCHER:New( Blue_KrasC_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Maykop = TASK_CARGO_DISPATCHER:New( Blue_Maykop_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Sochi = TASK_CARGO_DISPATCHER:New( Blue_Sochi_Resupply_Mission, BlueTransportGroups )
-- Blue_Task_Dispatcher_Anapa = TASK_CARGO_DISPATCHER:New( Blue_Anapa_Resupply_Mission, BlueTransportGroups )
-- Blue_Task_Dispatcher_Gelendzhik = TASK_CARGO_DISPATCHER:New( Blue_Gelendzhik_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_MineralnyeVody = TASK_CARGO_DISPATCHER:New( Blue_MineralnyeVody_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Nalchik = TASK_CARGO_DISPATCHER:New( Blue_Nalchik_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Mozdok = TASK_CARGO_DISPATCHER:New( Blue_Mozdok_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Vaziani = TASK_CARGO_DISPATCHER:New( Blue_Vaziani_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Sukhumi = TASK_CARGO_DISPATCHER:New( Blue_Sukhumi_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Senaki= TASK_CARGO_DISPATCHER:New( Blue_Senaki_Resupply_Mission, BlueTransportGroups )
Blue_Task_Dispatcher_Batumi= TASK_CARGO_DISPATCHER:New( Blue_Batumi_Resupply_Mission, BlueTransportGroups )
----This Identifies the zones to be delivered to, I used the already identified Pickup zones for troops, these aren't the pickup zones for the crates, those have to be outside the pickup zones and are not late activated so they will respawn every restart, which is conveinent btw, but these are the zones the cargo/re-enforcements are delivered to
-- KrasC_Zone = ZONE:New("Krasnodar-Center PickUp")
Maykop_Zone = ZONE:New("Maykop PickUp")
Sochi_Zone = ZONE:New("Sochi PickUp")
-- Anapa_Zone = ZONE:New("Anapa-Vityazevo PickUp")
-- Gelendzhik_Zone = ZONE:New("Gelendzhik PickUp")
MineralnyeVody_Zone = ZONE:New("Mineralnye Vody PickUp")
Nalchik_Zone = ZONE:New("Nalchik PickUp")
Mozdok_Zone = ZONE:New("Mozdok PickUp")
Vaziani_Zone = ZONE:New("Vaziani PickUp")
Sukhumi_Zone = ZONE:New("Sukumi PickUp")
Senaki_Zone = ZONE:New("Senaki PickUp")
Batumi_Zone = ZONE:New("Batumi PickUp")
----Identifies that all crates in the mission editor on load are type crates
local Cargo_Set = SET_CARGO:New()
  :FilterTypes( "Crates" )
  :FilterStart()
---Identifies specific crates at each airbase to be used for tranport tasks
-- local Crate_Static_KrasC = STATIC:FindByName( "Kras-C Resupply Crate" )
local Crate_Static_Maykop = STATIC:FindByName( "Maykop Resupply Crate" )
local Crate_Static_Sochi = STATIC:FindByName( "Sochi Resupply Crate" )
-- local Crate_Static_Anapa = STATIC:FindByName( "Anapa Resupply Crate" )
-- local Crate_Static_Gelendzhik = STATIC:FindByName( "Gelendzhik Resupply Crate" )
local Crate_Static_MineralnyeVody = STATIC:FindByName( "MineralnyeVody Resupply Crate" )
local Crate_Static_Nalchik = STATIC:FindByName( "Nalchik Resupply Crate" )
local Crate_Static_Mozdok = STATIC:FindByName( "Mozdok Resupply Crate" )
local Crate_Static_Vaziani = STATIC:FindByName( "Vaziani Resupply Crate" )
local Crate_Static_Sukhumi = STATIC:FindByName( "Sukhumi Resupply Crate" )
local Crate_Static_Senaki = STATIC:FindByName( "Senaki Resupply Crate" )
local Crate_Static_Batumi = STATIC:FindByName( "Batumi Resupply Crate" )
----Seems redundant, but it has to be this way. Below identifies the static crates as cargo
-- Cargo_Set_KrasC = SET_CARGO:New():AddCargo(Crate_Static_KrasC)
Cargo_Set_Maykop = SET_CARGO:New():AddCargo(Crate_Static_Maykop)
Cargo_Set_Sochi = SET_CARGO:New():AddCargo(Crate_Static_Sochi)
-- Cargo_Set_Anapa = SET_CARGO:New():AddCargo(Crate_Static_Anapa)
-- Cargo_Set_Gelendzhik = SET_CARGO:New():AddCargo(Crate_Static_Gelendzhik)
Cargo_Set_MineralnyeVody = SET_CARGO:New():AddCargo(Crate_Static_MineralnyeVody)
Cargo_Set_Nalchik = SET_CARGO:New():AddCargo(Crate_Static_Nalchik)
Cargo_Set_Mozdok = SET_CARGO:New():AddCargo(Crate_Static_Mozdok)
Cargo_Set_Vaziani = SET_CARGO:New():AddCargo(Crate_Static_Vaziani)
Cargo_Set_Sukhumi = SET_CARGO:New():AddCargo(Crate_Static_Sukhumi)
Cargo_Set_Senaki = SET_CARGO:New():AddCargo(Crate_Static_Senaki)
Cargo_Set_Batumi = SET_CARGO:New():AddCargo(Crate_Static_Batumi)
----This sets the load min/max radius for the crates and established them as cargo crates
-- Crate_Cargo_KrasC = CARGO_CRATE:New( Crate_Static_KrasC, "Crates", "Kras-C Resupply Crate", 100, 100 )
Crate_Cargo_Maykop = CARGO_CRATE:New( Crate_Static_Maykop, "Crates", "Maykop Resupply Crate", 100, 100 )
Crate_Cargo_Sochi = CARGO_CRATE:New( Crate_Static_Sochi, "Crates", "Sochi Resupply Crate", 100, 100 )
-- Crate_Cargo_Anapa = CARGO_CRATE:New( Crate_Static_Anapa, "Crates", "Anapa Resupply Crate", 100, 100 )
-- Crate_Cargo_Gelendzhik = CARGO_CRATE:New( Crate_Static_Gelendzhik, "Crates", "Gelendzhik Resupply Crate", 100, 100 )
Crate_Cargo_MineralnyeVody = CARGO_CRATE:New( Crate_Static_MineralnyeVody, "Crates", "MineralnyeVody Resupply Crate", 100, 100 )
Crate_Cargo_Nalchik = CARGO_CRATE:New( Crate_Static_Nalchik, "Crates", "Nalchik Resupply Crate", 100, 100 )
Crate_Cargo_Mozdok = CARGO_CRATE:New( Crate_Static_Mozdok, "Crates", "Mozdok Resupply Crate", 100, 100 )
Crate_Cargo_Vaziani = CARGO_CRATE:New( Crate_Static_Vaziani, "Crates", "Vaziani Resupply Crate", 100, 100 )
Crate_Cargo_Sukhumi = CARGO_CRATE:New( Crate_Static_Sukhumi, "Crates", "Sukhumi Resupply Crate", 100, 100 )
Crate_Cargo_Senaki = CARGO_CRATE:New( Crate_Static_Senaki, "Crates", "Senaki Resupply Crate", 100, 100 )
Crate_Cargo_Batumi = CARGO_CRATE:New( Crate_Static_Batumi, "Crates", "Batumi Resupply Crate", 100, 100 )
----again redundant to Set the cargo again, but I had to the previous one was a global variable for a if/ifelse switch later on, this one is a local varible for the tasker
-- local Cargo_Set_KrasC = SET_CARGO:New()
  -- :AddCargo(Crate_Cargo_KrasC)
local Cargo_Set_Maykop = SET_CARGO:New()
  :AddCargo(Crate_Cargo_Maykop)
local Cargo_Set_Sochi= SET_CARGO:New()
  :AddCargo(Crate_Cargo_Sochi)
-- local Cargo_Set_Anapa = SET_CARGO:New()
  -- :AddCargo(Crate_Cargo_Anapa)
-- local Cargo_Set_Gelendzhik = SET_CARGO:New()
  -- :AddCargo(Crate_Cargo_Gelendzhik)
local Cargo_Set_MineralnyeVody = SET_CARGO:New()
  :AddCargo(Crate_Cargo_MineralnyeVody)
local Cargo_Set_Nalchik = SET_CARGO:New()
  :AddCargo(Crate_Cargo_Nalchik)
local Cargo_Set_Mozdok = SET_CARGO:New()
  :AddCargo(Crate_Cargo_Mozdok)
local Cargo_Set_Vaziani = SET_CARGO:New()
  :AddCargo(Crate_Cargo_Vaziani)
local Cargo_Set_Sukhumi = SET_CARGO:New()
  :AddCargo(Crate_Cargo_Sukhumi)
local Cargo_Set_Senaki = SET_CARGO:New()
  :AddCargo(Crate_Cargo_Senaki)
local Cargo_Set_Batumi = SET_CARGO:New()
  :AddCargo(Crate_Cargo_Batumi)
----These are the Tasks which fall under the regional dispatches/missions. Its task prefix/cargo/briefing, I could make the briefing portions a little longer, but just want to be done for a little bit
-- local Red_KrasC_Resupply= Red_Task_Dispatcher_KrasC:AddTransportTask( "Kras-C Resupply ", Cargo_Set_KrasC, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
--local Red_KrasC_Resupply= Red_Task_Dispatcher_KrasC:AddTransportTask( "Infantry Test ", Cargo_SetInf, "Test Infantry as Cargo" ) --example of adding an additional task to the KrasC Dispatcher
local Red_Maykop_Resupply= Red_Task_Dispatcher_Maykop:AddTransportTask( "Maykop Resupply", Cargo_Set_Maykop, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_Sochi_Resupply= Red_Task_Dispatcher_Sochi:AddTransportTask( "Sochi Resupply ", Cargo_Set_Sochi, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
-- local Red_Anapa_Resupply= Red_Task_Dispatcher_Anapa:AddTransportTask( "Anapa Resupply ", Cargo_Set_Anapa, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
-- local Red_Gelendzhik_Resupply= Red_Task_Dispatcher_Gelendzhik:AddTransportTask( "Gelendzhik Resupply ", Cargo_Set_Gelendzhik, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_MineralnyeVody_Resupply= Red_Task_Dispatcher_MineralnyeVody:AddTransportTask( "MineralnyeVody Resupply ", Cargo_Set_MineralnyeVody, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_Nalchik_Resupply= Red_Task_Dispatcher_Nalchik:AddTransportTask( "Nalchik Resupply ", Cargo_Set_Nalchik, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_Mozdok_Resupply= Red_Task_Dispatcher_Mozdok:AddTransportTask( "Mozdok Resupply ", Cargo_Set_Mozdok, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_Vaziani_Resupply= Red_Task_Dispatcher_Vaziani:AddTransportTask( "Vaziani Resupply ", Cargo_Set_Vaziani, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_Sukhumi_Resupply= Red_Task_Dispatcher_Sukhumi:AddTransportTask( "Sukhumi Resupply ", Cargo_Set_Sukhumi, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_Senaki_Resupply= Red_Task_Dispatcher_Senaki:AddTransportTask( "Senaki Resupply ", Cargo_Set_Senaki, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Red_Batumi_Resupply= Red_Task_Dispatcher_Batumi:AddTransportTask( "Batumi Resupply ", Cargo_Set_Batumi, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
--Blue
-- local Blue_KrasC_Resupply= Blue_Task_Dispatcher_KrasC:AddTransportTask( "Kras-C Resupply ", Cargo_Set_KrasC, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Maykop_Resupply= Blue_Task_Dispatcher_Maykop:AddTransportTask( "Maykop Resupply", Cargo_Set_Maykop, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Sochi_Resupply= Blue_Task_Dispatcher_Sochi:AddTransportTask( "Sochi Resupply ", Cargo_Set_Sochi, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
-- local Blue_Anapa_Resupply= Blue_Task_Dispatcher_Anapa:AddTransportTask( "Anapa Resupply ", Cargo_Set_Anapa, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
-- local Blue_Gelendzhik_Resupply= Blue_Task_Dispatcher_Gelendzhik:AddTransportTask( "Gelendzhik Resupply ", Cargo_Set_Gelendzhik, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_MineralnyeVody_Resupply= Blue_Task_Dispatcher_MineralnyeVody:AddTransportTask( "MineralnyeVody Resupply ", Cargo_Set_MineralnyeVody, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Nalchik_Resupply= Blue_Task_Dispatcher_Nalchik:AddTransportTask( "Nalchik Resupply ", Cargo_Set_Nalchik, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Mozdok_Resupply= Blue_Task_Dispatcher_Mozdok:AddTransportTask( "Mozdok Resupply ", Cargo_Set_Mozdok, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Vaziani_Resupply= Blue_Task_Dispatcher_Vaziani:AddTransportTask( "Vaziani Resupply ", Cargo_Set_Vaziani, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Sukhumi_Resupply= Blue_Task_Dispatcher_Sukhumi:AddTransportTask( "Sukhumi Resupply ", Cargo_Set_Sukhumi, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Senaki_Resupply= Blue_Task_Dispatcher_Senaki:AddTransportTask( "Senaki Resupply ", Cargo_Set_Senaki, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
local Blue_Batumi_Resupply= Blue_Task_Dispatcher_Batumi:AddTransportTask( "Batumi Resupply ", Cargo_Set_Batumi, "Resupply to any base \n - The crate is at the end of the Runway \n - If you are far enough away you can use the F10 Control Task to give you bearing/distance to cargo \n - After you have re-supply crate onboard fly to any base to resupply, you can also request HQ to provide bearing an range to the base using F10 Control Task" )
----sets the zones for the task, so if you pick up a crate at KrasC, you can deliver to any of the following zones
-- Red_Task_Dispatcher_KrasC:SetDefaultDeployZones({Maykop_Zone, Sochi_Zone, Gelendzhik_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_Maykop:SetDefaultDeployZones({ Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_Sochi:SetDefaultDeployZones({ Maykop_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
-- Red_Task_Dispatcher_Anapa:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
-- Red_Task_Dispatcher_Gelendzhik:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, Anapa_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_MineralnyeVody:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_Nalchik:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_Mozdok:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Vaziani_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_Vaziani:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_Sukhumi:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Senaki_Zone, Batumi_Zone})
Red_Task_Dispatcher_Senaki:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Sukhumi_Zone, Batumi_Zone})
Red_Task_Dispatcher_Batumi:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Sukhumi_Zone, Senaki_Zone})
--Blue
-- Blue_Task_Dispatcher_KrasC:SetDefaultDeployZones({Maykop_Zone, Sochi_Zone, Anapa_Zone, , MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Maykop:SetDefaultDeployZones({ Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Sochi:SetDefaultDeployZones({ Maykop_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
-- Blue_Task_Dispatcher_Anapa:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, , MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
-- Blue_Task_Dispatcher_Gelendzhik:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, Anapa_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_MineralnyeVody:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Nalchik:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Mozdok:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Vaziani_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Vaziani:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Sukhumi_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Sukhumi:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Senaki_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Senaki:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Sukhumi_Zone, Batumi_Zone})
Blue_Task_Dispatcher_Batumi:SetDefaultDeployZones({ Maykop_Zone, Sochi_Zone, MineralnyeVody_Zone, Nalchik_Zone, Mozdok_Zone, Vaziani_Zone, Sukhumi_Zone, Senaki_Zone})
----Below are the if-else switches that determine what to spawn once you arrive to the zone and verifies the cargo is actually in the zone.
----KrasC Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
-- function Red_Task_Dispatcher_KrasC:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_KrasC:IsInZone(Maykop_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias("Maykop Red Base Resupply", "Re-enforcements From Kras-C"):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    -- elseif Crate_Cargo_KrasC:IsInZone(Sochi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
   -- elseif Crate_Cargo_KrasC:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_KrasC:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    -- elseif Crate_Cargo_KrasC:IsInZone(MineralnyeVody_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    -- elseif Crate_Cargo_KrasC:IsInZone(Nalchik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    -- elseif Crate_Cargo_KrasC:IsInZone(Mozdok_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Vaziani_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Sukhumi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Senaki_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Batumi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- end

-- end
----Maykop Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Maykop:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Maykop:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Maykop:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
   -- elseif Crate_Cargo_Maykop:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Maykop:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    -- elseif Crate_Cargo_Maykop:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Maykop:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Maykop:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Maykop:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Maykop:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Maykop:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Maykop:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Sochi Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Sochi:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Sochi:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Sochi:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
   -- elseif Crate_Cargo_Sochi:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Sochi:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Sochi:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Sochi:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Sochi:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Sochi:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Sochi:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Sochi:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Sochi:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Anapa Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
-- function Red_Task_Dispatcher_Anapa:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Anapa:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Anapa:IsInZone(Maykop_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    -- elseif Crate_Cargo_Anapa:IsInZone(Sochi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Anapa:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    -- elseif Crate_Cargo_Anapa:IsInZone(MineralnyeVody_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    -- elseif Crate_Cargo_Anapa:IsInZone(Nalchik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    -- elseif Crate_Cargo_Anapa:IsInZone(Mozdok_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Vaziani_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Sukhumi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Senaki_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Batumi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- end

-- end
----Gelendzhik Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
-- function Red_Task_Dispatcher_Gelendzhik:OnAfterCargoDeployed(From, Event, To, Task, 
-- TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Gelendzhik:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Maykop_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Sochi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
   -- elseif Crate_Cargo_Gelendzhik:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(MineralnyeVody_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Nalchik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Mozdok_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Vaziani_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Sukhumi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Senaki_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Batumi_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- end

-- end

----MineralnyeVody Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_MineralnyeVody:OnAfterCargoDeployed(From, Event, To, Task, 
TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_MineralnyeVody:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_MineralnyeVody:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
   -- elseif Crate_Cargo_MineralnyeVody:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_MineralnyeVody:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Nalchik Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Nalchik:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Nalchik:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Nalchik:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Nalchik:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
   -- elseif Crate_Cargo_Nalchik:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Nalchik:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Nalchik:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )
    elseif Crate_Cargo_Nalchik:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Nalchik:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Nalchik:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Nalchik:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Nalchik:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Mozdok Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Mozdok:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Mozdok:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Mozdok:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Mozdok:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Mozdok:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Mozdok:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Mozdok:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Mozdok:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Mozdok:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Mozdok:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Mozdok:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Mozdok:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Vaziani Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Vaziani:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Vaziani:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Vaziani:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Vaziani:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Vaziani:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Vaziani:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Vaziani:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Vaziani:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Vaziani:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)
    elseif Crate_Cargo_Vaziani:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Vaziani:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Vaziani:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Sukhumi Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Sukhumi:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Sukhumi:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Sukhumi:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Sukhumi:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Sukhumi:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Sukhumi:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Sukhumi:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Sukhumi:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Sukhumi:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Sukhumi:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400) 
    elseif Crate_Cargo_Sukhumi:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Senaki Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Sukhumi:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Senaki Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Senaki:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Senaki:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Senaki:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Maykop Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Senaki:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sochi Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Senaki:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Anapa Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Senaki:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Senaki:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Senaki:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Senaki:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Senaki:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Senaki:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)
    elseif Crate_Cargo_Senaki:IsInZone(Batumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "Batumi Red Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Batumi Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Red_Task_Dispatcher_Batumi:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Batumi:IsInZone(KrasC_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:NewWithAlias( "KrasC Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Batumi:IsInZone(Maykop_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "Maykop Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Batumi:IsInZone(Sochi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "Sochi Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Batumi:IsInZone(Anapa_Zone) then 
        -- Spawn_Red_Base_Resupply = SPAWN:New( "Anapa Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Batumi:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Red_Base_Resupply = SPAWN:New( "Gelendzhik Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Batumi:IsInZone(MineralnyeVody_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "MineralnyeVody Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Batumi:IsInZone(Nalchik_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "Nalchik Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Batumi:IsInZone(Mozdok_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "Mozdok Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Batumi:IsInZone(Vaziani_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "Vaziani Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Batumi:IsInZone(Sukhumi_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "Sukhumi Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Batumi:IsInZone(Senaki_Zone) then
        Spawn_Red_Base_Resupply = SPAWN:New( "Senaki Red Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Red_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
--Blue
----KrasC Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
-- function Blue_Task_Dispatcher_KrasC:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- -- if Crate_Cargo_KrasC:IsInZone(Maykop_Zone) then
        -- -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias("Maykop Blue Base Resupply", "Re-enforcements From Kras-C"):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    -- if Crate_Cargo_KrasC:IsInZone(Sochi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- -- elseif Crate_Cargo_KrasC:IsInZone(Anapa_Zone) then 
        -- -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- -- elseif Crate_Cargo_KrasC:IsInZone(Gelendzhik_Zone) then
        -- -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    -- elseif Crate_Cargo_KrasC:IsInZone(MineralnyeVody_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    -- elseif Crate_Cargo_KrasC:IsInZone(Nalchik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    -- elseif Crate_Cargo_KrasC:IsInZone(Mozdok_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Vaziani_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Sukhumi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Senaki_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- elseif Crate_Cargo_KrasC:IsInZone(Batumi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements From Kras-C" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- end

-- end
----Maykop Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Maykop:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Maykop:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Maykop:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Maykop:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Maykop:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Maykop:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Maykop:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Maykop:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Maykop:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Maykop:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Maykop:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Maykop:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements From Maykop" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Sochi Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Sochi:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Sochi:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Sochi:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    -- elseif Crate_Cargo_Sochi:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Sochi:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Sochi:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Sochi:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Sochi:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Sochi:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Sochi:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Sochi:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Sochi:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Sochi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Anapa Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
-- function Blue_Task_Dispatcher_Anapa:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Anapa:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- if Crate_Cargo_Anapa:IsInZone(Maykop_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    -- elseif Crate_Cargo_Anapa:IsInZone(Sochi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Anapa:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    -- elseif Crate_Cargo_Anapa:IsInZone(MineralnyeVody_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    -- elseif Crate_Cargo_Anapa:IsInZone(Nalchik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    -- elseif Crate_Cargo_Anapa:IsInZone(Mozdok_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Vaziani_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Sukhumi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Senaki_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- elseif Crate_Cargo_Anapa:IsInZone(Batumi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Anapa" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- end

-- end
----Gelendzhik Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
-- function Blue_Task_Dispatcher_Gelendzhik:OnAfterCargoDeployed(From, Event, To, Task, 
-- TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- -- if Crate_Cargo_Gelendzhik:IsInZone(KrasC_Zone) then
        -- -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- if Crate_Cargo_Gelendzhik:IsInZone(Maykop_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Sochi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
   -- -- elseif Crate_Cargo_Gelendzhik:IsInZone(Anapa_Zone) then 
        -- -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(MineralnyeVody_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Nalchik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Mozdok_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Vaziani_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Sukhumi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Senaki_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- elseif Crate_Cargo_Gelendzhik:IsInZone(Batumi_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Gelendzhik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    -- end

-- end

----MineralnyeVody Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_MineralnyeVody:OnAfterCargoDeployed(From, Event, To, Task, 
TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_MineralnyeVody:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_MineralnyeVody:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_MineralnyeVody:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_MineralnyeVody:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_MineralnyeVody:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from MineralnyeVody" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Nalchik Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Nalchik:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Nalchik:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Nalchik:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Nalchik:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
   -- elseif Crate_Cargo_Nalchik:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Nalchik:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Nalchik:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )
    elseif Crate_Cargo_Nalchik:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Nalchik:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Nalchik:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Nalchik:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Nalchik:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Nalchik" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Mozdok Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Mozdok:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Mozdok:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Mozdok:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Mozdok:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Mozdok:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Mozdok:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Mozdok:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Mozdok:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Mozdok:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Mozdok:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Mozdok:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Mozdok:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Mozdok" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Vaziani Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Vaziani:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Vaziani:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Vaziani:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Vaziani:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Vaziani:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Vaziani:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Vaziani:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Vaziani:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Vaziani:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)
    elseif Crate_Cargo_Vaziani:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Vaziani:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Vaziani:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Vaziani" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Sukhumi Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Sukhumi:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Sukhumi:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Sukhumi:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Sukhumi:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Sukhumi:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Sukhumi:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Sukhumi:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Sukhumi:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Sukhumi:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Sukhumi:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400) 
    elseif Crate_Cargo_Sukhumi:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Senaki Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    elseif Crate_Cargo_Sukhumi:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Sukhumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Senaki Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Senaki:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Senaki:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Senaki:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Maykop Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Senaki:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sochi Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Senaki:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Anapa Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Senaki:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Gelendzhik Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Senaki:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Senaki:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Nalchik Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Senaki:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Mozdok Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Senaki:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Vaziani Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Senaki:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Sukhumi Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)
    elseif Crate_Cargo_Senaki:IsInZone(Batumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "Batumi Blue Base Resupply", "Re-enforcements from Senaki" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end
----Batumi Switch to make sure the Cargo is in the corrrect zone to spawn the resupply units
function Blue_Task_Dispatcher_Batumi:OnAfterCargoDeployed(From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone)

    -- if Crate_Cargo_Batumi:IsInZone(KrasC_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:NewWithAlias( "KrasC Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    if Crate_Cargo_Batumi:IsInZone(Maykop_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "Maykop Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1900, 1700 )
    elseif Crate_Cargo_Batumi:IsInZone(Sochi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "Sochi Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1600 )
    -- elseif Crate_Cargo_Batumi:IsInZone(Anapa_Zone) then 
        -- Spawn_Blue_Base_Resupply = SPAWN:New( "Anapa Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1800, 1700 )
    -- elseif Crate_Cargo_Batumi:IsInZone(Gelendzhik_Zone) then
        -- Spawn_Blue_Base_Resupply = SPAWN:New( "Gelendzhik Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1500, 100 )
    elseif Crate_Cargo_Batumi:IsInZone(MineralnyeVody_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "MineralnyeVody Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2300, 2100 )  
    elseif Crate_Cargo_Batumi:IsInZone(Nalchik_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "Nalchik Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1000, 100 )  
    elseif Crate_Cargo_Batumi:IsInZone(Mozdok_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "Mozdok Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2600, 2400)  
    elseif Crate_Cargo_Batumi:IsInZone(Vaziani_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "Vaziani Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1600, 1400)  
    elseif Crate_Cargo_Batumi:IsInZone(Sukhumi_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "Sukhumi Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 2100, 1900)  
    elseif Crate_Cargo_Batumi:IsInZone(Senaki_Zone) then
        Spawn_Blue_Base_Resupply = SPAWN:New( "Senaki Blue Base Resupply", "Re-enforcements from Batumi" ):InitLimit( 20, 20 ):InitRandomizeTemplate( Spawn_Blue_Defenses ):SpawnScheduled( 0.05, 1 ):InitRandomizePosition( "NEEDS TO BE SET", 1400, 1200)  
    end

end