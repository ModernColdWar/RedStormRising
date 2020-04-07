local lu = require("tests.luaunit")
require("tests.dcs_stub")
require("Moose")

local hitEventHandler = require("hitEventHandler")

-- stub out enough for an event's Weapon attribute
local function weaponWithDisplayName(displayName)
    return {
        getDesc = function()
            return { displayName = displayName }
        end
    }
end

TestHitEventHandler = {}

function TestHitEventHandler:tearDown()
    dcsStub.reset()
end

function TestHitEventHandler:testEmptyHitEvent()
    lu.assertIsNil(hitEventHandler.buildHitMessage({}))
end

function TestHitEventHandler:testAIHitOnPlayer()
    local event = {
        IniCoalition = 2,
        IniTypeName = "M-1 Abrams",
        TgtCoalition = 1,
        TgtPlayerName = "Winston",
        TgtTypeName = "UH-1H",
        Weapon = weaponWithDisplayName("120mm HE"),
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] blue M-1 Abrams hit Winston in red UH-1H with 120mm HE")
end

function TestHitEventHandler:testPlayerHitOnAI()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        Weapon = weaponWithDisplayName("AIM-120C"),
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] Bob in red F/A-18C hit blue ZSU-23 with AIM-120C")
end

function TestHitEventHandler:testPlayerHitOnAIWithNoIniCoalition()
    local event = {
        IniPlayerName = "Bob",
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        Weapon = weaponWithDisplayName("AIM-120C"),
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] Bob in F/A-18C hit blue ZSU-23 with AIM-120C")
end

function TestHitEventHandler:testPlayerHitOnAINoWeaponName()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23"
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] Bob in red F/A-18C hit blue ZSU-23")
end

function TestHitEventHandler:testPlayerOnPlayerHit()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        Weapon = weaponWithDisplayName("AIM-120C"),
        TgtPlayerName = "Alan",
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] Bob in red F/A-18C hit Alan in blue ZSU-23 with AIM-120C")
end

function TestHitEventHandler:testPlayerOnPlayerFriendlyHit()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 1,
        TgtTypeName = "ZSU-23",
        Weapon = weaponWithDisplayName("AIM-120C"),
        TgtPlayerName = "Alan",
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] FRIENDLY FIRE: Bob in red F/A-18C hit Alan in red ZSU-23 with AIM-120C")
end

function TestHitEventHandler:testAIOnAIHit()
    local event = {
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        WeaponName = "AIM-120C",
    }
    lu.assertIsNil(hitEventHandler.buildHitMessage(event))
end

function TestHitEventHandler:testSlungOnSlungHit()
    local event = {
        IniCoalition = 2,
        IniTypeName = "M-1 Abrams",
        IniGroupName = "CTLD_M-1 Abrams 33 (Steve)",
        TgtCoalition = 1,
        TgtTypeName = "ZSU-23",
        WeaponName = "BFG",
        TgtGroupName = "CTLD_M-1 Abrams 33 (Steve)",
    }
    lu.assertIsNil(hitEventHandler.buildHitMessage(event))
end

function TestHitEventHandler:testSlungUnitHitOnPlayer()
    local event = {
        IniCoalition = 2,
        IniTypeName = "M-1 Abrams",
        IniGroupName = "CTLD_M-1 Abrams 1234 (Winston)",
        TgtCoalition = 1,
        TgtPlayerName = "Alan",
        TgtTypeName = "UH-1H",
        Weapon = weaponWithDisplayName("120mm AP"),
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] Winston's blue M-1 Abrams hit Alan in red UH-1H with 120mm AP")
end

function TestHitEventHandler:testPlayerHitOnSlungUnit()
    local event = {
        IniPlayerName = "Bob",
        IniCoalition = 1,
        IniTypeName = "F/A-18C",
        TgtCoalition = 2,
        TgtTypeName = "ZSU-23",
        TgtGroupName = "CTLD_ZSU_23 1 (Winston)",
        Weapon = weaponWithDisplayName("AGM-65D"),
    }
    lu.assertEquals(hitEventHandler.buildHitMessage(event),
            "[ALL] Bob in red F/A-18C hit Winston's blue ZSU-23 with AGM-65D")
end

function TestHitEventHandler:testShouldSendMessageRemovesImmediatelyRepeatedMessages()
    local eventHandler = hitEventHandler.HIT_EVENTHANDLER:New(30)
    lu.assertIsTrue(eventHandler:shouldSendMessage("foo"))
    lu.assertIsFalse(eventHandler:shouldSendMessage("foo"))
    lu.assertIsTrue(eventHandler:shouldSendMessage("bar"))
    lu.assertIsFalse(eventHandler:shouldSendMessage("bar"))
end

function TestHitEventHandler:testShouldSendMessageAllowsSameMessageAfter5Seconds()
    local eventHandler = hitEventHandler.HIT_EVENTHANDLER:New(30)
    lu.assertIsTrue(eventHandler:shouldSendMessage("foo"))
    dcsStub.setTimeOffset(5.01)
    lu.assertIsTrue(eventHandler:shouldSendMessage("foo"))
end

function TestHitEventHandler:testShouldSendMessageRemovesAlternatingMessages()
    local eventHandler = hitEventHandler.HIT_EVENTHANDLER:New(30)
    lu.assertIsTrue(eventHandler:shouldSendMessage("Hit by AP"))
    lu.assertIsTrue(eventHandler:shouldSendMessage("Hit by HE"))
    lu.assertIsFalse(eventHandler:shouldSendMessage("Hit by AP"))
    lu.assertIsFalse(eventHandler:shouldSendMessage("Hit by HE"))
    lu.assertIsFalse(eventHandler:shouldSendMessage("Hit by AP"))
    lu.assertIsFalse(eventHandler:shouldSendMessage("Hit by HE"))
    dcsStub.setTimeOffset(5.01)
    lu.assertIsTrue(eventHandler:shouldSendMessage("Hit by AP"))
    lu.assertIsTrue(eventHandler:shouldSendMessage("Hit by HE"))
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
