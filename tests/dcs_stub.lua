--- Stubs DCS World for testing of scripts outside of the DCS runtime mission environment
-- luacheck: ignore dcsStub AI Airbase Group StaticObject Unit coalition country env radio timer trigger world
local lu = require("tests.luaunit")
local inspect = require("inspect")

dcsStub = {}
dcsStub.timeOffset = 0

local _logger = nil

--- Lazily creates a MIST logger
--- This is done lazily because we stub DCS before we load MIST
local function log()
    if _logger == nil then
        require("mist_4_3_74")
        _logger = mist.Logger:new("DCS_STUB", "info")
    end
    return _logger
end

dcsStub.recordedCalls = {}

--- Logs the call name and arguments
local function logCall(callName)
    local text = callName .. "("
    local n = 0
    for k, v in pairs(arg) do
        if k ~= "n" then
            if n > 0 then
                text = text .. ", "
            end
            if type(v) ~= "string" then
                if type(v) == "table" then
                    text = text .. inspect(v)
                else
                    text = text .. tostring(v)
                end
            else
                text = text .. v
            end
            n = n + 1
        end
    end
    text = text .. ")"
    log():info(text)
end

local function recordCall(callName)
    return function()
        logCall(callName)
        table.insert(dcsStub.recordedCalls, callName)
    end
end

env = {
    mission = {
        coalition = {
            red = {
                bullseye = { x = 1, y = 2 },
            },
            blue = {
                bullseye = { x = 3, y = 4 },
            }
        },
        triggers = {
            zones = {},
        }
    },
    info = function(str)
        print("INFO: " .. str)
    end,
    warning = function(str)
        print("WARNING: " .. str)
    end,
    error = function(str)
        print("ERROR: " .. str)
    end,
    setErrorMessageBoxEnabled = function()
    end,
}

timer = {
    getTime = function()
        return os.clock() + dcsStub.timeOffset
    end,
    scheduleFunction = function()
    end
}

trigger = {
    smokeColor = {
        Green = 0,
        Red = 1,
        White = 2,
        Orange = 3,
        Blue = 4
    },
    flareColor = {
        Green = 0,
        Red = 1,
        White = 2,
        Yellow = 3
    },
    action = {
        outText = recordCall("trigger.action.outText"),
        setUserFlag = recordCall("trigger.action.setUserFlag")
    }
}

world = {
    -- all these numbers are placeholders
    event = {
        S_EVENT_INVALID = 0,
        S_EVENT_SHOT = 1,
        S_EVENT_HIT = 2,
        S_EVENT_TAKEOFF = 3,
        S_EVENT_LAND = 4,
        S_EVENT_CRASH = 5,
        S_EVENT_EJECTION = 6,
        S_EVENT_REFUELING = 7,
        S_EVENT_DEAD = 8,
        S_EVENT_PILOT_DEAD = 9,
        S_EVENT_BASE_CAPTURED = 10,
        S_EVENT_MISSION_START = 11,
        S_EVENT_MISSION_END = 12,
        S_EVENT_TOOK_CONTROL = 13,
        S_EVENT_REFUELING_STOP = 14,
        S_EVENT_BIRTH = 15,
        S_EVENT_HUMAN_FAILURE = 16,
        S_EVENT_ENGINE_STARTUP = 17,
        S_EVENT_ENGINE_SHUTDOWN = 18,
        S_EVENT_PLAYER_ENTER_UNIT = 19,
        S_EVENT_PLAYER_LEAVE_UNIT = 20,
        S_EVENT_PLAYER_COMMENT = 21,
        S_EVENT_SHOOTING_START = 22,
        S_EVENT_SHOOTING_END = 23,
        S_EVENT_MARK_ADDED = 24,
        S_EVENT_MARK_CHANGE = 25,
        S_EVENT_MARK_REMOVED = 26,
        S_EVENT_MAX = 99,
    },
    addEventHandler = function()
    end,
    getAirbases = function()
        return {}
    end,
}

