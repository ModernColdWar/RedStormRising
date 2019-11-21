local M = {}

-- From https://wiki.hoggitworld.com/view/Category:Terrain_Information
M.airbases = {
    Caucasus = {
        [12] = "Anapa-Vityazevo",
        [13] = "Krasnodar-Center",
        [14] = "Novorossiysk",
        [15] = "Krymsk",
        [16] = "Maykop-Khanskaya",
        [17] = "Gelendzhik",
        [18] = "Sochi-Adler",
        [19] = "Krasnodar-Pashkovsky",
        [20] = "Sukhumi-Babushara",
        [21] = "Gudauta",
        [22] = "Batumi",
        [23] = "Senaki-Kolkhi",
        [24] = "Kobuleti",
        [25] = "Kutaisi",
        [26] = "Mineralnye Vody",
        [27] = "Nalchik",
        [28] = "Mozdok",
        [29] = "Tbilisi-Lochini",
        [30] = "Soganlug",
        [31] = "Vaziani",
        [32] = "Beslan",
    }
}

function M.loadMission(missionDir)
    print("Loading mission from " .. missionDir)
    dofile(missionDir .. [[\mission]])
    dofile(missionDir .. [[\warehouses]])
    dofile(missionDir .. [[\l10n\DEFAULT\dictionary]])
    print("Mission loaded")
end

function M.serializeMission(mission, missionDir)
    local dcsPath = os.getenv("DCS_PATH")
    if dcsPath == nil then
        error("DCS_PATH environment variable must be set")
    end
    package.path = package.path .. ";" .. dcsPath .. [[\Scripts\?.lua]]
    local Serializer = require("Serializer")
    local missionfile = missionDir .. [[\mission]]
    print("Serializing to mission at " .. missionfile)
    local outfile = io.open(missionDir .. "\\mission", "w+")
    -- Uses ED's serializer to make sure it's compatible
    local serializer = Serializer.new(outfile)
    serializer.fout = outfile -- Why this is required is beyond me, Serializer.new() does this already
    serializer:serialize_simple2('mission', mission)
    outfile:close()
    print("Mission serialized")
end

function M.getDictionaryValue(key)
    -- luacheck: read_globals dictionary
    return dictionary[key]
end

function M.iterCountries(mission, countryCallback)
    for sideName, coalition in pairs(mission.coalition) do
        for _, country in ipairs(coalition.country) do
            countryCallback(sideName, country)
        end
    end
end

function M.iterGroups(mission, groupCallback)
    M.iterCountries(mission, function(sideName, country)
        if country.plane ~= nil then
            for _, groups in pairs(country.plane) do
                for _, group in ipairs(groups) do
                    groupCallback(group, sideName)
                end
            end
        end
        if country.helicopter ~= nil then
            for _, groups in pairs(country.helicopter) do
                for _, group in ipairs(groups) do
                    groupCallback(group, sideName)
                end
            end
        end
    end)
end

function M.iterZones(mission, zoneCallback)
    for _, zone in ipairs(mission.triggers.zones) do
        zoneCallback(zone)
    end
end

function M.isClientGroup(group)
    for _, unit in ipairs(group.units) do
        if unit.skill == "Client" then
            return true
        end
    end
    return false
end

local transportTypes = {
    "C-101CC",
    "Ka-50",
    "L-39ZA",
    "Mi-8MT",
    "SA342L",
    "SA342M",
    "SA342Mistral",
    "UH-1H",
}

function M.isTransportType(type)
    for _, transportType in ipairs(transportTypes) do
        if type == transportType then
            return true
        end
    end
    return false
end

function M.getZoneNames(mission, pattern)
    local zones = {}
    M.iterZones(mission, function(zone)
        local zoneName = zone.name
        if string.match(zoneName:lower(), pattern) then
            table.insert(zones, zoneName)
        end
    end)
    table.sort(zones)
    return zones
end

function M.iterBases(mission, theatre, baseCallback)
    -- luacheck: read_globals warehouses
    for baseId, baseName in pairs(M.airbases[theatre]) do
        baseCallback(baseName, warehouses.airports[baseId])
    end
    M.iterCountries(mission, function(sideName, country)
        if country.static ~= nil and country.static.group ~= nil then
            for _, group in ipairs(country.static.group) do
                for _, unit in ipairs(group.units) do
                    if unit.type == "FARP" then
                        baseCallback(M.getDictionaryValue(unit.name))
                    end
                end
            end
        end
    end)
end

return M