-- RedStormRising slot blocker
-- Based on the excellent work by the authors of Simple Slot Block (thank you Ciribob et al!)

-- Events related to connection and chat are handled by RSRPlayerLogger

local M = {}

-- RSR developers and admins
M.gameMasterUcids = {
    "46f14d9df21bcca261da5d54ff77b6a8", -- Winston
    "117bc9e9faafa19d71f099d650cf1b0c", -- deebix
    "cbb43fc99e978ee535b86653d14e5dbc", -- Mobius
    "99bc992d15a8b9366c1af3873f53a895", -- Capt.Fdez
    "231aa8ac940aa8a712c1f17c2a3f0122", -- Flashheart
    "6e14d6e4deb4bf3b08d99713754cd1dc", -- n0xy Steam
    "87dd983a6c5b678de30c9adb55b18cf4", -- n0xy Standalone
    "263d36e3b60782a6c16e2b3c5cebf3f9", -- mad rabbit
	"53c1017106f484956c9e56d8c4b85acb", -- GENA pilot (for video creation April 2020); remove eventually
}

M.tacCmdrUcids = {
    "9afc4637083feaf599e78b25b37adf25",
    "053ec863e71f9b83f1dc3155a3563ee6",
    "f47be7b9564d03e6d8a75313efeba92a",
    "64cb0b85fffe51c3e79ecd8f13766ded", -- Wildcat
    "0f8240487915af76a6f44a41c01cde47",
    "182fb65bdbbdf9566d7cefeaab8c3c25",
    "7d5c7a1b8bf4e5bee87cf9fd20d3a90c", -- Lord Felix
    "e2b6cc3261d5513faaaffe8a7c157a32",
    "a0d2bd3f8eea70563d49cae543f4ed8f",
    "ebb1471000e15b3ca240910d82342503",
    "e711c21cecbfb91534afa41275027291", -- Hbomb
    "57c75549549a256464978b7a7deba4c8",
    "9d70024558a2a3949c2ae9b8b9f79669",
    "e5d0f5316232e5802ced7cc4c86d2c95",
    "5d619981c0a192bda60c927bd6fbccf9",
    "24b0e1cfc1b27e375d38a98a43db9779",
    "d7f6161e6401a1c9c1f31ba7315e647c",
    "60eaa32a48cdf3b1162739acf7cfec28", --DakiBajoMoj
    "6e1c8117ab788fa693feec6326320a5e",
    "842514dc165092ba9631f8c7d2052d0a",
    "837f1acd1132ed0a60f2a6a1f57bcc1c", -- Smitty
    "b12d9af45f2b08a353f1e706e034eaec",
    "0a312f0e5531d0fb0e1b1d90bb559fa3",
    "e011e49e75560dbe802d50cd0f1ce68d",
    "80981e82a3f8b8178c232ddc96d7fe40",
    "3beb7082568d91bdeb29282d840c4e76",
    "3b1623a591687015f620aaba1598b3ca",
    "6151a2842ea86fd5bf7274fdf0cce579",
    "67d27f9376433f555b1ae71c2872c584",
    "f3120f75fa5d66e5a1adaeea4f303c3d", -- Drif
    "a9a6ba83cc166d960fcf7ef3d8a20eb9",
    "c0fda776e215e597c37c92fb9dde70fb",
    "9d76164a91c872953a4f1ab378f0e008",
    "a78d9cc5ad679f472dc36f66c71d99db", -- Canuck
    "dc91af6f5f48dd94c89ace508c17cc69",
    "eae6f83ee3693287e92229d7eeab25b3",
    "5df2d8f9d4675adf07a1d0f7eed7f9e0",
    "b0d7c14dd6fe1ac1ef203643512f4387", -- Two Lives
    "22f8d3edba38b8052c3b82242262a867", -- Shatten55
    "630959d9628dce969646b5ce279a5996", -- crazzymrbc
    "18228f3b7ecb8b5af9cb7965870d3f1b", -- EARL 4-2 | H4nS0L0
    "822f0042190141165d100ccffe8d2cbf", -- EARL 1-4 | alxz
    "fff7b6fabadc7339a246fa5330ceb3b2", -- SaabFAN
    "a1f7bf58006730415c9cdda22b2f89b2", -- EARL 6-4 | CYPHER
    "5d194005968acd3db845fdae1f1575e9", -- Checklist
    "07aa971b0e583a05c69dc06075bedabf", -- HansPeter
    "703a4d348871ec2fe9cac9cd2168f609", -- NightStalker
    "5cb74e04677581b97c65d7ac67872b99", -- Woodstock
    "e1277ddbc6cc620bfbc9ceb0f57dc19c", -- Airplaneman321
    "2e9713fc055304fe1bd6c6c778c0f620", -- LeoNerd
    "91ec71924c23f4f15d785f5d7105e6b3", -- Salad
    "9b1a9d6714bfc414eb0c2e5158f75c89", -- -=*26th*=- | Pakster
    "4f306d55e7ca9d3c683ebd983ad6c859", -- Firefly
    "afce946e4b300ebc03bbbfdee7b07f31", -- <64>Kazansky
    "10fb130391f045766bb836e7c9f66c2c", -- Viper 77|Gandalf
    "964158664f15dd3d7fbb0ea80c6b296f", -- The State|LTJG SNOT
    "20dd4b54a9fc51df4d38cd8955103361", -- Disco
    "4c38b2e3c3647473512e5400017df50e", -- 8==D Ritt
    "92fd1d66e41dfa65c7dd73b4f309db87", -- 8==D Texas
    "2afada4c6dcd47147a1140cea34bc43a", -- 8==D Redback
    "d64300a70517b5878f2aae5cc4e96968", -- 8==D Shively
    "a73cc77ec3926ac636a4fd419f1c0fb5", -- 8==D Jarhead
    "c7dade15a8a58dca9d91e12402b77e65", -- 8==D Jarhead
    "b7477d13cfac623b3ca55e1e2dd0df1f", -- 8==D Guns
    "e64dcbab81dcdb157439018fc6e76488", -- 8==D Zooker
    "f10c00accc6b3f694490dbb307988e1d", -- ROGUE | Archangel
    "6cb230729c620cd22eea9a1900279dcb", -- GasMachine
    "a72632f9d4aef4bc3fc12fb0a6bcdc87", -- =R|D= johnnytrump
    "d125549aa96ca9c8c021e7bfb1028d7c", -- Tester
    "d26bb6e1f0b5268626d41a0feef17727", -- Shabi
    "b67841fbaf484d62fd93c159f00a5a78", -- ALA15-Snake
    "19db9ec1f7b12df8c89360e17a31d7ef", -- VS33 Stroke
    "53ecb670a7fa0147ccf6ab8af0eb7f9d", -- wolfy
    "0905260d71275b3f8051e42d73b96a19", -- {WD} bert, added by Capt.Fdez
    "7e8563b5c0ae6d9657de5758395c2406", -- ZZ added by deebix
    "8f3e2a5beadbd739a973027607f4a5cc", -- Rigez added by mad rabbit
    "7c6028ee85d15cb5008a07403f486522", -- outcast 1-1 by deebix
    "37922d84eaf6bb71e775a54af9b1c75d", -- Drip added by deebix
    "88e28730b17a4cacae63e61fafbded1e", -- Airogue added by mad rabbit
    "a83dd704a242de5450deec9887e7c9d3", -- Sephryn added by mad rabbit
    "079236f5f48b0350bdaf364d042dccfe", -- rocket_knight added by deebix
    "c70c2a7bb2d855e80bcf4964ee1daaeb", -- moupe added by deebix
    "9de0e2e317a56c09aecff8eeeecdd47a", -- =AW=33COM added by mad rabbit
	"7695c98ec481ce38dc1728d469dbd5ba"  -- Kestrel added by mad rabbit
	"062792cea85dc2159a74a82e0ceeeff3"  -- REAPER 54 | Sturdyguns added by mad rabbit
    -----------------------------------
    -- Russian Players
    "53c1017106f484956c9e56d8c4b85acb", -- GenaPilot
    "09bc71361a591195159e2b84dfc67482", -- ROSS_Pups added by deebix
    "20ef9ad2392e236cf72cd3f3a853da42", -- ROSS_BoomSbk added by mad rabbit
    "3dd6e3bcd9f99a8826e8f9791dc15199", -- Sakhalin66
    "90d0af5d35b62cc5012de966b5bd1dcf", -- Harkonnen
    -----------------------------------
    -- Russian Players
    "00e5296e187ccfb8ee5edb55a7968d39", -- ★ВАРЯГ★
    "b148135d459915551e3d2b5489821c16", -- Santa
    "e5f8848b3ef84a88c635e5bc2a8e2a41", -- Djim
    "25bd8aec82ad88e26c5534abddb3cc22", -- HanSolo
    "aea4fb0972eb001320d390b7a955356b", -- НовоБранец
    "a1aef3ef90d4e611eb8bd40a21ab26cd", -- Coldays
    "1d62619fb7ccd513e9f7cd639ad595bb", -- Lam, added by Mobius
    "4052f4b970efd04829623d087898a66f", -- =KAG=Zakha
    "1d086e78fb0870ad682ff5ee90aa94fd", -- -=WildCat=-
    "e61489151c2de788e78e8c92b97a2cca", -- ROSS berrymore by deebix
    "7fa9836632054f227b042f6a185b957c", -- ROSS grishik by deebix
    -----------------------------------

}

