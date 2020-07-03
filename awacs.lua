local logging = require("logging")
local state = require("state")

local M = {}

local log = logging.Logger:new("AWACS")

local function spawnAWACS(spawnTemplatePrefix, spawnLimit)
    log:info("Spawning $1", spawnTemplatePrefix)
    SPAWN:New(spawnTemplatePrefix)
         :InitLimit(1, spawnLimit)
         :InitRepeat()
         :SpawnScheduled(3600, 0.05)
end
-- Set detection vars and objects for Red AI CAP
RedDetectionSetGroup = SET_GROUP:New()
RedDetectionSetGroup:FilterCoalitions("red")
RedDetectionSetGroup:FilterPrefixes( { "EWR", "AWACS" } )
RedDetectionSetGroup:FilterStart()
RedDetection = DETECTION_AREAS:New( RedDetectionSetGroup, 50000 )
RedA2ADispatcher = AI_A2A_DISPATCHER:New( RedDetection )

-- Set detection vars and objects for Blue AI CAP
BlueDetectionSetGroup = SET_GROUP:New()
BlueDetectionSetGroup:FilterCoalitions("blue")
BlueDetectionSetGroup:FilterPrefixes( { "EWR", "AWACS" } )
BlueDetectionSetGroup:FilterStart()
BlueDetection = DETECTION_AREAS:New( BlueDetectionSetGroup, 50000 )
BlueA2ADispatcher = AI_A2A_DISPATCHER:New( BlueDetection )



--Zones for CAP
KrasC_NorthCAPZone = ZONE_POLYGON:New( "Kras-C CAP Zone", GROUP:FindByName( "Kras-C CAP Zone" ) )
Vaziani_SouthCAPZone = ZONE_POLYGON:New( "Vaziani CAP Zone", GROUP:FindByName( "Vaziani CAP Zone" ) )

--Zones for CAS
-- KrasC_NorthCASZone = ZONE_POLYGON:New( "Kras-C CAS Zone", GROUP:FindByName( "Kras-C CAS Zone" ) )
-- KrasC_SouthCASZone = ZONE=POLYGON:New( "Vaziani CAS Zone", GROUP:FindByName( "Vaziani CAS Zone" ) )

