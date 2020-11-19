--split of state.lua respawn queue updating to allow bases.lua to update spawn queue without creating a loop between state.lua and baseOwnershipCheck.lua
local logging = require("logging")
local log = logging.Logger:new("updateSpawnQueue")
local M = {}

-- recently spawned units (from player unpacking via CTLD or via code)
M.spawnQueue = {}

function M.pushSpawnQueue(groupName)
    log:info("Adding $1 to spawn queue", groupName)
    table.insert(M.spawnQueue, groupName)
end

return M