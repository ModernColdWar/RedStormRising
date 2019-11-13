--[[
    Combat Troop and Logistics Drop

    Allows Huey, Mi-8 and C130 to transport troops internally and Helicopters to transport Logistic / Vehicle units to the field via sling-loads
    without requiring external mods.

    Supports all of the original CTTS functionality such as AI auto troop load and unload as well as group spawning and preloading of troops into units.

    Supports deployment of Auto Lasing JTAC to the field

    See https://github.com/ciribob/DCS-CTLD for a user manual and the latest version

	Contributors:
	    - Steggles - https://github.com/Bob7heBuilder
	    - mvee - https://github.com/mvee
	    - jmontleon - https://github.com/jmontleon
	    - emilianomolina - https://github.com/emilianomolina

    Version: 1.73 - 15/04/2018
      - Allow minimum distance from friendly logistics to be set
 ]]

ctld = {} -- DONT REMOVE!

-- ************************************************************************
-- *********************  USER CONFIGURATION ******************************
-- ************************************************************************

ctld.staticBugWorkaround = false --  DCS had a bug where destroying statics would cause a crash. If this happens again, set this to TRUE
ctld.debug = false -- Set true to turn off logistics distances, to test crates
ctld.disableAllSmoke = true -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below

ctld.hoverPickup = false --  if set to false you can load internal crates with the F10 menu instead of hovering... Only if not using real crates!

ctld.enableCrates = true -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
ctld.internalCargo = true -- if true, allow the internal carriage of some cargo
ctld.slingLoad = true -- if false, crates can be used WITHOUT slingloading, by hovering above the crate, simulating slingloading but not the weight...
-- There are some bug with Sling-loading that can cause crashes, if these occur set slingLoad to false
-- to use the other method.
-- Set staticBugFix  to FALSE if use set ctld.slingLoad to TRUE

ctld.enableSmokeDrop = true -- if false, helis and c-130 will not be able to drop smoke

ctld.maxExtractDistance = 200 -- max distance from vehicle to troops to allow a group extraction
ctld.maximumDistanceLogistic = 200 -- max distance from vehicle to logistics to allow a loading or spawning operation (-Swallow Changed to 0 for ez testing)
ctld.maximumSearchDistance = 0 -- max distance for troops to search for enemy
ctld.maximumMoveDistance = 2000 -- max distance for troops to move from drop point if no enemy is nearby

ctld.minimumDeployDistance = 600 -- minimum distance from a friendly pickup zone where you can deploy a crate

ctld.numberOfTroops = 10 -- default number of troops to load on a transport heli or C-130
-- also works as maximum size of group that'll fit into a helicopter unless overridden
ctld.enableFastRopeInsertion = true -- allows you to drop troops by fast rope
ctld.fastRopeMaximumHeight = 18.28 -- in meters which is 60 ft max fast rope (not rappell) safe height

ctld.vehiclesForTransportRED = { "BRDM-2", "BTR_D" } -- vehicles to load onto Il-76 - Alternatives {"Strela-1 9P31","BMP-1"}
ctld.vehiclesForTransportBLUE = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130 - Alternatives {"M1128 Stryker MGS","M1097 Avenger"}

ctld.spawnRPGWithCoalition = true --spawns a friendly RPG unit with Coalition forces
ctld.spawnStinger = true -- spawns a stinger / igla soldier with a group of 6 or more soldiers!

ctld.enabledFOBBuilding = true -- if true, you can load a crate INTO a C-130 than when unpacked creates a Forward Operating Base (FOB) which is a new place to spawn (crates) and carry crates from
-- In future i'd like it to be a FARP but so far that seems impossible...
-- You can also enable troop Pickup at FOBS

ctld.cratesRequiredForFOB = 1 -- The amount of crates required to build a FOB. Once built, helis can spawn crates at this outpost to be carried and deployed in another area.
-- The large crates can only be loaded and dropped by large aircraft, like the C-130 and listed in ctld.vehicleTransportEnabled
-- Small FOB crates can be moved by helicopter. The FOB will require ctld.cratesRequiredForFOB larges crates and small crates are 1/3 of a large fob crate
-- To build the FOB entirely out of small crates you will need ctld.cratesRequiredForFOB * 3

ctld.troopPickupAtFOB = true -- if true, troops can also be picked up at a created FOB

ctld.buildTimeFOB = 30 --time in seconds for the FOB to be built

ctld.crateWaitTime = 10 -- time in seconds to wait before you can spawn another crate

