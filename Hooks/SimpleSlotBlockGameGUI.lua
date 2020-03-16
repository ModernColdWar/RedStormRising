local ssb = {} -- DONT REMOVE!!!

--[[

   Simple Slot Block - V 1.1

   Put this file in C:/Users/<YOUR USERNAME>/DCS/Scripts for 1.5 or C:/Users/<YOUR USERNAME>/DCS.openalpha/Scripts for 2.0

   This script will use flags to disable and enable slots based on aircraft name and / or player prefix

   By Default all slots are enabled unless you change the ssb.enabledFlagValue to anything other than 0 or add a clan
   tag to the ssb.prefixes list and set an aircraft group name to contain it.

   To set a Flag value in DCS use the DO SCRIPT action and put in:

   trigger.action.setUserFlag("GROUP_NAME",100)

   Where GROUP_NAME is the name of the flag you want to change and 100 the value you want to set the flag too.

   As an example, there are two aircraft groups, HELI1 and HELI2 and the initial flag to turn on SSB

   You have a trigger that runs at the start of the mission with a DO SCRIPT that looks like so:

   trigger.action.setUserFlag("SSB",100)

   trigger.action.setUserFlag("HELI1",0)
   trigger.action.setUserFlag("HELI2",100)

   This will make HEL21 unusable until that flag is changed to 0 (assuming the ssb.enabledFlagValue is 0).
   The SSB flag is required to turn on slot blocking for that mission

   The flags will NOT interfere with mission flags
   
   Additions:
   
   * 2017-10-19 - FlightControl
     
     You can now kick players out of their airplane or unit back to spectators during your running missions.
     This by setting user flags with the key the group name of the group seated by the player, to a value other than zero!
     
     => trigger.action.setUserFlag("HELI2",100) -- This will kick the group HELI2 when in the game.
     
       - Kicking players is enabled by default, but you can disable the function by modifying ssb.KickPlayers.
         => ssb.kickPlayers = true -- (default) This will enable the players to be kicked. 
         => ssb.kickPlayers = false -- This will disable the players to be kicked. 
         
       - Slotblocker will check upon a defined time interval whether a player needs to be kicked.
         => ssb.kickTimeInterval = 1 -- (default) Check every 1 seconds if a player needs to be kicked.
         => ssb.kickTimeInterval = 5 -- Check every 5 seconds if a player needs to be kicked.
         
       - By default, when a player gets kicked, its slot will be automatically unblocked.
         But maybe the mission designer wants to mission to be in control which slots get unblocked.
         => ssb.kickReset = true -- (default) The slot will be automatically reset to open, after kicking the player.
         => ssb.kickReset = false -- The slot will NOT be automatically reset to open, after kicking the player.

       

--]]

ssb.showEnabledMessage = false -- if set to true, the player will be told that the slot is enabled when switching to it
ssb.controlNonAircraftSlots = true -- if true, only unique DCS Player ids will be allowed for the Commander / GCI / Observer Slots


-- New addon version 1.1 -- kicking of players.
ssb.kickPlayers = false -- Change to false if you want to disable to kick players.
ssb.kickTimeInterval = 1 -- Change the amount of seconds if you want to shorten the interval time or make the interval time longer.
ssb.kickReset = false -- The slot will be automatically reset to open, after kicking the player.
ssb.kickTimePrev = 0 -- leave this untouched!


-- If you set this to 0, all slots are ENABLED
-- by default as every flag starts at 0.
-- If you set this to anything other than 0 all slots
-- will be DISABLED BY DEFAULT!!!
-- Each slot will then have to be manually enabled via
-- trigger.action.setUserFlag("GROUP_NAME",100)
-- where GROUP_NAME is the group name (not pilot name) and 100 is the value you're setting the flag too which must
-- match the enabledFlagValue
ssb.enabledFlagValue = 0  -- what value to look for to enable a slot.


-- any aircraft slot controlled by the GROUP Name (not pilot name!)
-- that contains a prefix below will only allow players with that prefix
-- to join the slot
--
-- NOTE: the player prefix must match exactly including case
-- The examples below can be turned on by removing the -- in front
--
ssb.prefixes = {
    -- "-=104th=-",
    -- "-=VSAAF=-",
    -- "ciribob", -- you could also add in an actual player name instead
    "some_clan_tag",
    "-=AnotherClan=-",
}


