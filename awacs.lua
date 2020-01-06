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

function M.onMissionStart(awacsBases)
    log:info("Configuring AWACS at mission start")

    for _, baseName in pairs(awacsBases) do
        local baseOwner = state.getOwner(baseName)
        log:info("$1 owner is $2", baseName, baseOwner)
        if baseOwner == "red" then
            spawnAWACS(string.format("%s Red AWACS", baseName))
        elseif baseOwner == "blue" then
            spawnAWACS(string.format("%s Blue AWACS", baseName))
        end
    end
end

return M
