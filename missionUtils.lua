local logging = require("logging")
local log = logging.Logger:new("missionUtils", "info")

local M = {}

-- From https://wiki.hoggitworld.com/view/Category:Terrain_Information
M.airbases = {
    --[[Caucasus = {
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
    }--]]	
    Syria = {
  	    [1] = "Abu al-Duhur", 
      	[2] = "Adana Sakirpasa", 
      	[3] = "Al Qusayr", 
      	[4] = "An Nasiriyah", 
      	[6] = "Beirut-Rafic Hariri", 
      	[7] = "Damascus", 
      	[8] = "Marj as Sultan South", 
      	[9] = "Al-Dumayr", 
      	[10] = "Eyn Shemer", 
      	[13] = "Haifa", 
      	[14] = "Hama", 
      	[15] = "Hatay", 
      	[16] = "Incirlik", 
      	[17] = "Jirah", 
      	[18] = "Khalkhalah", 
      	[19] = "King Hussein Air College", 
      	[20] = "Kiryat Shmona", 
      	[21] = "Bassel Al-Assad", 
      	[22] = "Marj as Sultan North", 
      	[23] = "Marj Ruhayyil", 
      	[24] = "Megiddo", 
      	[25] = "Mezzeh", 
      	[26] = "Minakh", 
      	[27] = "Aleppo", 
      	[28] = "Palmyra", 
      	[29] = "Qabr as Sitt", 
      	[30] = "Ramat David",
      	[31] = "Kuweires",
      	[32] = "Rayak", 
      	[33] = "Rene Mouawad", 
      	[37] = "Tabqa", 
      	[38] = "Taftanaz", 
      	[40] = "Wujah Al Hajar",
	}
}
function M.loadMission(missionDir)
    print("Loading mission from " .. missionDir)
    dofile(missionDir .. [[\mission]])
    dofile(missionDir .. [[\options]])
    dofile(missionDir .. [[\warehouses]])
    dofile(missionDir .. [[\l10n\DEFAULT\dictionary]])
    print("Mission loaded")
end

local function serialize(filename, name, object)
    local Serializer = require("Serializer")
    print("Serializing to " .. name .. " at " .. filename)
    local outfile = io.open(filename, "w+")
    -- Uses ED's serializer to make sure it's compatible
    local serializer = Serializer.new(outfile)
    serializer.fout = outfile -- Why this is required is beyond me, Serializer.new() does this already
    serializer:serialize_simple2(name, object)
    outfile:close()
    print(name .. " serialized")
end

-- luacheck: globals warehouses
function M.serializeMission(missionDir)
    local dcsPath = os.getenv("DCS_PATH")
    if dcsPath == nil then
        error("DCS_PATH environment variable must be set")
    end
    package.path = package.path .. ";" .. dcsPath .. [[\Scripts\?.lua]]
    serialize(missionDir .. [[\mission]], "mission", mission)
    serialize(missionDir .. [[\warehouses]], "warehouses", warehouses)
    serialize(missionDir .. [[\options]], "options", options)
end

function M.getDictionaryValue(key)
    -- luacheck: read_globals dictionary
    return dictionary[key]
end

function M.iterCountries(mission, countryCallback)
    for sideName, coalition in pairs(mission.coalition) do
        if coalition.country ~= nil then
            for _, country in ipairs(coalition.country) do
                countryCallback(sideName, country)
            end
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

function M.iterVehicleGroups(mission, groupCallback)
    M.iterCountries(mission, function(sideName, country)
        if country.vehicle ~= nil then
            for _, groups in pairs(country.vehicle) do
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
    -- returns true if any unit in the group is a Client, otherwise false
    for _, unit in ipairs(group.units) do
        if unit.skill == "Client" then
            return true
        end
    end
    return false
end

--ctld.transportTypes
local transportTypes = {

    --"SA342Mistral",
    "SA342L",
    "SA342M",
	"SA342Minigun",
    "Ka-50",
    "UH-1H",
    "Mi-8MT",
    ----
    "C-101CC",
    "L-39ZA",
    ----
    "MiG-15bis",
    "F-86F Sabre",
    ----
    "TF-51D",
    "Bf-109K-4",
    "FW-190D9",
    "FW-190A8",
    "I-16",
    "SpitfireLFMkIX",
    "SpitfireLFMkIXCW",
    "P-51D",
    "P-51D-30-NA",
    "Christen Eagle II",
    "Yak-52"
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

-- DCS getZone function only returns zone position and radius based on name, therefore store complete zone details i.e. color
function M.getZones(mission, pattern)
    local zones = {}
    M.iterZones(mission, function(zone)
        local zoneName = zone.name
        if string.match(zoneName:lower(), pattern) then
            table.insert(zones, zone)
        end
    end)
    --table.sort(zones)
    return zones
end

function M.getSpecificZone(mission, pattern)
    local patternNoHyphen = string.gsub(pattern, "-", "")
    local foundZone = "NotFound"
    M.iterZones(mission, function(zone)
        local zoneName = zone.name
        local zoneNameNoHyphen = string.gsub(zoneName, "-", "")
        if string.match(zoneNameNoHyphen:lower(), patternNoHyphen) then
            foundZone = zone
        end
    end)
    if foundZone == "NotFound" then
        log:error("$1 zone not found.", pattern)
    end
    return foundZone
end

function M.iterBases(mission, theatre, baseCallback)
    -- luacheck: read_globals warehouses
    for baseId, baseName in pairs(M.airbases[theatre]) do
        baseCallback(baseName, warehouses.airports[baseId], true)
    end
    M.iterCountries(mission, function(_, country)
        if country.static ~= nil and country.static.group ~= nil then
            for _, group in ipairs(country.static.group) do
                for _, unit in ipairs(group.units) do
                    if unit.type == "FARP" then
                        baseCallback(M.getDictionaryValue(unit.name), warehouses.warehouses[unit.unitId], false)
                    end
                end
            end
        end
    end)
end

return M