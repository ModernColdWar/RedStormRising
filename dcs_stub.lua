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
    }
}

world = {
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
    addStaticObject = function()
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
