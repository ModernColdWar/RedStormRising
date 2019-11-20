local M = {}

function M.loadMission(missionDir)
    print("Loading mission from " .. missionDir)
    dofile(missionDir .. [[\mission]]);
    dofile(missionDir .. [[\l10n\DEFAULT\dictionary]])
    print("Mission loaded")
end

function M.serializeMission(mission, missionDir)
    package.path = package.path .. ";" .. os.getenv("DCS_PATH") .. [[\Scripts\?.lua]]
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

function M.iterGroups(mission, groupCallback)
    for _, coalition in pairs(mission.coalition) do
        for _, country in ipairs(coalition.country) do
            if country.plane ~= nil then
                for _, groups in pairs(country.plane) do
                    for _, group in ipairs(groups) do
                        groupCallback(group)
                    end
                end
            end
            if country.helicopter ~= nil then
                for _, groups in pairs(country.helicopter) do
                    for _, group in ipairs(groups) do
                        groupCallback(group)
                    end
                end
            end
        end
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
    for _, zone in ipairs(mission.triggers.zones) do
        local zoneName = zone.name
        if string.match(zoneName:lower(), pattern) then
            table.insert(zones, zoneName)
        end
    end
    table.sort(zones)
    return zones
end

return M