function M.onMissionStart(awacsBases, awacsSpawnLimit)
    log:info("Configuring AWACS at mission start")

    for _, baseName in pairs(awacsBases) do
        local baseOwner = state.getOwner(baseName)
        log:info("$1 owner is $2", baseName, baseOwner)
        if baseOwner == "red" then
            spawnAWACS(string.format("%s Red AWACS", baseName), awacsSpawnLimit)
        elseif baseOwner == "blue" then
            spawnAWACS(string.format("%s Blue AWACS", baseName), awacsSpawnLimit)
        end
    end

    local KrasC_Ownership = state.getOwner("Krasnodar-Center")
    if KrasC_Ownership == "red" then
      RedA2ADispatcher:SetSquadron( "41st Fighter Aviation Regiment", AIRBASE.Caucasus.Krasnodar_Center, { "41st Fighter Aviation Regiment" }, 8 ) -- MiG-25 Squadron
      RedA2ADispatcher:SetSquadronCap( "41st Fighter Aviation Regiment", KrasC_NorthCAPZone, 1000, 12000, 600, 800, 800, 1200, "BARO" )
      RedA2ADispatcher:SetSquadronCapInterval( "41st Fighter Aviation Regiment", 2, 180, 900, 1 )
    elseif KrasC_Ownership == "blue" then
      BlueA2ADispatcher:SetSquadron( "10th Tactical Fighter Squadron", AIRBASE.Caucasus.Krasnodar_Center, { "10th Tactical Fighter Squadron" }, 8 ) --F16 Squadron
      BlueA2ADispatcher:SetSquadronCap( "10th Tactical Fighter Squadron", KrasC_NorthCAPZone, 1000, 12000, 600, 800, 800, 1200, "BARO" )
      BlueA2ADispatcher:SetSquadronCapInterval( "10th Tactical Fighter Squadron", 2, 180, 900, 1 )
    end
    if KrasC_Ownership == "blue" then
      TEXACOTankerBlue = SPAWN
        :NewWithAlias("B_TANKER_KC135MPRS_1","TEXACO Blue 1")
        :InitLimit(1,3)
        :InitCleanUp(30)
        :OnSpawnGroup(function(SpawnedGroup)
          MESSAGE:New("TEXACO is back on station",25,"TEXACO"):ToBlue()
          end)
        :SpawnScheduled(1800,0.1)
    elseif KrasC_Ownership == "red" then
      TEXACOTankerRed = SPAWN
        :NewWithAlias("R_TANKER_KC135MPRS_1","TEXACO Red 1")
        :InitLimit(1,3)
        :InitCleanUp(30)
        :OnSpawnGroup(function(SpawnedGroup)
          MESSAGE:New("TEXACO is back on station",25,"TEXACO"):ToRed()
          end)
        :SpawnScheduled(1800,0.1)
    end   

    local Vaziani_Ownership = state.getOwner("Vaziani")
    if Vaziani_Ownership == "red" then
      RedA2ADispatcher:SetSquadron( "472nd Fighter Aviation Regiment", AIRBASE.Caucasus.Vaziani, { "472nd Fighter Aviation Regiment" }, 8 ) -- MiG-25 Squadron
      RedA2ADispatcher:SetSquadronCap( "472nd Fighter Aviation Regiment", Vaziani_SouthCAPZone, 1000, 12000, 600, 800, 800, 1200, "BARO" )
      RedA2ADispatcher:SetSquadronCapInterval( "472nd Fighter Aviation Regiment", 2, 180, 900, 1 )
    elseif Vaziani_Ownership == "blue" then
      BlueA2ADispatcher:SetSquadron( "313th Tactical Fighter Squadron", AIRBASE.Caucasus.Vaziani, { "313th Tactical Fighter Squadron" }, 8 ) --F16 Squadron
      BlueA2ADispatcher:SetSquadronCap( "313th Tactical Fighter Squadron", Vaziani_SouthCAPZone, 1000, 12000, 600, 800, 800, 1200, "BARO" )
      BlueA2ADispatcher:SetSquadronCapInterval( "313th Tactical Fighter Squadron", 2, 180, 900, 1 )
    end
    if Vaziani_Ownership == "blue" then
      TEXACOTankerBlue2 = SPAWN
        :NewWithAlias("B_TANKER_KC135MPRS_2","TEXACO Blue 2")
        :InitLimit(1,3)
        :InitCleanUp(30)
        :OnSpawnGroup(function(SpawnedGroup)
          MESSAGE:New("TEXACO is back on station",25,"TEXACO"):ToBlue()
          end)
        :SpawnScheduled(1800,0.1)
    elseif Vaziani_Ownership == "red" then
      TEXACOTankerRed2 = SPAWN
        :NewWithAlias("R_TANKER_KC135MPRS_2","TEXACO Red 2")
        :InitLimit(1,3)
        :InitCleanUp(30)
        :OnSpawnGroup(function(SpawnedGroup)
          MESSAGE:New("TEXACO is back on station",25,"TEXACO"):ToRed()
          end)
        :SpawnScheduled(1800,0.1)
    end       
end

RedA2ADispatcher:SetDefaultTakeoffInAir()
RedA2ADispatcher:SetDefaultLandingAtEngineShutdown()
BlueA2ADispatcher:SetDefaultTakeoffInAir()
BlueA2ADispatcher:SetDefaultLandingAtEngineShutdown()

TEXACOTankerBlue3 = SPAWN
  :NewWithAlias("B_TANKER_S3_1","TEXACO Blue 3")
  :InitLimit(1,3)
  :InitCleanUp(30)
  :OnSpawnGroup(function(SpawnedGroup)
    MESSAGE:New("TEXACO 3-1 is back on station",25,"TEXACO"):ToBlue()
    end)
  :SpawnScheduled(1800,0.1)
TEXACOTankerRed3 = SPAWN
  :NewWithAlias("R_TANKER_S3_1","TEXACO Red 3")
  :InitLimit(1,3)
  :InitCleanUp(30)
  :OnSpawnGroup(function(SpawnedGroup)
    MESSAGE:New("TEXACO 3-1 is back on station",25,"TEXACO"):ToBlue()
    end)
  :SpawnScheduled(1800,0.1)
BlueCarrierAWACS = SPAWN
  :NewWithAlias("B_AWACS_E2_1","Overlord Blue 1")
  :InitLimit(1,3)
  :InitCleanUp(30)
  :OnSpawnGroup(function(SpawnedGroup)
    MESSAGE:New("Overlord 1-1 is back on station",25,"Overlord"):ToBlue()
    end)
  :SpawnScheduled(1800,0.1)
RedCarrierAWACS = SPAWN
  :NewWithAlias("R_AWACS_E2_1","Overlord Red 1")
  :InitLimit(1,3)
  :InitCleanUp(30)
  :OnSpawnGroup(function(SpawnedGroup)
    MESSAGE:New("Overlord 1-1 is back on station",25,"Overlord"):ToRed()
    end)
  :SpawnScheduled(1800,0.1)
return M