ctld.forceCrateToBeMoved = false -- a crate must be picked up at least once and moved before it can be unpacked. Helps to reduce crate spam. Only works if ctld.slingLoad = false -Swallow you might want to change this to True

ctld.radioSound = "beacon.ogg" -- the name of the sound file to use for the FOB radio beacons. If this isnt added to the mission BEACONS WONT WORK!
ctld.radioSoundFC3 = "beaconsilent.ogg" -- name of the second silent radio file, used so FC3 aircraft dont hear ALL the beacon noises... :)

ctld.deployedBeaconBattery = 30 -- the battery on deployed beacons will last for this number minutes before needing to be re-deployed

ctld.enabledRadioBeaconDrop = true -- if its set to false then beacons cannot be dropped by units

ctld.allowRandomAiTeamPickups = false -- Allows the AI to randomize the loading of infantry teams (specified below) at pickup zones

-- Simulated Sling load configuration

ctld.minimumHoverHeight = 7.5 -- Lowest allowable height for crate hover
ctld.maximumHoverHeight = 18.0 -- Highest allowable height for crate hover
ctld.maxDistanceFromCrate = 5.5 -- Maximum distance from from crate for hover
ctld.hoverTime = 4 -- Time to hold hover above a crate for loading in seconds

-- end of Simulated Sling load configuration

-- AA SYSTEM CONFIG --
-- Sets a limit on the number of active AA systems that can be built for RED.
-- A system is counted as Active if its fully functional and has all parts
-- If a system is partially destroyed, it no longer counts towards the total
-- When this limit is hit, a player will still be able to get crates for an AA system, just unable
-- to unpack them

ctld.AASystemLimitRED = 100 -- Red side limit

ctld.AASystemLimitBLUE = 100 -- Blue side limit

ctld.aaSRLaunchers = 3 -- controls how many launchers to add to Short Range Missile systems when spawned.
ctld.aaMRLaunchers = 4 -- controls how many launchers to add to Medium Range Missile systems when spawned.
ctld.aaLRLaunchers = 4 -- controls how many launchers to add to Long Range Missile systems when spawned.

--END AA SYSTEM CONFIG --

-- ***************** JTAC CONFIGURATION *****************

ctld.JTAC_LIMIT_RED = 20 -- max number of JTAC Crates for the RED Side
ctld.JTAC_LIMIT_BLUE = 20 -- max number of JTAC Crates for the BLUE Side

ctld.JTAC_dropEnabled = true -- allow JTAC Crate spawn from F10 menu

ctld.JTAC_maxDistance = 10000 -- How far a JTAC can "see" in meters (with Line of Sight)

ctld.JTAC_smokeOn_RED = true -- enables marking of target with smoke for RED forces
ctld.JTAC_smokeOn_BLUE = true -- enables marking of target with smoke for BLUE forces

ctld.JTAC_smokeColour_RED = 4 -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeColour_BLUE = 1 -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4

ctld.JTAC_jtacStatusF10 = true -- enables F10 JTAC Status menu

ctld.JTAC_location = true -- shows location of target in JTAC message
ctld.location_DMS = false -- shows coordinates as Degrees Minutes Seconds instead of Degrees Decimal minutes

ctld.JTAC_lock = "all" -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units

ctld.JTAC_laserCode_RED = 1686
ctld.JTAC_laserCode_BLUE = 1687

-- ***************** Pickup, dropoff and waypoint zones *****************

-- Available colors (anything else like "none" disables smoke): "green", "red", "white", "orange", "blue", "none",

-- Use any of the predefined names or set your own ones

-- You can add number as a third option to limit the number of soldier or vehicle groups that can be loaded from a zone.
-- Dropping back a group at a limited zone will add one more to the limit

-- If a zone isn't ACTIVE then you can't pickup from that zone until the zone is activated by ctld.activatePickupZone
-- using the Mission editor

-- You can pickup from a SHIP by adding the SHIP UNIT NAME instead of a zone name

-- Side - Controls which side can load/unload troops at the zone

-- Flag Number - Optional last field. If set the current number of groups remaining can be obtained from the flag value