-- any NON aircraft slot eg JTAC / GCI / GAME COMMANDER
-- will only allow certain PLAYER IDS
-- PLAYER IDS are unique DCS ids that can't be changed or spoofed
-- This script will output them when a player changes slots so you can copy them out easily :)
-- This will only take effect if: ssb.controlNonAircraftSlots = true
ssb.commanderPlayerUCID = {
  "9afc4637083feaf599e78b25b37adf25",
  "053ec863e71f9b83f1dc3155a3563ee6",
  "f47be7b9564d03e6d8a75313efeba92a",
  "64cb0b85fffe51c3e79ecd8f13766ded",
  "0f8240487915af76a6f44a41c01cde47",
  "182fb65bdbbdf9566d7cefeaab8c3c25",
  "7d5c7a1b8bf4e5bee87cf9fd20d3a90c",
  "e2b6cc3261d5513faaaffe8a7c157a32",
  "a0d2bd3f8eea70563d49cae543f4ed8f",
  "117bc9e9faafa19d71f099d650cf1b0c",
  "ebb1471000e15b3ca240910d82342503",
  "e711c21cecbfb91534afa41275027291",
  "57c75549549a256464978b7a7deba4c8",
  "9d70024558a2a3949c2ae9b8b9f79669",
  "99bc992d15a8b9366c1af3873f53a895", --Capt.Fdez
  "e5d0f5316232e5802ced7cc4c86d2c95",
  "5d619981c0a192bda60c927bd6fbccf9",
  "231aa8ac940aa8a712c1f17c2a3f0122",
  "24b0e1cfc1b27e375d38a98a43db9779",
  "cbb43fc99e978ee535b86653d14e5dbc",
  "d7f6161e6401a1c9c1f31ba7315e647c",
  "60eaa32a48cdf3b1162739acf7cfec28", --DakiBajoMoj
  "6e1c8117ab788fa693feec6326320a5e",
  "842514dc165092ba9631f8c7d2052d0a",
  "837f1acd1132ed0a60f2a6a1f57bcc1c", --Smitty
  "263d36e3b60782a6c16e2b3c5cebf3f9", --mad rabbit
  "b12d9af45f2b08a353f1e706e034eaec",
  "0a312f0e5531d0fb0e1b1d90bb559fa3",
  "e011e49e75560dbe802d50cd0f1ce68d",
  "80981e82a3f8b8178c232ddc96d7fe40",
  "3beb7082568d91bdeb29282d840c4e76",
  "3b1623a591687015f620aaba1598b3ca",
  "6151a2842ea86fd5bf7274fdf0cce579",
  "67d27f9376433f555b1ae71c2872c584",
  "e5f8848b3ef84a88c635e5bc2a8e2a41",
  "f3120f75fa5d66e5a1adaeea4f303c3d",
  "a9a6ba83cc166d960fcf7ef3d8a20eb9",
  "c0fda776e215e597c37c92fb9dde70fb",
  "9d76164a91c872953a4f1ab378f0e008",
  "a78d9cc5ad679f472dc36f66c71d99db", --Canuck
  "dc91af6f5f48dd94c89ace508c17cc69",
  "eae6f83ee3693287e92229d7eeab25b3",
  "5df2d8f9d4675adf07a1d0f7eed7f9e0",
  "b148135d459915551e3d2b5489821c16",
  "00e5296e187ccfb8ee5edb55a7968d39", --★ВАРЯГ★
  "25bd8aec82ad88e26c5534abddb3cc22", --HanSolo
  "b0d7c14dd6fe1ac1ef203643512f4387", --Two Lives
  "aea4fb0972eb001320d390b7a955356b", --НовоБранец 
  "1d086e78fb0870ad682ff5ee90aa94fd", ---=WildCat=-
  "22f8d3edba38b8052c3b82242262a867", --Shatten55 
  "a1aef3ef90d4e611eb8bd40a21ab26cd", --Coldays
  "46f14d9df21bcca261da5d54ff77b6a8", --Winston
  "630959d9628dce969646b5ce279a5996", --crazzymrbc
  "90d0af5d35b62cc5012de966b5bd1dcf", --Harkonnen
  "6e14d6e4deb4bf3b08d99713754cd1dc", --n0xy Steam
  "3dd6e3bcd9f99a8826e8f9791dc15199", --Sakhalin66
  "4052f4b970efd04829623d087898a66f", --=KAG=Zakha
  "53c1017106f484956c9e56d8c4b85acb", --GenaPilot
  "18228f3b7ecb8b5af9cb7965870d3f1b", --EARL 4-2 | H4nS0L0
  "822f0042190141165d100ccffe8d2cbf", --EARL 1-4 | alxz
  "fff7b6fabadc7339a246fa5330ceb3b2", --SaabFAN
  "a1f7bf58006730415c9cdda22b2f89b2", --EARL 6-4 | CYPHER
  "5d194005968acd3db845fdae1f1575e9", --Checklist
  "07aa971b0e583a05c69dc06075bedabf", --HansPeter
  "703a4d348871ec2fe9cac9cd2168f609", --NightStalker
  "5cb74e04677581b97c65d7ac67872b99", --Woodstock
  "a73cc77ec3926ac636a4fd419f1c0fb5", --8==D Jarhead
  "c7dade15a8a58dca9d91e12402b77e65", --8==D Jarhead
  "b7477d13cfac623b3ca55e1e2dd0df1f", --8==D Guns
  "e64dcbab81dcdb157439018fc6e76488", --8==D Zooker
  "e1277ddbc6cc620bfbc9ceb0f57dc19c", --Airplaneman321
  "2e9713fc055304fe1bd6c6c778c0f620", --LeoNerd
  "91ec71924c23f4f15d785f5d7105e6b3", --Salad
  "87dd983a6c5b678de30c9adb55b18cf4", --n0xy Standalone
  "9b1a9d6714bfc414eb0c2e5158f75c89", ---=*26th*=- | Pakster
  "4f306d55e7ca9d3c683ebd983ad6c859", --Firefly
  "afce946e4b300ebc03bbbfdee7b07f31", --<64>Kazansky
  "10fb130391f045766bb836e7c9f66c2c", --Viper 77|Gandalf
  "964158664f15dd3d7fbb0ea80c6b296f", --The State|LTJG SNOT
  "20dd4b54a9fc51df4d38cd8955103361", --Disco
  "4c38b2e3c3647473512e5400017df50e", --8==D Ritt
  "92fd1d66e41dfa65c7dd73b4f309db87", --8==D Texas
  "f10c00accc6b3f694490dbb307988e1d", --ROGUE | Archangel
  "6cb230729c620cd22eea9a1900279dcb", --GasMachine
  "2afada4c6dcd47147a1140cea34bc43a", --8==D Redback
  "d64300a70517b5878f2aae5cc4e96968", --8==D Shively
  "a72632f9d4aef4bc3fc12fb0a6bcdc87", --=R|D= johnnytrump
  "d125549aa96ca9c8c021e7bfb1028d7c", --Tester
  "d26bb6e1f0b5268626d41a0feef17727", --Shabi
  "b67841fbaf484d62fd93c159f00a5a78", --ALA15-Snake
  "19db9ec1f7b12df8c89360e17a31d7ef", --VS33 Stroke
  "53ecb670a7fa0147ccf6ab8af0eb7f9d", --wolfy
  "1d62619fb7ccd513e9f7cd639ad595bb", --Lam, added by Mobius
  "0905260d71275b3f8051e42d73b96a19", --{WD} bert, added by Capt.Fdez
  "7e8563b5c0ae6d9657de5758395c2406", -- ZZ added by deebix
  "079236f5f48b0350bdaf364d042dccfe", -- rocket_knight added by deebix
  "09bc71361a591195159e2b84dfc67482", --ROSS Pups added by deebix
  "8f3e2a5beadbd739a973027607f4a5cc", --Rigez added by mad rabbit
}

