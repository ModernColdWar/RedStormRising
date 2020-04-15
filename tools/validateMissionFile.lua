require("tests.dcs_stub")
local missionUtils = require("missionUtils")
local utils = require("utils")
local inspect = require("inspect")

local laserCodes = { red = 6, blue = 7 }
--[[
ropeLengths:
  default length in mission editor is 15m
  13/04/20 testing: rope length >15m for Mi8 or KA50 cause CTDs, severe lag/hang-ups, helo to backflip, rope to creation problems, etc.

]]
local clientOptions = {
    ["A_10A"] = { fuel = { capacity = 5029, fraction = 0.4 } },
    ["A_10C"] = { fuel = { capacity = 5029, fraction = 0.4 } },
    ["AJS37"] = { fuel = { capacity = 4476, fraction = 1.0 } },
    ["AV8BNA"] = { fuel = { capacity = 3519.423, fraction = 1.0 } },
    ["Bf_109K_4"] = { fuel = { capacity = 296, fraction = 1.0 } },
    ["C_101CC"] = { fuel = { capacity = 1580.46, fraction = 0.8 } },
    ["F_14B"] = {
        fuel = { capacity = 7348, fraction = 0.5 },
        AddPropAircraft = {
            INSAlignmentStored = true,
            LGB1 = laserCodes
        }
    },
    ["F_15C"] = { fuel = { capacity = 6103, fraction = 0.2 } },
    ["F_16C_50"] = { fuel = { capacity = 3249, fraction = 0.5 } },
    ["F_5E_3"] = {
        fuel = { capacity = 2046, fraction = 1.0 },
        Radio = {
            blue = { { channels = { 305, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269 } } }
        },
        AddPropAircraft = {
            LaserCode1 = laserCodes
        }

    },
    ["F_86F Sabre"] = { fuel = { capacity = 1282, fraction = 1.0 } },
    ["FA_18C_hornet"] = { fuel = { capacity = 4900, fraction = 0.5 } },
    ["FW_190A8"] = { fuel = { capacity = 409, fraction = 1.0 } },
    ["FW_190D9"] = { fuel = { capacity = 388, fraction = 1.0 } },
    ["TF_51D"] = { fuel = { capacity = 340.68, fraction = 1.0 } },
    ["P_51D"] = { fuel = { capacity = 732, fraction = 1.0 } },
    ["I_16"] = { fuel = { capacity = 191, fraction = 1.0 } },
    ["Christen Eagle II"] = { fuel = { capacity = 71, fraction = 1.0 } },
    ["J_11A"] = { fuel = { capacity = 9400, fraction = 0.5 } },
    ["JF_17"] = {
        fuel = { capacity = 2325, fraction = 0.5 },
        Radio = {
            red = { { channels = { 124, 151, 152, 153, 154, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114 } } }
        },
        AddPropAircraft = {
            AARProbe = false,
            LaserCode1 = laserCodes
        }
    },
    ["Ka_50"] = { fuel = { capacity = 1450, fraction = 0.5 }, ropeLength = 15 },
    ["L_39ZA"] = {
        fuel = { capacity = 823.2, fraction = 0.82 },
        Radio = {
            blue = { { channels = { 305, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269 } } }
        }
    },
    ["M_2000C"] = {
        fuel = { capacity = 3165, fraction = 0.5 },
        AddPropAircraft = {
            ForceINSRules = false,
            NoDDMSensor = true, -- yes, really this is with the DDM!
            LoadNVGCase = true,
            LaserCode1 = laserCodes,
        }
    },
    ["Mi_8MT"] = { fuel = { capacity = 1929, fraction = 0.4 }, ropeLength = 15 },
    ["MiG_15bis"] = { fuel = { capacity = 1172, fraction = 1.0 } },
    ["MiG_19P"] = { fuel = { capacity = 1800, fraction = 1.0 } },
    ["MiG_21Bis"] = {
        fuel = { capacity = 2280, fraction = 1.0 },
        Radio = {
            red = { { channels = { 126, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139 } } }
        }
    },
    ["MiG_29A"] = { fuel = { capacity = 3376, fraction = 0.5 } },
    ["MiG_29G"] = { fuel = { capacity = 3376, fraction = 0.5 } },
    ["MiG_29S"] = { fuel = { capacity = 3493, fraction = 0.5 } },
    ["P_51D_30_NA"] = { fuel = { capacity = 732, fraction = 1.0 } },
    ["SA342L"] = { fuel = { capacity = 416.33, fraction = 0.4 } },
    ["SA342M"] = { fuel = { capacity = 416.33, fraction = 0.4 } },
    ["SA342Mistral"] = { fuel = { capacity = 416.33, fraction = 0.4 } },
    ["SA342Minigun"] = { fuel = { capacity = 416.33, fraction = 0.4 } },
    ["SpitfireLFMkIX"] = { fuel = { capacity = 247, fraction = 1.0 } },
    --["Su-25"] = { fuel = { capacity = 2835, fraction = 0.7 }}, -- still produces error but removed all Su-25s from mission anyway
    ["Su_25T"] = { fuel = { capacity = 3790, fraction = 0.7 }, payload = { flare = 192, chaff = 64 } },
    ["Su_27"] = { fuel = { capacity = 5590.18, fraction = 0.5 } },
    ["Su_33"] = { fuel = { capacity = 9500, fraction = 0.5 } },
    ["UH_1H"] = { fuel = { capacity = 631, fraction = 0.3 }, ropeLength = 10 },
}