coalition = {
    side = {
        NEUTRAL = 0,
        RED = 1,
        BLUE = 2,
    },
    service = {
        ATC = 0,
        AWACS = 1,
        TANKER = 2,
        FAC = 3,
    },
    addGroup = recordCall("coalition.addGroup"),
    addStaticObject = recordCall("coalition.addStaticObject"),
    getGroups = function()
    end,
    getStaticObjects = function()
    end,
    getAirbases = function()
    end,

}

country = {
    id = {
        ['RUSSIA'] = 0,
        ['UKRAINE'] = 1,
        ['USA'] = 2,
    },
    name = {
        [0] = 'RUSSIA',
        [1] = 'UKRAINE',
        [2] = 'USA',
    },
    names = {
        [0] = 'RUSSIA',
        [1] = 'UKRAINE',
        [2] = 'USA',
    },
}

radio = { modulation = { "AM", "FM" } }

Group = {
    Category = {
        AIRPLANE = 0,
        HELICOPTER = 1,
        GROUND = 2,
        SHIP = 3,
        TRAIN = 4
    }
}

function Group:new(name)
    local g = {}
    g.name = name
    g.coalition = coalition.side.RED
    setmetatable(g, self)
    self.__index = self
    return g
end

function Group:getName()
    return self.name
end

function Group:getCoalition()
    return self.coalition
end

function Group:getUnit()
    return Unit.getByName(self.name)
end

function Group:getUnits()
    return { Unit.getByName(self.name) }
end

StaticObject = {
    getByName = function()
    end
}

function Group.getByName(name)
    return Group:new(name)
end

Unit = {
    Category = {
        AIRPLANE = 0,
        HELICOPTER = 1,
        GROUND_UNIT = 2,
        SHIP = 3,
        STRUCTURE = 4
    }
}

function Unit:new(name)
    if name == "deadUnit" then
        return nil
    end
    local u = {}
    u.name = name
    u.active = true
    u.life = 100
    u.coalition = coalition.side.RED
    u.country = country.id.USA
    u.typeName = "Avenger"
    u.point = { x = 0, y = 0, z = 0 }
    u.position = { p = { x = 1, y = 3, z = 2 }, x = u.point, y = u.point, z = u.point }
    u.id = 1001
    self.in_air = false
    setmetatable(u, self)
    self.__index = self
    return u
end

function Unit:getName()
    return self.name
end

function Unit:isActive()
    return self.active
end

function Unit:getLife()
    return self.life
end

function Unit:inAir()
    return self.in_air
end

function Unit:getCoalition()
    return self.coalition
end

function Unit:getCountry()
    return self.country
end

function Unit:getTypeName()
    return self.typeName
end

function Unit:getPoint()
    return self.point
end

function Unit:getPosition()
    return self.position
end

function Unit:getID()
    return self.id
end

function Unit.getByName(name)
    return Unit:new(name)
end

Airbase = {
    Category = {
        AIRDROME = 1,
        HELIPAD = 2,
        SHIP = 3
    }
}

AI = {
    Option = {
        Air = {
            val = {
                ROE = {
                    OPEN_FIRE = 1
                },
                REACTION_ON_THREAT = {
                    ALLOW_ABORT_MISSION = 1,
                }
            }
        }
    }
}

function dcsStub.reset()
    dcsStub.recordedCalls = {}
    dcsStub.timeOffset = 0
end

function dcsStub.assertNoCalls()
    lu.assertEquals(#dcsStub.recordedCalls, 0)
end

function dcsStub.assertOneCallTo(callName)
    local callCount = 0
    for _, recordedCall in ipairs(dcsStub.recordedCalls) do
        if recordedCall == callName then
            callCount = callCount + 1
        end
    end
    lu.assertEquals(callCount, 1, inspect(dcsStub.recordedCalls))
end

function dcsStub.setTimeOffset(timeOffset)
    dcsStub.timeOffset = timeOffset
end

lfs = {}

function lfs.writedir()
    return ''
end