ssb.version = "1.1"



-- Logic for determining if player is allowed in a slot
function ssb.shouldAllowAircraftSlot(_playerID, _slotID)
    -- _slotID == Unit ID unless its multi aircraft in which case slotID is unitId_seatID

    local _groupName = ssb.getGroupName(_slotID)

    if _groupName == nil or _groupName == "" then
        net.log("SSB - Unable to get group name for slot " .. _slotID)
        return true
    end

    _groupName = ssb.trimStr(_groupName)

    if not ssb.checkClanSlot(_playerID, _groupName) then
        return false
    end

    -- check flag value
    local _flag = ssb.getFlagValue(_groupName)

    if _flag == ssb.enabledFlagValue then
        return true
    end

    return false

end


-- Logic to allow a player in a slot
function ssb.allowAircraftSlot(_playerID, _slotID)
    -- _slotID == Unit ID unless its multi aircraft in which case slotID is unitId_seatID (added by FlightControl)

    local _groupName = ssb.getGroupName(_slotID)

    if _groupName == nil or _groupName == "" then
        net.log("SSB - Unable to get group name for slot " .. _slotID)
        return true
    end

    _groupName = ssb.trimStr(_groupName)

    if not ssb.checkClanSlot(_playerID, _groupName) then
        return false
    end

    -- check flag value
    local _result = ssb.setFlagValue(_groupName, 0)

    return _result