local missionDir = arg[1]
if missionDir == nil then
    print("No mission dir specified")
    os.exit(1)
end
local write = #arg >= 2 and arg[2] == "--write"

missionUtils.loadMission(missionDir)
-- luacheck: read_globals mission options

local function getOptionsKey(unit)
    return string.gsub(unit.type, "-", "_")
end

local function validateClientGroup(group)
    local errors = {}
    local groupName = missionUtils.getDictionaryValue(group.name)

    local unit = group.units[1]
    local unitName = missionUtils.getDictionaryValue(unit.name)
    if missionUtils.isTransportType(unit.type) and unitName ~= groupName then
        if #group.units ~= 1 then
            table.insert(errors, string.format("Transport group '%s' should only have 1 unit, but has %d", groupName, #group.units))
        end
        table.insert(errors, string.format("Transport group '%s' must contain unit with same name, but was '%s'", groupName, unitName))
    end
    for _, error in ipairs(errors) do
        print("ERROR: " .. error)
    end
    return #errors == 0
end

local function description(unit)
    return unit.type .. " '" .. missionUtils.getDictionaryValue(unit.name) .. "'"
end

local function setWeaponsUnlimited(baseName, warehouse)
    print("Setting warehouse weapons to unlimited for " .. baseName)
    warehouse.weapons = {}
    warehouse.unlimitedMunitions = true
end

local function setFuel(unit, fuel)
    if fuel == nil then
        print("ERROR: No fuel details available for " .. unit.type)
        return
    end
    local desiredFuel = fuel.capacity * fuel.fraction
    if unit.payload.fuel ~= desiredFuel then
        print(string.format("INFO:  Changing fuel for %s from %s to %s", description(unit), unit.payload.fuel, desiredFuel))
        unit.payload.fuel = desiredFuel
    end
end

local function setRopeLength(unit, desiredRopeLength)
    if desiredRopeLength == nil then
        return
    end
    if unit.ropeLength ~= desiredRopeLength then
        print(string.format("INFO:  Changing ropeLength for %s from %s to %s", description(unit), unit.ropeLength, desiredRopeLength))
        unit.ropeLength = desiredRopeLength
    end
end

local function setRadio(unit, sideName, radio)
    if unit.Radio == nil then
        print("TRACE: No radio present for " .. unit.type)
        -- FC3
        return
    end
    if radio == nil then
        print("TRACE: No radio options present for " .. unit.type)
        return
    end
    local radioSideSettings = radio[sideName]
    if radioSideSettings == nil then
        print("TRACE: No radio options present for " .. sideName .. " " .. unit.type)
        return
    end
    if inspect(unit.Radio) ~= inspect(radioSideSettings) then
        print("INFO:  Changing radio settings for " .. sideName .. " " .. description(unit))
        unit.Radio = radioSideSettings
    end
end

local function setPayload(unit, sideName, payload)
    if payload == nil then
        print("TRACE: No payload options for " .. unit.type)
        return
    end
    for key, newValue in pairs(payload) do
        local oldValue = unit.payload[key]
        if oldValue ~= newValue then
            print(string.format("INFO:  Changing payload %s for %s from %s to %s", key, description(unit), oldValue, newValue))
            unit.payload[key] = newValue
        end
    end
end

local function setProperties(unit, sideName, properties)
    if properties == nil then
        print("TRACE: No AddPropAircraft for " .. unit.type)
        return
    end
    for key, newValue in pairs(properties) do
        local oldValue = unit.AddPropAircraft[key]
        if oldValue == nil then
            print("WARN:  No existing value found for unit.AddPropAircraft." .. key .. " on " .. description(unit))
        end
        if key == "LGB1" or key == "LaserCode1" then
            newValue = newValue[sideName]
            if newValue == nil then
                print("ERROR: No side-specific value found for " .. sideName .. " " .. unit.type .. " " .. key)
                return
            end
        end
        if oldValue ~= newValue then
            print(string.format("INFO:  Changing property %s for %s from %s to %s", key, description(unit), tostring(oldValue), tostring(newValue)))
            unit.AddPropAircraft[key] = newValue
        end
    end
end

local function setClientUnitOptions(unit, sideName)
    local key = getOptionsKey(unit)
    local options = clientOptions[key]
    if options == nil then
        print("ERROR: No options available for " .. unit.type)
        return
    end
    setFuel(unit, options.fuel)
    setRopeLength(unit, options.ropeLength)
    setRadio(unit, sideName, options.Radio)
    setPayload(unit, sideName, options.payload)
    setProperties(unit, sideName, options.AddPropAircraft)
end

print("Checking bases for problems")
missionUtils.iterBases(mission, "Caucasus", function(baseName, warehouse, isAirbase)
    setWeaponsUnlimited(baseName, warehouse)
    if isAirbase and warehouse.coalition:lower() ~= "neutral" then
        print("ERROR: Base is not neutral " .. baseName .. " (is " .. warehouse.coalition .. ")")
        return
    end

    local foundPickupZone = false
    missionUtils.iterZones(mission, function(zone)
        local zoneName = zone.name

        local pickupZoneBaseName = utils.getBaseNameFromZoneName(zoneName, "pickup")
        if pickupZoneBaseName ~= nil and utils.matchesBaseName(baseName, pickupZoneBaseName) then
            foundPickupZone = true
        end
    end)

    if not foundPickupZone then
        print("ERROR: No pickup zone found for " .. baseName)
    end
end)

print("\nSetting options for client aircraft")
missionUtils.iterGroups(mission, function(group, sideName)
    if missionUtils.isClientGroup(group) then
        validateClientGroup(group)
        for _, unit in pairs(group.units) do
            setClientUnitOptions(unit, sideName)
        end
    end
end)

print("\nSetting ground units to game master only")
missionUtils.iterVehicleGroups(mission, function(group, sideName)
    local groupName = missionUtils.getDictionaryValue(group.name)
    if not group.uncontrollable then
        print("Setting " .. groupName .. " to game master only")
        group.uncontrollable = true
    end
end)

print("\Setting mission options")
options.miscellaneous.f5_nearest_ac = false
options.miscellaneous.f11_free_camera = false
options.difficulty.spectatorExternalViews = false
options.difficulty.externalViews = false
options.plugins.CA.ground_aim_helper = false

if write then
    missionUtils.serializeMission(missionDir)
end

print("Done")
