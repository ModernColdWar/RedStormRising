--- Stubs DCS World for testing of scripts outside of the DCS runtime mission environment

env = {
    mission = {
        coalition = {
            red = {
                bullseye = { x = 1, y = 2 },
            },
            blue = {
                bullseye = { x = 3, y = 4 },
            }
        }
    },
    info = function(str)
        print("INFO: " .. str)
    end,
    error = function(str)
        print("ERROR: " .. str)
    end,
}

timer = {
    getTime = function()
        return os.clock()
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
        outText = function(text, displayTime)
            _log():info("trigger.action.outText($1, $2)", displayTime, text)
        end
    }
}

world = {
    event = {
        S_EVENT_MARK_REMOVED = 99, -- this is a placeholder number
    },
    addEventHandler = function()
    end
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
    addStaticObject = function(countryId, groupData)
        _log():info("coalition.addStaticObject($1, $2)", countryId, groupData)
    end
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

Group = {
    getByName = function()
    end
}

StaticObject = {
    getByName = function()
    end
}

__logger = nil

--- Lazily creates a MIST logger
--- This is done lazily because we stub DCS before we load MIST
function _log()
    if __logger == nil then
        __logger = mist.Logger:new("DCS_STUB", "info")
    end
    return __logger
end