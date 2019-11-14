local utils = require("utils")

local M = {}

local function crate(text)
    local weight = tonumber(text)
    log:info("Spawning red crate with weight $1 at $2", weight, event.pos)
    ctld.spawnCrateAtPoint("red", weight, event.pos)
end

local function destroy(text)
    local unit = Unit.getByName(text)
    if unit ~= nil then
        log:info("Destroying unit $1", text)
        unit:destroy()
    else
        log:warn("Unable to find unit with name $1", text)
    end
end
--- Handles mark removals
function M.markRemoved(event)
    if event.id == world.event.S_EVENT_MARK_REMOVED and event.text ~= nil then
        if event.text:find("-crate") then
            crate(string.sub(event.text, 8))
        elseif event.text:find("-destroy") then
            destroy(string.sub(event.text, 10))
        end
    end
end

if utils.runningInDcs() and rsr.devMode then
    mist.addEventHandler(M.markRemoved)
end

return M
