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
    if krasOwner == "red" then
        log:info("Kras-C owned by red")
        spawnAWACS("Red AWACS")
    elseif krasOwner == "blue" then
        log:info("Kras-C owned by blue")
        spawnAWACS("Blue AWACS")
    end
    local vazOwner = state.getOwner("Vaziani")
    if vazOwner == "red" then
        log:info("Vaziani owned by red")
        spawnAWACS("Red AWACS 2")
    elseif vazOwner == "blue" then
        log:info("Vaziani owned by blue")
        spawnAWACS("Blue AWACS 2")
    end
end

return M
