require("tests.dcs_stub")
local missionUtils = require("missionUtils")
local utils = require("utils")
local inspect = require("inspect")

local fuelSettings = {
    A_10A = { capacity = 5029, fraction = 0.4 },
    A_10C = { capacity = 5029, fraction = 0.4 },
    AJS37 = { capacity = 4476, fraction = 1.0 },
    AV8BNA = { capacity = 3519.423, fraction = 1.0 },
    Bf_109K_4 = { capacity = 296, fraction = 1.0 },
    C_101CC = { capacity = 1580.46, fraction = 0.8 },
    F_14B = { capacity = 7348, fraction = 0.5 },
    F_15C = { capacity = 6103, fraction = 0.2 },
    F_16C_50 = { capacity = 3249, fraction = 0.5 },
    F_5E_3 = { capacity = 2046, fraction = 1.0 },
    ["F_86F Sabre"] = { capacity = 1282, fraction = 1.0 },
    FA_18C_hornet = { capacity = 4900, fraction = 0.5 },
    FW_190A8 = { capacity = 409, fraction = 1.0 },
    FW_190D9 = { capacity = 388, fraction = 1.0 },
    TF_51D = { capacity = 340.68, fraction = 1.0 },
    P_51D = { capacity = 732, fraction = 1.0 },
    I_16 = { capacity = 191, fraction = 1.0 },
    ["Christen Eagle II"] = { capacity = 71, fraction = 1.0 },
    J_11A = { capacity = 9400, fraction = 0.5 },
    JF_17 = { capacity = 2325, fraction = 0.5 },
    Ka_50 = { capacity = 1450, fraction = 0.5 },
    L_39ZA = { capacity = 823.2, fraction = 0.82 },
    M_2000C = { capacity = 3165, fraction = 0.5 },
    Mi_8MT = { capacity = 1929, fraction = 0.4 },
    MiG_15bis = { capacity = 1172, fraction = 1.0 },
    MiG_19P = { capacity = 1800, fraction = 1.0 },
    MiG_21Bis = { capacity = 2280, fraction = 1.0 },
    MiG_29A = { capacity = 3376, fraction = 0.5 },
    MiG_29G = { capacity = 3376, fraction = 0.5 },
    MiG_29S = { capacity = 3493, fraction = 0.5 },
    P_51D_30_NA = { capacity = 732, fraction = 1.0 },
    SA342L = { capacity = 416.33, fraction = 0.4 },
    SA342M = { capacity = 416.33, fraction = 0.4 },
    SA342Mistral = { capacity = 416.33, fraction = 0.4 },
	SA342Minigun = { capacity = 416.33, fraction = 0.4 },
    SpitfireLFMkIX = { capacity = 247, fraction = 1.0 },
    --["Su-25"] = { capacity = 2835, fraction = 0.7 }, -- still produces error but removed all Su-25s from mission anyway
    Su_25T = { capacity = 3790, fraction = 0.7 },
    Su_27 = { capacity = 5590.18, fraction = 0.5 },
    Su_33 = { capacity = 9500, fraction = 0.5 },
    UH_1H = { capacity = 631, fraction = 0.3 },
}

local countermeasuresSettings = {
    Su_25T = { flare = 192, chaff = 64 },
}


-- default length in mission editor is 15m
-- 13/04/20 testing: rope length >15m for Mi8 or KA50 cause CTDs, severe lag/hang-ups, helo to backflip, rope to creation problems, etc.
local ropeLengths = {
    Ka_50 = 15,
    Mi_8MT = 15,
    UH_1H = 10,
}

local radioSettings = {
    red = {
        MiG_21Bis = { { channels = { 126, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139 } } },
        JF_17 = { { channels = { 124, 151, 152, 153, 154, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114 } } },
    },
    blue = {
        L_39ZA = { { channels = { 305, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269 } } },
        F_5E_3 = { { channels = { 305, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269 } } }
    },
}

local missionDir = arg[1]
if missionDir == nil then
    print("No mission dir specified")
    os.exit(1)
end
local write = #arg >= 2 and arg[2] == "--write"

missionUtils.loadMission(missionDir)
-- luacheck: read_globals mission options

