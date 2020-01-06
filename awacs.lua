require("mist_4_3_74")
local state = require("state")

local M = {}

local log = mist.Logger:new("AWACS", "info")

local function spawnAWACS(spawnTemplatePrefix)
    log:info("Spawning $1", spawnTemplatePrefix)
    SPAWN:New(spawnTemplatePrefix)
         :InitLimit(1, 99)
         :SpawnScheduled(1800, 0.1)
end

function M.onMissionStart()
    log:info("Configuring AWACS at mission start")

    local krasOwner = state.getOwner("Krasnodar-Center")
    log:info("Krasnodar-Center owner is $1", krasOwner)
    if krasOwner == "red" then
        spawnAWACS("Krasnodar-Center Red AWACS")
    elseif krasOwner == "blue" then
        spawnAWACS("Krasnodar-Center Blue AWACS")
    end

    local vazOwner = state.getOwner("Vaziani")
    log:info("Vaziani owner is $1", krasOwner)
    if vazOwner == "red" then
        spawnAWACS("Vaziani Red AWACS")
    elseif vazOwner == "blue" then
        spawnAWACS("Vaziani Blue AWACS")
    end
end

return M