-- These values must match what's in RSR\slotBlocker.lua
M.slotEnabled = 1
M.slotDisabled = 99 -- flags default to 0 if not set, so don't use 0 for disabled!

local function log(message)
    net.log("RSRSlotBlocker: " .. message)
end

local function getFlagValue(groupName)
    local status, error = net.dostring_in('server', " return trigger.misc.getUserFlag(\"" .. groupName .. "\"); ")

    if not status and error then
        log("Error getting flag '" .. groupName .. "': " .. error)
        return M.slotEnabled
    else
        return tonumber(status)
    end
end

local function isUcidAllowed(playerUcid, allowedUcids)
    for _, allowedUcid in pairs(allowedUcids) do
        if allowedUcid == playerUcid then
            return true
        end
    end
    return false
end

local function isGameMasterSlot(unitRole)
    return unitRole == "instructor"
end

local function isTacCmdrSlot(unitRole)
    return unitRole == "artillery_commander" or unitRole == "forward_observer" or unitRole == "observer"
end

local function isNonAircraftSlot(unitRole)
    return unitRole ~= nil and isGameMasterSlot(unitRole) or isTacCmdrSlot(unitRole)
end

local function logNonAircraftSlot(playerId, playerName, playerUcid, unitRole, allowed)
    if allowed then
        log("Allowing " .. playerName .. " into " .. unitRole .. " slot (UCID " .. playerUcid .. ")")
    else
        log("Rejecting " .. playerName .. " from " .. unitRole .. " slot (UCID " .. playerUcid .. ")")
        net.send_chat_to("*** Sorry, you are not allowed into the " .. unitRole .. " slots.  If you want access to these slots, please contact us on Discord (linked in the briefing) ***", playerId)
    end