local function getSettingsKey(unit)
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

local function setFuel(unit)
    local key = getSettingsKey(unit)
    local fuelDetails = fuelSettings[key]
    if fuelDetails == nil then
        error("No fuel details available for " .. unit.type)
    end
    local desiredFuel = fuelDetails.capacity * fuelDetails.fraction
    local fuelError = math.abs(unit.payload.fuel - desiredFuel) / desiredFuel
    if fuelError > 0.01 then
        print("INFO:  Changing fuel for " .. description(unit) .. " from " .. unit.payload.fuel .. " to " .. desiredFuel)
        unit.payload.fuel = desiredFuel
    end
end

local function setCountermeasures(unit)
    local key = getSettingsKey(unit)
    local countermeasures = countermeasuresSettings[key]
    if countermeasures == nil then
        return
    end
    if unit.payload.flare ~= countermeasures.flare then
        print("INFO:  Changing flare count for " .. description(unit) .. " from " .. unit.payload.flare .. " to " .. countermeasures.flare)
        unit.payload.flare = countermeasures.flare
    end
    if unit.payload.chaff ~= countermeasures.chaff then
        print("INFO:  Changing chaff count for " .. description(unit) .. " from " .. unit.payload.chaff .. " to " .. countermeasures.chaff)
        unit.payload.chaff = countermeasures.chaff
    end
end

local function setRadio(unit, sideName)
    if unit.Radio == nil then
        -- FC3
        return
    end
    local desiredSettings = radioSettings[sideName][getSettingsKey(unit)]
    if desiredSettings == nil then
        return
    end
    if inspect(unit.Radio) ~= inspect(desiredSettings) then
        print("INFO:  Changing radio settings for " .. sideName .. " " .. description(unit))
        unit.Radio = desiredSettings
    end
end

local function setRopeLength(unit)
    local desiredRopeLength = ropeLengths[getSettingsKey(unit)]
    if desiredRopeLength == nil then
        return
    end
    if unit.ropeLength ~= desiredRopeLength then
        print("INFO:  Changing rope length for " .. description(unit) .. " from " .. unit.ropeLength .. " to " .. desiredRopeLength)
        unit.ropeLength = desiredRopeLength
    end
end

local function setF14Options(unit, sideName)
    if not unit.AddPropAircraft.INSAlignmentStored then
        print("INFO:  Setting options for " .. description(unit))
        unit.AddPropAircraft.INSAlignmentStored = true
    end
    if sideName == "red" then
        unit.AddPropAircraft.LGB1 = 6
    else
        unit.AddPropAircraft.LGB1 = 7
    end
end

local function setM2000Options(unit, sideName)
    print("INFO:  Setting options for " .. description(unit))
    unit.AddPropAircraft.ForceINSRules = false
    unit.AddPropAircraft.NoDDMSensor = true  -- yes, really this is with the DDM!
    unit.AddPropAircraft.LoadNVGCase = true
    if sideName == "red" then
        unit.AddPropAircraft.LaserCode1 = 6
    else
        unit.AddPropAircraft.LaserCode1 = 7
    end
end

local function setJF17Options(unit, sideName)
    print("INFO:  Setting options for " .. description(unit))
    unit.AddPropAircraft.AARProbe = false
    if sideName == "red" then
        unit.AddPropAircraft.LaserCode1 = 6
    else
        unit.AddPropAircraft.LaserCode1 = 7
    end
end

local function setF5Options(unit, sideName)
    print("INFO:  Setting options for " .. description(unit))
    if sideName == "red" then
        unit.AddPropAircraft.LaserCode1 = 6
    else
        unit.AddPropAircraft.LaserCode1 = 7
    end
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
            setFuel(unit)
            setCountermeasures(unit)
            setRadio(unit, sideName)
            setRopeLength(unit)
            if unit.type == "F-14B" then
                setF14Options(unit, sideName)
            end
            if unit.type == "M-2000C" then
                setM2000Options(unit, sideName)
            end
            if unit.type == "JF-17" then
                setJF17Options(unit, sideName)
            end
            if unit.type == "F-5E-3" then
                setF5Options(unit, sideName)
            end
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