end

function ssb.checkClanSlot(_playerID, _unitName)

    for _, _value in pairs(ssb.prefixes) do

        if string.find(_unitName, _value, 1, true) ~= nil then

            net.log("SSB - " .. _unitName .. " is clan slot for " .. _value)

            local _playerName = net.get_player_info(_playerID, 'name')

            if _playerName ~= nil and string.find(_playerName, _value, 1, true) then

                net.log("SSB - " .. _playerName .. " is clan member for " .. _value .. " for " .. _unitName .. " Allowing so far")
                --passed clan test, carry on!
                return true
            end

            if _playerName ~= nil then
                net.log("SSB - " .. _playerName .. " is NOT clan member for " .. _value .. " for " .. _unitName .. " Rejecting")
            end

            -- clan tag didnt match, quit!
            return false
        end
    end

    return true
end

function ssb.getFlagValue(_flag)

    local _status, _error = net.dostring_in('server', " return trigger.misc.getUserFlag(\"" .. _flag .. "\"); ")

    if not _status and _error then
        net.log("SSB - error getting flag: " .. _error)
        return tonumber(ssb.enabledFlagValue)
    else

        --disabled
        return tonumber(_status)
    end
end

function ssb.setFlagValue(_flag, _number)
    -- Added by FlightControl

    local _status, _error = net.dostring_in('server', " return trigger.action.setUserFlag(\"" .. _flag .. "\", " .. _number .. "); ")

    if not _status and _error then
        net.log("SSB - error setting flag: " .. _error)
        return false
    end
    return true
end


-- _slotID == Unit ID unless its multi aircraft in which case slotID is unitId_seatID
function ssb.getUnitId(_slotID)
    local _unitId = tostring(_slotID)
    if string.find(tostring(_unitId), "_", 1, true) then
        --extract substring
        _unitId = string.sub(_unitId, 1, string.find(_unitId, "_", 1, true))
        net.log("Unit ID Substr " .. _unitId)
    end

    return tonumber(_unitId)
end

function ssb.getGroupName(_slotID)

    local _name = DCS.getUnitProperty(_slotID, DCS.UNIT_GROUPNAME)

    return _name

end

--- Reset the persistent variables when a new mission is loaded.
ssb.onMissionLoadEnd = function()

    ssb.kickTimePrev = 0 -- Reset when a new mission has been loaded!

end

--- For each simulation frame, check if a player needs to be kicked.
ssb.onSimulationFrame = function()

    -- For each slot, check the flags...

    ssb.kickTimeNow = DCS.getModelTime()

    -- Check every 5 seconds if a player needs to be kicked.
    if ssb.kickPlayers and ssb.kickTimePrev + ssb.kickTimeInterval <= ssb.kickTimeNow then

        ssb.kickTimePrev = ssb.kickTimeNow

        if DCS.isServer() and DCS.isMultiplayer() then
            if DCS.getModelTime() > 1 and ssb.slotBlockEnabled() then
                -- must check this to prevent a possible CTD by using a_do_script before the game is ready to use a_do_script. -- Source GRIMES :)

                local Players = net.get_player_list()
                for PlayerIDIndex, playerID in pairs(Players) do

                    -- is player still in a valid slot
                    local _playerDetails = net.get_player_info(playerID)

                    if _playerDetails ~= nil and _playerDetails.side ~= 0 and _playerDetails.slot ~= "" and _playerDetails.slot ~= nil then

                        local _unitRole = DCS.getUnitType(_playerDetails.slot)
                        if _unitRole ~= nil and
                                (_unitRole == "forward_observer" or
                                        _unitRole == "instructor" or
                                        _unitRole == "artillery_commander" or
                                        _unitRole == "observer")
                        then
                            return true
                        end

                        local _allow = ssb.shouldAllowAircraftSlot(playerID, _playerDetails.slot)

                        if not _allow then
                            ssb.rejectPlayer(playerID)
                            if ssb.kickReset then
                                ssb.allowAircraftSlot(playerID, _playerDetails.slot)
                            end
                        end
                    end
                end
            end
        end
    end
