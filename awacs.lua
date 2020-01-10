require("mist_4_3_74")
local state = require("state")

local M = {}

local log = mist.Logger:new("AWACS", "info")

local function spawnAWACS(spawnTemplatePrefix, spawnLimit)
    log:info("Spawning $1", spawnTemplatePrefix)
    SPAWN:New(spawnTemplatePrefix)
         :InitLimit(1, spawnLimit)
         :InitRepeat()
         :SpawnScheduled(3600, 0.05)
end

function M.onMissionStart(awacsBases, awacsSpawnLimit)
    log:info("Configuring AWACS at mission start")

    for _, baseName in pairs(awacsBases) do
        local baseOwner = state.getOwner(baseName)
        log:info("$1 owner is $2", baseName, baseOwner)
        if baseOwner == "red" then
            spawnAWACS(string.format("%s Red AWACS", baseName), awacsSpawnLimit)
        elseif baseOwner == "blue" then
            spawnAWACS(string.format("%s Blue AWACS", baseName), awacsSpawnLimit)
        end
    end
end

return M
