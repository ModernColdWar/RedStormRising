local lu = require("tests.luaunit")
require("tests.dcs_stub")
require("MOOSE")

local loggingEventHandler = require("loggingEventHandler")

TestLoggingEventHandler = {}

function TestLoggingEventHandler:testEmptyHitEvent()
    lu.assertIsNil(loggingEventHandler.buildHitMessage({}))
end

function TestLoggingEventHandler:testAIHitOnPlayer()
    local event = {
        IniCoalition = 2,
        IniTypeName = "M-1 Abrams",
        TgtCoalition = 1,
        TgtPlayerName = "Winston",
        TgtTypeName = "UH-1H",
        WeaponName = "weapons.shells.M2_12_7_T",
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "Blue M-1 Abrams hit Winston in red UH-1H with weapons.shells.M2_12_7_T")
end

function TestLoggingEventHandler:testPlayerHitOnAI()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        WeaponName = "AIM-120C",
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "Bob in red F/A-18C hit blue ZSU-23 with AIM-120C")
end

function TestLoggingEventHandler:testPlayerHitOnAIWithNoIniCoalition()
    local event = {
        IniPlayerName = "Bob",
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        WeaponName = "AIM-120C",
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "Bob in F/A-18C hit blue ZSU-23 with AIM-120C")
end

function TestLoggingEventHandler:testPlayerHitOnAINoWeaponName()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23"
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "Bob in red F/A-18C hit blue ZSU-23")
end

function TestLoggingEventHandler:testPlayerOnPlayerHit()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        WeaponName = "AIM-120C",
        TgtPlayerName = "Alan",
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "Bob in red F/A-18C hit Alan in blue ZSU-23 with AIM-120C")
end

function TestLoggingEventHandler:testPlayerOnPlayerFriendlyHit()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 1,
        TgtTypeName = "ZSU-23",
        WeaponName = "AIM-120C",
        TgtPlayerName = "Alan",
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "FRIENDLY FIRE: Bob in red F/A-18C hit Alan in red ZSU-23 with AIM-120C")
end

function TestLoggingEventHandler:testAIOnAIHit()
    local event = {
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        WeaponName = "AIM-120C",
    }
    lu.assertIsNil(loggingEventHandler.buildHitMessage(event))
end

function TestLoggingEventHandler:testSlungOnSlungHit()
    local event = {
        IniCoalition = 2,
        IniTypeName = "M-1 Abrams",
        IniGroupName = "CTLD_M-1 Abrams 33 (Steve)",
        TgtCoalition = 1,
        TgtTypeName = "ZSU-23",
        WeaponName = "BFG",
        TgtGroupName = "CTLD_M-1 Abrams 33 (Steve)",
    }
    lu.assertIsNil(loggingEventHandler.buildHitMessage(event))
end

function TestLoggingEventHandler:testSlungUnitHitOnPlayer()
    local event = {
        IniCoalition = 2,
        IniTypeName = "M-1 Abrams",
        IniGroupName = "CTLD_M-1 Abrams 1234 (Winston)",
        TgtCoalition = 1,
        TgtPlayerName = "Alan",
        TgtTypeName = "UH-1H",
        WeaponName = "weapons.shells.M2_12_7_T",
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "Winston's blue M-1 Abrams hit Alan in red UH-1H with weapons.shells.M2_12_7_T")
end

function TestLoggingEventHandler:testPlayerHitOnSlungUnit()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        TgtGroupName = "CTLD_ZSU_23 1 (Winston)",
        WeaponName = "AGM-65D",
    }
    lu.assertEquals(loggingEventHandler.buildHitMessage(event),
            "Bob in red F/A-18C hit Winston's blue ZSU-23 with AGM-65D")
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