end


---DOC
-- onGameEvent(eventName,arg1,arg2,arg3,arg4)
--"friendly_fire", playerID, weaponName, victimPlayerID
--"mission_end", winner, msg
--"kill", killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName
--"self_kill", playerID
ssb.onPlayerTryChangeSlot = function(playerID, side, slotID)

    if DCS.isServer() and DCS.isMultiplayer() then
        if (side ~= 0 and slotID ~= '' and slotID ~= nil) and ssb.slotBlockEnabled() then

            local _ucid = net.get_player_info(playerID, 'ucid')
            local _playerName = net.get_player_info(playerID, 'name')

            if _playerName == nil then
                _playerName = ""
            end

            net.log("SSB - Player Selected slot - player: " .. _playerName .. " side:" .. side .. " slot: " .. slotID .. " ucid: " .. _ucid)

            local _unitRole = DCS.getUnitType(slotID)

            if _unitRole ~= nil and
                    (_unitRole == "forward_observer"
                            or _unitRole == "instructor"
                            or _unitRole == "artillery_commander"
                            or _unitRole == "observer")
            then

                net.log("SSB - Player Selected Non Aircraft Slot - player: " .. _playerName .. " side:" .. side .. " slot: " .. slotID .. " ucid: " .. _ucid .. " type: " .. _unitRole)

                local _allow = false

                if ssb.controlNonAircraftSlots and ssb.slotBlockEnabled() then

                    for _, _value in pairs(ssb.commanderPlayerUCID) do

                        if _value == _ucid then
                            _allow = true
                            break
                        end
                    end

                    if not _allow then

                        ssb.rejectMessage(playerID)
                        net.log("SSB - REJECTING Player Selected Non Aircraft Slot - player: " .. _playerName .. " side:" .. side .. " slot: " .. slotID .. " ucid: " .. _ucid .. " type: " .. _unitRole)

                        return false
                    end
                end

                net.log("SSB - ALLOWING Player Selected Non Aircraft Slot - player: " .. _playerName .. " side:" .. side .. " slot: " .. slotID .. " ucid: " .. _ucid .. " type: " .. _unitRole)

                return
            else
                local _allow = ssb.shouldAllowAircraftSlot(playerID, slotID)

                if not _allow then
                    net.log("SSB - REJECTING Aircraft Slot - player: " .. _playerName .. " side:" .. side .. " slot: " .. slotID .. " ucid: " .. _ucid)

                    ssb.rejectMessage(playerID)

                    return false
                else
                    if ssb.showEnabledMessage then
                        --Disable chat message to user
                        local _chatMessage = string.format("*** %s - Slot Allowed! ***", _playerName)
                        net.send_chat_to(_chatMessage, playerID)
                    end
                end
            end

            net.log("SSB - ALLOWING Aircraft Slot - player: " .. _playerName .. " side:" .. side .. " slot: " .. slotID .. " ucid: " .. _ucid)

        end
    end

    return

end

ssb.slotBlockEnabled = function()

    local _res = ssb.getFlagValue("SSB") --SSB disabled by Default

    return _res == 100

end

ssb.rejectMessage = function(playerID)
    local _playerName = net.get_player_info(playerID, 'name')

    if _playerName ~= nil then
        --Disable chat message to user
        local _chatMessage = string.format("*** Sorry %s, this slot is only active if your side controls this base ***", _playerName)
        net.send_chat_to(_chatMessage, playerID)
    end

end

ssb.rejectPlayer = function(playerID)
    net.log("SSB - REJECTING Slot - force spectators - " .. playerID)

    -- put to spectators
    net.force_player_slot(playerID, 0, '')

    ssb.rejectMessage(playerID)

end

ssb.trimStr = function(_str)
    return string.format("%s", _str:match("^%s*(.-)%s*$"))
end

DCS.setUserCallbacks(ssb)

net.log("Loaded - SIMPLE SLOT BLOCK v" .. ssb.version .. " by Ciribob")
