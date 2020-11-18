-- Author: Wildcat (Chandawg)
-- Date Created: 04 Nov 2020
-- Same principle used to spawn UAVs, but going to spawn Tankers and AWACs
-- Spawns

--- Event Handler
BlueAWACs_EventHandler = EVENTHANDLER:New()
BlueAWACs_EventHandler:HandleEvent( EVENTS.Birth )

function BlueAWACs_EventHandler:OnEventBirth( EventData )
  if EventData.IniDCSGroupName == 'Magic 1-1#001' then 
  MESSAGE:New("Magic 1-1 is on station contact on channel 251.000 MHz \nBlue Team has 3 remaining AWACs",10):ToBlue()
  elseif EventData.IniDCSGroupName == 'Magic 1-1#002' then
  MESSAGE:New("Magic 1-1 is on station contact on channel 251.000 MHz \nBlue Team has 2 remaining AWACs",10):ToBlue()
  elseif EventData.IniDCSGroupName == 'Magic 1-1#003' then
  MESSAGE:New("Magic 1-1 is on station contact on channel 251.000 MHz \nBlue Team has 1 remaining AWACs",10):ToBlue()
  elseif EventData.IniDCSGroupName == 'Magic 1-1#004' then
  MESSAGE:New("Magic 1-1 is on station contact on channel 251.000 MHz \nBlue Team has no remaining AWACs",10):ToBlue()
  else
  --nothing
  end
end


---Objects to be spawned with attributes set
Spawn_Blue_AWACs = SPAWN:NewWithAlias("AWACS Blue","Magic 1-1")
    :InitLimit(1,4)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Magic_11)
        Magic_11:CommandSetCallsign(2, 1)
        Magic_11:TaskOrbitCircle(7000, 700)
        Magic_11:ComandSetFrequency(251.000)
        Magic_11:EnRouteTaskAWACS()
      end)
    --:SpawnScheduled(30,0.5)

--- Event Handler
BlueTanker1_EventHandler = EVENTHANDLER:New()
BlueTanker1_EventHandler:HandleEvent( EVENTS.Birth )

function BlueTanker1_EventHandler:OnEventBirth( EventData )
  if EventData.IniDCSGroupName == 'Texaco 1-1#001' then 
  MESSAGE:New("Texaco 1-1 (Basket) is on station contact on channel 142.000 MHz \nBlue Team has 1 remaining Basket Tanker",10):ToBlue()
  elseif EventData.IniDCSGroupName == 'Texaco 1-1#002' then
  MESSAGE:New("Texaco 1-1 (Basket) is on station contact on channel 142.000 MHz \nBlue Team has no remaining Basket Tankers",10):ToBlue()
  else
  --nothing
  end
end

Spawn_Blue_TankerBasket = SPAWN:NewWithAlias("Tanker Basket Blue","Texaco 1-1")
    :InitLimit(1,2)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Texaco_11)
        Texaco_11:CommandSetCallsign(1, 2)
        Texaco_11:TaskOrbitCircle(5000, 600)
        Texaco_11:ComandSetFrequency(142.000)
        Texaco_11:EnRouteTaskTanker()
      end)
    --:SpawnScheduled(30,0.5)

--- Event Handler
BlueTanker2_EventHandler = EVENTHANDLER:New()
BlueTanker2_EventHandler:HandleEvent( EVENTS.Birth )

function BlueTanker2_EventHandler:OnEventBirth( EventData )
  if EventData.IniDCSGroupName == 'Texaco 2-1#001' then 
  MESSAGE:New("Texaco 2-1 (Boom) is on station contact on channel 141.000 MHz \nBlue Team has 1 remaining Boom Tanker",10):ToBlue()
  elseif EventData.IniDCSGroupName == 'Texaco 2-1#002' then
  MESSAGE:New("Texaco 2-1 (Boom) is on station contact on channel 141.000 MHz \nBlue Team has no remaining Boom Tankers",10):ToBlue()
  else
  --nothing
  end
end

Spawn_Blue_TankerBoom = SPAWN:NewWithAlias("Tanker Boom Blue","Texaco 2-1")
    :InitLimit(1,2)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Texaco_21)
        Texaco_21:CommandSetCallsign(1, 2)
        Texaco_21:TaskOrbitCircle(5000, 600)
        Texaco_21:ComandSetFrequency(141.000)
        Texaco_21:EnRouteTaskTanker()
      end)
    --:SpawnScheduled(30,0.5)

--- Event Handler
RedAWACs_EventHandler = EVENTHANDLER:New()
RedAWACs_EventHandler:HandleEvent( EVENTS.Birth )