--pickupZones = { "Zone name or Ship Unit Name", "smoke color", "limit (-1 unlimited)", "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", flag number (optional) }
ctld.pickupZones = {
    { "Senaki Red PickUp", "none", -1, "no", 1 },
    { "Kutaisi Red PickUp", "none", -1, "no", 1 },
    { "Kobuleti Red PickUp", "none", -1, "no", 1 },
    { "Sukumi Red PickUp", "none", -1, "no", 1 },
    { "Gudauta Red PickUp", "none", -1, "no", 1 },
    { "Sochi Red PickUp", "none", -1, "no", 1 },
    { "KN61 Red PickUp", "none", -1, "no", 1 },
    { "GH05 Red PickUp", "none", -1, "no", 1 },


    { "pickzone11", "blue", 20, "no", 2 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    { "pickzone12", "red", 20, "no", 1 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    { "pickzone13", "none", -1, "yes", 0 },
    { "pickzone14", "none", -1, "yes", 0 },
    { "pickzone15", "none", -1, "yes", 0 },
    { "pickzone16", "none", -1, "yes", 0 },
    { "pickzone17", "none", -1, "yes", 0 },
    { "pickzone18", "none", -1, "yes", 0 },
    { "pickzone19", "none", 5, "yes", 0 },
    { "pickzone20", "none", 10, "yes", 0, 1000 }, -- optional extra flag number to store the current number of groups available in

    { "USA Carrier", "blue", 10, "yes", 0, 1001 }, -- instead of a Zone Name you can also use the UNIT NAME of a ship
}


-- dropOffZones = {"name","smoke colour",0,side 1 = Red or 2 = Blue or 0 = Both sides}
ctld.dropOffZones = {
    { "dropzone1", "green", 2 },
    { "dropzone2", "blue", 2 },
    { "dropzone3", "orange", 2 },
    { "dropzone4", "none", 2 },
    { "dropzone5", "none", 1 },
    { "dropzone6", "none", 1 },
    { "dropzone7", "none", 1 },
    { "dropzone8", "none", 1 },
    { "dropzone9", "none", 1 },
    { "dropzone10", "none", 1 },
}


--wpZones = { "Zone name", "smoke color",  "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", }
ctld.wpZones = {
    { "wpzone1", "green", "yes", 2 },
    { "wpzone2", "blue", "yes", 2 },
    { "wpzone3", "orange", "yes", 2 },
    { "wpzone4", "none", "yes", 2 },
    { "wpzone5", "none", "yes", 2 },
    { "wpzone6", "none", "yes", 1 },
    { "wpzone7", "none", "yes", 1 },
    { "wpzone8", "none", "yes", 1 },
    { "wpzone9", "none", "yes", 1 },
    { "wpzone10", "none", "no", 0 }, -- Both sides as its set to 0
}


-- ******************** Transports names **********************

-- Use any of the predefined names or set your own ones
ctld.transportPilotNames = {
    "Sochi Red Helos #001",
    "Sochi Red Helos #002",
    "Sochi Red Helos #003",
    "Sochi Red Helos #004",
    "Sochi Red Helos #005",
    "Sochi Red Helos #006",
    "Sochi Red Helos #007",
    "Sochi Red Helos #008",
    "Sochi Red Helos #009",
    "Sochi Red Helos #010",
    "Sochi Red Helos #011",
    "Sochi Red Helos #012",


    "Sochi Blue Helos #001",
    "Sochi Blue Helos #002",
    "Sochi Blue Helos #003",
    "Sochi Blue Helos #005",
    "Sochi Blue Helos #006",
    "Sochi Blue Helos #007",
    "Sochi Blue Helos #008",
    "Sochi Blue Helos #009",
    "Sochi Blue Helos #010",
    "Sochi Blue Helos #011",
    "Sochi Blue Helos #012",

    "Gudauta Red Helos #001",
    "Gudauta Red Helos #002",
    "Gudauta Red Helos #003",
    "Gudauta Red Helos #004",
    "Gudauta Red Helos #005",
    "Gudauta Red Helos #006",
    "Gudauta Red Helos #007",
    "Gudauta Red Helos #008",
    "Gudauta Red Helos #009",
    "Gudauta Red Helos #010",
    "Gudauta Red Helos #011",
    "Gudauta Red Helos #012",

    "Gudauta Blue Helos #001",
    "Gudauta Blue Helos #002",
    "Gudauta Blue Helos #003",
    "Gudauta Blue Helos #005",
    "Gudauta Blue Helos #006",
    "Gudauta Blue Helos #007",
    "Gudauta Blue Helos #008",
    "Gudauta Blue Helos #009",
    "Gudauta Blue Helos #010",
    "Gudauta Blue Helos #011",
    "Gudauta Blue Helos #012",


    "Sukumi Red Helos #001",
    "Sukumi Red Helos #002",
    "Sukumi Red Helos #003",
    "Sukumi Red Helos #004",
    "Sukumi Red Helos #005",
    "Sukumi Red Helos #006",
    "Sukumi Red Helos #007",
    "Sukumi Red Helos #008",
    "Sukumi Red Helos #009",
    "Sukumi Red Helos #010",
    "Sukumi Red Helos #011",
    "Sukumi Red Helos #012",

    "Sukumi Blue Helos #001",
    "Sukumi Blue Helos #002",
    "Sukumi Blue Helos #003",
    "Sukumi Blue Helos #004",
    "Sukumi Blue Helos #005",
    "Sukumi Blue Helos #006",
    "Sukumi Blue Helos #007",
    "Sukumi Blue Helos #008",
    "Sukumi Blue Helos #009",
    "Sukumi Blue Helos #010",
    "Sukumi Blue Helos #011",
    "Sukumi Blue Helos #012",

    "Kobuleti Red Helos #001",
    "Kobuleti Red Helos #002",
    "Kobuleti Red Helos #003",
    "Kobuleti Red Helos #004",
    "Kobuleti Red Helos #005",
    "Kobuleti Red Helos #006",
    "Kobuleti Red Helos #007",
    "Kobuleti Red Helos #008",
    "Kobuleti Red Helos #009",
    "Kobuleti Red Helos #010",
    "Kobuleti Red Helos #011",
    "Kobuleti Red Helos #012",


    "Kobuleti Blue Helos #001",
    "Kobuleti Blue Helos #002",
    "Kobuleti Blue Helos #003",
    "Kobuleti Blue Helos #005",
    "Kobuleti Blue Helos #006",
    "Kobuleti Blue Helos #007",
    "Kobuleti Blue Helos #008",
    "Kobuleti Blue Helos #009",
    "Kobuleti Blue Helos #010",
    "Kobuleti Blue Helos #011",
    "Kobuleti Blue Helos #012",


    "Kutaisi Red Helos #001",
    "Kutaisi Red Helos #002",
    "Kutaisi Red Helos #003",
    "Kutaisi Red Helos #004",
    "Kutaisi Red Helos #005",
    "Kutaisi Red Helos #006",
    "Kutaisi Red Helos #007",
    "Kutaisi Red Helos #008",
    "Kutaisi Red Helos #009",
    "Kutaisi Red Helos #010",
    "Kutaisi Red Helos #011",
    "Kutaisi Red Helos #012",


    "Kutaisi Blue Helos #001",
    "Kutaisi Blue Helos #002",
    "Kutaisi Blue Helos #003",
    "Kutaisi Blue Helos #005",
    "Kutaisi Blue Helos #006",
    "Kutaisi Blue Helos #007",
    "Kutaisi Blue Helos #008",
    "Kutaisi Blue Helos #009",
    "Kutaisi Blue Helos #010",
    "Kutaisi Blue Helos #011",
    "Kutaisi Blue Helos #012",


    "Senaki Red Helos #001",
    "Senaki Red Helos #002",
    "Senaki Red Helos #003",
    "Senaki Red Helos #004",
    "Senaki Red Helos #005",
    "Senaki Red Helos #006",
    "Senaki Red Helos #007",
    "Senaki Red Helos #008",
    "Senaki Red Helos #009",
    "Senaki Red Helos #010",
    "Senaki Red Helos #011",
    "Senaki Red Helos #012",


    "Senaki Blue Helos #001",
    "Senaki Blue Helos #002",
    "Senaki Blue Helos #003",
    "Senaki Blue Helos #005",
    "Senaki Blue Helos #006",
    "Senaki Blue Helos #007",
    "Senaki Blue Helos #008",
    "Senaki Blue Helos #009",
    "Senaki Blue Helos #010",
    "Senaki Blue Helos #011",
    "Senaki Blue Helos #012",

    "GH05 BLUE HELOS #001",
    "GH05 BLUE HELOS #002",
    "GH05 BLUE HELOS #003",
    "GH05 BLUE HELOS #004",
    "GH05 BLUE HELOS #005",
    "GH05 BLUE HELOS #006",
    "GH05 BLUE HELOS #007",
    "GH05 BLUE HELOS #008",
    "GH05 BLUE HELOS #009",
    "GH05 BLUE HELOS #010",
    "GH05 BLUE HELOS #011",
    "GH05 BLUE HELOS #012",


    "GH05 RED HELOS #001",
    "GH05 RED HELOS #002",
    "GH05 RED HELOS #003",
    "GH05 RED HELOS #005",
    "GH05 RED HELOS #006",
    "GH05 RED HELOS #007",
    "GH05 RED HELOS #008",
    "GH05 RED HELOS #009",
    "GH05 RED HELOS #010",
    "GH05 RED HELOS #011",
    "GH05 RED HELOS #012",

    "KN61 BLUE HELOS #001",
    "KN61 BLUE HELOS #002",
    "KN61 BLUE HELOS #003",
    "KN61 BLUE HELOS #004",
    "KN61 BLUE HELOS #005",
    "KN61 BLUE HELOS #006",
    "KN61 BLUE HELOS #007",
    "KN61 BLUE HELOS #008",
    "KN61 BLUE HELOS #009",
    "KN61 BLUE HELOS #010",
    "KN61 BLUE HELOS #011",
    "KN61 BLUE HELOS #012",


    "KN61 RED HELOS #001",
    "KN61 RED HELOS #002",
    "KN61 RED HELOS #003",
    "KN61 RED HELOS #005",
    "KN61 RED HELOS #006",
    "KN61 RED HELOS #007",
    "KN61 RED HELOS #008",
    "KN61 RED HELOS #009",
    "KN61 RED HELOS #010",
    "KN61 RED HELOS #011",
    "KN61 RED HELOS #012",

    "ZENI BLUE HELOS #001",
    "ZENI BLUE HELOS #002",
    "ZENI BLUE HELOS #003",
    "ZENI BLUE HELOS #004",
    "ZENI BLUE HELOS #005",
    "ZENI BLUE HELOS #006",
    "ZENI BLUE HELOS #007",
    "ZENI BLUE HELOS #008",

    "ZENI RED HELOS #001",
    "ZENI RED HELOS #002",
    "ZENI RED HELOS #003",
    "ZENI RED HELOS #004",
    "ZENI RED HELOS #005",
    "ZENI RED HELOS #006",
    "ZENI RED HELOS #007",
    "ZENI RED HELOS #008",

    "RIKE BLUE HELOS #001",
    "RIKE BLUE HELOS #002",
    "RIKE BLUE HELOS #003",
    "RIKE BLUE HELOS #004",
    "RIKE BLUE HELOS #005",
    "RIKE BLUE HELOS #006",
    "RIKE BLUE HELOS #007",
    "RIKE BLUE HELOS #008",

    "RIKE RED HELOS #001",
    "RIKE RED HELOS #002",
    "RIKE RED HELOS #003",
    "RIKE RED HELOS #004",
    "RIKE RED HELOS #005",
    "RIKE RED HELOS #006",
    "RIKE RED HELOS #007",
    "RIKE RED HELOS #008",


    "Kutaisi Red AF #005",
    "Kutaisi Red AF #006",
    "Kobuleti Red AF #001",
    "Kobuleti Red AF #002",
    "Sukumi Blue AF #002",
    "Sukumi Blue AF #001",

    "heli1",

    -- *** AI transports names (different names only to ease identification in mission) ***

    -- Use any of the predefined names or set your own ones

    "transport1",
    "transport2",
    "transport3",
    "transport4",
    "transport5",
    "transport6",
    "transport7",
    "transport8",
    "transport9",
    "transport10",

}

-- *************** Optional Extractable GROUPS *****************

-- Use any of the predefined names or set your own ones

ctld.extractableGroups = {
    "extract1",
    "extract2",
    "extract3",
    "extract4",
    "extract5",
    "extract6",
    "extract7",
    "extract8",
    "extract9",
    "extract10",


}

-- ************** Logistics UNITS FOR CRATE SPAWNING ******************

-- Use any of the predefined names or set your own ones
-- When a logistic unit is destroyed, you will no longer be able to spawn crates

ctld.logisticUnits = {
    "Sochi_Logistic",
    "Gudauta_Logistic",
    "Sukumi_Logistic",
    "FARP_GH05_Logistic",
    "FARP_KN61_Logistic",
    "Senaki_Logistic",
    "Kutaisi_Logistic",
    "Kobuleti_ Logistic",
    "logistic9",
    "logistic10",
}


-- ************** UNITS ABLE TO TRANSPORT VEHICLES ******************
-- Add the model name of the unit that you want to be able to transport and deploy vehicles
-- units db has all the names or you can extract a mission.miz file by making it a zip and looking
-- in the contained mission file
ctld.vehicleTransportEnabled = {
    "76MD", -- the il-76 mod doesnt use a normal - sign so il-76md wont match... !!!! GRR
    "C-130",
}


-- ************** Maximum Units SETUP for UNITS ******************

-- Put the name of the Unit you want to limit group sizes too
-- i.e
-- ["UH-1H"] = 10,
--
-- Will limit UH1 to only transport groups with a size 10 or less
-- Make sure the unit name is exactly right or it wont work

ctld.unitLoadLimits = {

    -- Remove the -- below to turn on options
    ["UH-1H"] = 10,
    ["Mi-8MT"] = 20,
    ["SA342M"] = 2,
    ["CH-47D"] = 33,
    ["SA342Mistral"] = 1,
    ["SA342L"] = 1,
    ["C-101CC"] = 1,
    ["L-39ZA"] = 1,
}


-- ************** Allowable actions for UNIT TYPES ******************

-- Put the name of the Unit you want to limit actions for
-- NOTE - the unit must've been listed in the transportPilotNames list above
-- This can be used in conjunction with the options above for group sizes
-- By default you can load both crates and troops unless overriden below
-- i.e
-- ["UH-1H"] = {crates=true, troops=false},
--
-- Will limit UH1 to only transport CRATES but NOT TROOPS
--
-- ["SA342Mistral"] = {crates=fales, troops=true},
-- Will allow Mistral Gazelle to only transport crates, not troops

ctld.unitActions = {

    -- Remove the -- below to turn on options
    ["SA342Mistral"] = { crates = false, troops = false, internal = false },
    ["SA342L"] = { crates = false, troops = false, internal = false },
    ["SA342M"] = { crates = false, troops = false, internal = false },
    ["Ka-50"] = { crates = true, troops = false, internal = false },
    ["UH-1H"] = { crates = true, troops = true, internal = true },
    ["Mi-8MT"] = { crates = true, troops = true, internal = true },
    ["C-101CC"] = { crates = true, troops = true, internal = true },
    ["L-39ZA"] = { crates = true, troops = true, internal = true },

}

-- ************** INFANTRY GROUPS FOR PICKUP ******************
-- Unit Types
-- inf is normal infantry
-- mg is M249
-- at is RPG-16
-- aa is Stinger or Igla
-- mortar is a 2B11 mortar unit
-- You must add a name to the group for it to work
-- You can also add an optional coalition side to limit the group to one side
-- for the side - 2 is BLUE and 1 is RED
ctld.loadableGroups = {
    { name = "Standard Group", inf = 5, mg = 2, at = 2 }, -- will make a loadable group with 5 infantry, 2 MGs and 2 anti-tank for both coalitions
    { name = "Standard Group [Mi-8]", inf = 12, mg = 4, at = 2 },
    { name = "Anti Air", aa = 2 },
    { name = "Anti Tank", mg = 2, at = 4 },
    { name = "Mortar Squad", mortar = 6 },
    -- {name = "Mortar Squad Red", inf = 2, mortar = 5, side =1 }, --would make a group loadable by RED only
}

-- ************** SPAWNABLE CRATES ******************
-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
--
ctld.spawnableCrates = {
    -- name of the sub menu on F10 for spawning crates
    --crates you can spawn
    -- weight in KG
    -- Desc is the description on the F10 MENU
    -- unit is the model name of the unit to spawn
    -- cratesRequired - if set requires that many crates of the same type within 100m of each other in order build the unit
    -- side is optional but 2 is BLUE and 1 is RED
    -- internal is cargo can be carried in internal bays, set 0 for external.
    -- dont use that option with the HAWK Crates

    ["IFVs & Light Vehicles"] = {
        { weight = 706, desc = "BTR-80", unit = "BTR-80", side = 1, cratesRequired = 1, internal = 0 },
        { weight = 707, desc = "IFV BMP-2", unit = "BMP-2", side = 1, cratesRequired = 1, internal = 0 },
        { weight = 708, desc = "IFV BMP-3", unit = "BMP-3", side = 1, cratesRequired = 2, internal = 0 },
        { weight = 709, desc = "ZBD04A", unit = "ZBD04A", side = 1, cratesRequired = 2, internal = 0 },

        { weight = 701, desc = "HMMWV - TOW", unit = "M1045 HMMWV TOW", side = 2, cratesRequired = 1, internal = 0 },
        { weight = 702, desc = "HMMWV MG", unit = "M1043 HMMWV Armament", side = 2, cratesRequired = 1, internal = 0 },
        { weight = 703, desc = "Stryker ATGM", unit = "M1134 Stryker ATGM", side = 2, internal = 0 },
        { weight = 704, desc = "Stryker MGS", unit = "M1128 Stryker MGS", side = 2, internal = 0 },
        { weight = 705, desc = "IFV BRADLEY", unit = "M-2 Bradley", side = 2, cratesRequired = 2, internal = 0 },

    },

    -- weight range 731-749
    ["Tanks"] = {
        { weight = 710, desc = "MBT T-72", unit = "T-72B", side = 1, cratesRequired = 2, internal = 0 },
        { weight = 711, desc = "MBT T-80", unit = "T-80UD", side = 1, cratesRequired = 3, internal = 0 },

        { weight = 712, desc = "Leopard1A3", unit = "Leopard1A3", side = 2, cratesRequired = 2, internal = 0 },
        { weight = 713, desc = "Leopard 2", unit = "Leopard-2", side = 2, cratesRequired = 3, internal = 0 },
        { weight = 714, desc = "Challenger II", unit = "Challenger2", side = 2, cratesRequired = 3, internal = 0 }, -- blue tanks
    },

    ["IR SAM & AAA"] = {
        { weight = 757, desc = "ZSU-23-4 Shilka", unit = "ZSU-23-4 Shilka", side = 1, internal = 0 },
        { weight = 758, desc = "ZU-23 on Ural", unit = "Ural-375 ZU-23", side = 1, internal = 0 },
        { weight = 759, desc = "SA-19 Tunguska", unit = "2S6 Tunguska", side = 1, cratesRequired = 2, internal = 0 },
        { weight = 751, desc = "SA-9 Strela-1", unit = "Strela-1 9P31", side = 1, internal = 0 },
        { weight = 752, desc = "SA-13 Strela-10", unit = "Strela-10M3", side = 1, cratesRequired = 2, internal = 0 },

        { weight = 755, desc = "M163 Vulcan", unit = "Vulcan", side = 2, internal = 0 },
        { weight = 756, desc = "Gepard", unit = "Gepard", side = 2, internal = 0 },
        { weight = 753, desc = "M1097 Avenger", unit = "M1097 Avenger", side = 2, cratesRequired = 2, internal = 0 },
        { weight = 754, desc = "M6 Linebacker", unit = "M6 Linebacker", side = 2, cratesRequired = 2, internal = 0 },
    },


    -- weight range 801-849
    ["Radar SAM"] = {
        -- SA-3 system
        { weight = 801, desc = "SA-3 Search Radar", unit = "p-19 s-125 sr", side = 1, internal = 0 },
        { weight = 802, desc = "SA-3 Track Radar", unit = "snr s-125 tr", side = 1, internal = 0 },
        { weight = 803, desc = "SA-3 Launcher", unit = "5p73 s-125 ln", side = 1, internal = 0 },

        -- HQ-7 System
        { weight = 812, desc = "HQ-7 Launcher", unit = "HQ-7 Self-Propelled ln", side = 1, internal = 0 },
        { weight = 813, desc = "HQ-7 Search Radar", unit = "HQ-7 Self-Propelled str", side = 1, internal = 0 },

        -- KUB system
        { weight = 804, desc = "KUB Launcher", unit = "Kub 2P25 ln", side = 1, internal = 0 },
        { weight = 805, desc = "KUB Radar", unit = "Kub 1S91 str", side = 1, internal = 0 },

        -- BUK system
        { weight = 812, desc = "BUK Launcher", unit = "SA-11 Buk LN 9A310M1", side = 1, internal = 0 },
        { weight = 813, desc = "BUK Search Radar", unit = "SA-11 Buk SR 9S18M1", side = 1, internal = 0 },
        { weight = 814, desc = "BUK CC Radar", unit = "SA-11 Buk CC 9S470M1", side = 1, internal = 0 },

        { weight = 806, desc = "SA-8 Osa", unit = "SA-8 Osa LD 9T217", side = 1, cratesRequired = 2, internal = 0 },

        -- Hawk System
        { weight = 808, desc = "Hawk Launcher", unit = "Hawk ln", side = 2, internal = 0 },
        { weight = 809, desc = "Hawk Search Radar", unit = "Hawk sr", side = 2, internal = 0 },
        { weight = 810, desc = "Hawk Track Radar", unit = "Hawk tr", side = 2, internal = 0 },
        { weight = 811, desc = "Hawk PCP", unit = "Hawk pcp", side = 2, internal = 0 }, -- Remove this if on 1.2


        -- Tor on both sides
        { weight = 807, desc = "SA-15 Tor", unit = "Tor 9A331", cratesRequired = 2, internal = 0 },


    },

    ["Artillery"] = {
        { weight = 715, desc = "SPH 2S19 Msta", unit = "SAU Msta", side = 1, cratesRequired = 2, internal = 0 },
        { weight = 719, desc = "BM-27 MLRS", unit = "Uragan_BM-27", side = 1, cratesRequired = 2, internal = 0 },
        { weight = 718, desc = "MLRS Smerch", unit = "Smerch", side = 1, cratesRequired = 2, internal = 0 },

        { weight = 716, desc = "M-109", unit = "M-109", side = 2, cratesRequired = 2, internal = 0 },
        { weight = 717, desc = "MLRS", unit = "MLRS", side = 2, cratesRequired = 2, internal = 0 },
    },

    ["Support"] = {
        { weight = 652, desc = "ATZ-10 Fuel Truck", unit = "ATZ-10", side = 1, cratesRequired = 1, internal = 1 },
        { weight = 653, desc = "Ural-375 Ammo Truck", unit = "Ural-375", side = 1, cratesRequired = 1, internal = 0 },

        { weight = 651, desc = "M978 HEMTT Tanker", unit = "M978 HEMTT Tanker", side = 2, cratesRequired = 1, internal = 0 },
        { weight = 654, desc = "M-818 Ammo Truck", unit = "M 818", side = 2, cratesRequired = 1, internal = 0 },

        { weight = 655, desc = "SAM Repair", unit = "SAM Repair", internal = 0 },
        { weight = 656, desc = "Early Warning Radar", unit = "1L13 EWR", internal = 0 },
    },


    ["Internal Cargo"] = {
        { weight = 501, desc = "HMMWV - JTAC (internal)", unit = "Hummer", side = 2, cratesRequired = 1, internal = 1 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { weight = 502, desc = "UAZ - JTAC (internal)", unit = "UAZ-469", side = 1, cratesRequired = 1, internal = 1 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { weight = 503, desc = "Command Center (internal) ", unit = "FOB", internal = 1 },
    },
}

-- if the unit is on this list, it will be made into a JTAC when deployed
ctld.jtacUnitTypes = {
    "UAZ", "Hummer" -- there are some wierd encoding issues so if you write SKP-11 it wont match as the - sign is encoded differently...
}

--- Tells CTLD What multipart AA Systems there are and what parts they need
-- A New system added here also needs the launcher added
ctld.AASystemTemplate = {
    {
        name = "HQ-7 AA System",
        count = 2,
        parts = {
            { name = "HQ-7 Self-Propelled ln", desc = "HQ-7_LN_SP", launcher = true },
            { name = "HQ-7 Self-Propelled str", desc = "HQ-7_STR_SP" },
        },
        repair = "SAM Repair",
        systemType = "SR",
    },
    {
        name = "ROLAND AA System",
        count = 2,
        parts = {
            { name = "SAM Roland ADS", desc = "Roland Launcher", launcher = true },
            { name = "SAM Roland EWR", desc = "Roland Radar" },
        },
        repair = "SAM Repair",
        systemType = "SR",
    },
    {
        name = "HAWK SAM System",
        count = 4,
        parts = {
            { name = "Hawk ln", desc = "Hawk Launcher", launcher = true },
            { name = "Hawk tr", desc = "Hawk Track Radar" },
            { name = "Hawk sr", desc = "Hawk Search Radar" },
            { name = "Hawk pcp", desc = "Hawk PCP" },
        },
        repair = "SAM Repair",
        systemType = "MR",
    },
    {
        name = "BUK SAM System",
        count = 3,
        parts = {
            { name = "SA-11 Buk LN 9A310M1", desc = "BUK Launcher", launcher = true },
            { name = "SA-11 Buk CC 9S470M1", desc = "BUK CC Radar" },
            { name = "SA-11 Buk SR 9S18M1", desc = "BUK Search Radar" },
        },
        repair = "SAM Repair",
        systemType = "MR"
    },
    {
        name = "KUB SAM System",
        count = 2,
        parts = {
            { name = "Kub 2P25 ln", desc = "KUB Launcher", launcher = true },
            { name = "Kub 1S91 str", desc = "KUB Radar" },
        },
        repair = "SAM Repair",
        systemType = "MR",
    },
    {
        name = "SA-3 SAM System",
        count = 3,
        parts = {

            { name = "5p73 s-125 ln", desc = "SA-3 Launcher", launcher = true },
            { name = "snr s-125 tr", desc = "SA-3 Track Radar" },
            { name = "p-19 s-125 sr", desc = "SA-3 Search Radar" },
        },
        repair = "SAM Repair",
        systemType = "MR",
    },

}