end

-- DCS documentation says returning nothing is success, otherwise a failure
function M.onPlayerTryChangeSlot(playerId, side, slotId)
    if not DCS.isServer() or not DCS.isMultiplayer() or side == 0 or slotId == '' or slotId == nil then
        return
    end

    local playerName = net.get_player_info(playerId, 'name')
    local playerUcid = net.get_player_info(playerId, 'ucid')

    if playerName == nil then
        playerName = ""
    end

    local unitRole = DCS.getUnitType(slotId)

    if isNonAircraftSlot(unitRole) then
        if isGameMasterSlot(unitRole) then
            local allowedIntoGameMaster = isUcidAllowed(playerUcid, M.gameMasterUcids)
            logNonAircraftSlot(playerId, playerName, playerUcid, unitRole, allowedIntoGameMaster)
            return allowedIntoGameMaster
        else
            local allowedIntoTacCmdr = isUcidAllowed(playerUcid, M.gameMasterUcids) or isUcidAllowed(playerUcid, M.tacCmdrUcids)
            logNonAircraftSlot(playerId, playerName, playerUcid, unitRole, allowedIntoTacCmdr)
            return allowedIntoTacCmdr
        end
    end

    -- aircraft slots; check flag values based on group name
    local groupName = DCS.getUnitProperty(slotId, DCS.UNIT_GROUPNAME)

    if groupName == nil or groupName == "" then
        log("Unable to get group name for slot " .. slotId .. "; allowing access")
        return true
    end

    local flagValue = getFlagValue(groupName)
    net.log(string.format("Flag value for group '%s' is %d", groupName, flagValue))
    -- only reject a slot if the disabled value is set (ie fail-safe and allow the slot)
    local slotAllowed = flagValue ~= M.slotDisabled

    if slotAllowed then
        log("Allowing player " .. playerName .. " on side " .. side .. " into slot '" .. groupName .. "'")
        return true
    else
        net.send_chat_to("*** Sorry, this slot is only active if your side controls this base ***", playerId)
        log("Rejecting player " .. playerName .. " on side " .. side .. " from slot '" .. groupName .. "'")
        return false
    end
end

DCS.setUserCallbacks(M)

net.log("Loaded RSRSlotBlocker")