function RedAWACs_EventHandler:OnEventBirth( EventData )
  if EventData.IniDCSGroupName == 'Overlord 1-1#001' then 
  MESSAGE:New("Overlord 1-1 is on station contact on channel 121.000 MHz \nRed Team has 3 remaining AWACs",10):ToRed()
  elseif EventData.IniDCSGroupName == 'Overlord 1-1#002' then
  MESSAGE:New("Overlord 1-1 is on station contact on channel 121.000 MHz \nRed Team has 2 remaining AWACs",10):ToRed()
  elseif EventData.IniDCSGroupName == 'Overlord 1-1#003' then
  MESSAGE:New("Overlord 1-1 is on station contact on channel 121.000 MHz \nRed Team has 1 remaining AWACs",10):ToRed()
  elseif EventData.IniDCSGroupName == 'Overlord 1-1#004' then
  MESSAGE:New("Overlord 1-1 is on station contact on channel 121.000 MHz \nRed Team has no remaining AWACs",10):ToRed()
  else
  --nothing
  end
end

Spawn_Red_AWACs = SPAWN:NewWithAlias("AWACS Red","Overlord 1-1")
    :InitLimit(1,4)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Overlord_11)
        Overlord_11:CommandSetCallsign(1, 1)
        Overlord_11:TaskOrbitCircle(7000, 700)
        Overlord_11:ComandSetFrequency(121.000)
        Overlord_11:EnRouteTaskAWACS()
      end)

--- Event Handler
RedTanker1_EventHandler = EVENTHANDLER:New()
RedTanker1_EventHandler:HandleEvent( EVENTS.Birth )

function RedTanker1_EventHandler:OnEventBirth( EventData )
  if EventData.IniDCSGroupName == 'Shell 1-1#001' then 
  MESSAGE:New("Shell 1-1 (Basket) is on station contact on channel 142.000 MHz \nRed Team has 1 remaining Basket Tanker",10):ToRed()
  elseif EventData.IniDCSGroupName == 'Shell 1-1#002' then
  MESSAGE:New("Shell 1-1 (Basket) is on station contact on channel 142.000 MHz \nRed Team has no remaining Basket Tankers",10):ToRed()
  else
  --nothing
  end
end

Spawn_Red_TankerBasket = SPAWN:NewWithAlias("Tanker Basket Red","Shell 1-1")
    :InitLimit(1,2)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Shell_11)
        Shell_11:CommandSetCallsign(3, 1)
        Shell_11:TaskOrbitCircle(5000, 600)
        Shell_11:ComandSetFrequency(142.000)
        Shell_11:EnRouteTaskTanker()
      end)
    --:SpawnScheduled(30,0.5)

--- Event Handler
RedTanker2_EventHandler = EVENTHANDLER:New()
RedTanker2_EventHandler:HandleEvent( EVENTS.Birth )

function RedTanker2_EventHandler:OnEventBirth( EventData )
  if EventData.IniDCSGroupName == 'Shell 2-1#001' then 
  MESSAGE:New("Shell 2-1 (Boom) is on station contact on channel 141.000 MHz \nRed Team has 1 remaining Boom Tanker",10):ToRed()
  elseif EventData.IniDCSGroupName == 'Shell 2-1#002' then
  MESSAGE:New("Shell 2-1 (Boom) is on station contact on channel 141.000 MHz \nRed Team has no remaining Boom Tankers",10):ToRed()
  else
  --nothing
  end
end

Spawn_Red_TankerBoom = SPAWN:NewWithAlias("Tanker Boom Red","Shell 2-1")
    :InitLimit(1,2)
    :InitKeepUnitNames(true)
    :OnSpawnGroup(
      function(Shell_21)
        Shell_21:CommandSetCallsign(3, 2)
        Shell_21:TaskOrbitCircle(4000, 600)
        Shell_21:ComandSetFrequency(141.000)
        Shell_21:EnRouteTaskTanker()
      end)
    --:SpawnScheduled(30,0.5)
              
----Function to actually spawn the UAV from the players nose      
function BlueAWACs(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Blue_AWACs:SpawnFromVec3(spawnVec3)
end

function BlueTankerBasket(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Blue_TankerBasket:SpawnFromVec3(spawnVec3)
end

function BlueTankerBoom(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Blue_TankerBoom:SpawnFromVec3(spawnVec3)
end

function RedAWACs(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Red_AWACs:SpawnFromVec3(spawnVec3)
end

function RedTankerBasket(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Red_TankerBasket:SpawnFromVec3(spawnVec3)
end

function RedTankerBoom(group,rng)
  local range = rng * 1852
  local hdg = group:GetHeading()
  local pos = group:GetPointVec2()
  local spawnPt = pos:Translate(range, hdg, true)
  local spawnVec3 = spawnPt:GetVec3() 
  local spawnUnit = Spawn_Red_TankerBoom:SpawnFromVec3(spawnVec3)
end

----Define the client to have the menu
local SetClient3 = SET_CLIENT:New():FilterCoalitions("blue"):FilterPrefixes({" Blue AF"}):FilterStart()
local SetClient4 = SET_CLIENT:New():FilterCoalitions("red"):FilterPrefixes({" Red AF"}):FilterStart()
----Menus for the client
local function AWACs_Tanker_MENU()
  SetClient3:ForEachClient(function(client3)
      if (client3 ~= nil) and (client3:IsAlive()) then 
      local group3 = client3:GetGroup()
      local groupName = group3:GetName()
            BlueMenuGroup2 = group3
            BlueMenuGroupName2 = BlueMenuGroup2:GetName()
            ----Main Menu
            BlueSpawnAWACs = MENU_GROUP:New( BlueMenuGroup2, "AWACS-Tankers" )
            ---- Sub Menu
            BlueSpawnAWACsmenu = MENU_GROUP:New( BlueMenuGroup2, "Spawn AWACs-Tankers", BlueSpawnAWACs)
            ---- Command for the sub Menu the number on the end is the argument for the command (the rng) for the function
            BlueSpawnAWACsrng5 = MENU_GROUP_COMMAND:New( BlueMenuGroup2, "E-3 5 nmi in front co-altitude", BlueSpawnAWACs, BlueAWACs, BlueMenuGroup2, 5)
            BlueSpawnTanker1rng5 = MENU_GROUP_COMMAND:New( BlueMenuGroup2, "KC-135MPRS 5 nmi in front co-altitude", BlueSpawnAWACs, BlueTankerBasket, BlueMenuGroup2, 5)
            BlueSpawnTanker2rng5 = MENU_GROUP_COMMAND:New( BlueMenuGroup2, "KC-135 5 nmi in front co-altitude", BlueSpawnAWACs, BlueTankerBoom, BlueMenuGroup2, 5)
            ---- Enters log information
            env.info("Player name: " ..client3:GetPlayerName())
            env.info("Group Name: " ..group3:GetName())
            SetClient3:Remove(client3:GetName(), true)
    end
  end)
timer.scheduleFunction(AWACs_Tanker_MENU,nil,timer.getTime() + 1)
end
local function AWACs_Tanker_MENU2()
  SetClient4:ForEachClient(function(client4)
      if (client4 ~= nil) and (client4:IsAlive()) then 
      local group4 = client4:GetGroup()
      local groupName = group4:GetName()
            RedMenuGroup2 = group4
            RedMenuGroupName2 = RedMenuGroup2:GetName()
            ----Main Menu
            RedSpawnAWACs = MENU_GROUP:New( RedMenuGroup2, "AWACS-Tankers" )
            ---- Sub Menu
            RedSpawnAWACsmenu = MENU_GROUP:New( RedMenuGroup2, "Spawn AWACs-Tankers", RedSpawnAWACs)
            ---- Command for the sub Menu the number on the end is the argument for the command (the rng) for the function
            RedSpawnAWACsrng5 = MENU_GROUP_COMMAND:New( RedMenuGroup2, "E-3 5 nmi in front co-altitude", RedSpawnAWACs, RedAWACs, RedMenuGroup2, 5)
            RedSpawnTanker1rng5 = MENU_GROUP_COMMAND:New( RedMenuGroup2, "KC-135MPRS 5 nmi in front co-altitude", RedSpawnAWACs, RedTankerBasket, RedMenuGroup2, 5)
            RedSpawnTanker2rng5 = MENU_GROUP_COMMAND:New( RedMenuGroup2, "KC-135 5 nmi in front co-altitude", RedSpawnAWACs, RedTankerBoom, RedMenuGroup2, 5)
            ---- Enters log information
            env.info("Player name: " ..client4:GetPlayerName())
            env.info("Group Name: " ..group4:GetName())
            SetClient4:Remove(client4:GetName(), true)
    end
  end)
timer.scheduleFunction(AWACs_Tanker_MENU2,nil,timer.getTime() + 1)
end
AWACs_Tanker_MENU()
AWACs_Tanker_MENU2()