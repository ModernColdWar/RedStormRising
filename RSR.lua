env.info("RSR starting")

env.info("Loading MIST")
dofile(lfs.writedir() .. [[Scripts\RSR\mist_4_3_74.lua]])
env.info("MIST loaded")

log = mist.Logger:new("RSR", "info")

log:info("Loading CTLD")
dofile(lfs.writedir() .. [[Scripts\RSR\CTLD.lua]])
log:info("CTLD loaded")

ctld.slingLoad = true

function markRemoved(event)
    if event.id == world.event.S_EVENT_MARK_REMOVED and event.text ~= nil then
        local text = event.text:lower()
        local side = event.coalition == coalition.side.RED and "red" or "blue"
        if text:find("-crate") then
            local weight = tonumber(string.sub(text, 8))
            log:info("Spawing $1 crate with weight $2 at $3", side, weight, event.pos)
            ctld.spawnCrateAtPoint(side, weight, event.pos)
        end
    end
end

mist.addEventHandler(markRemoved)

log:info("RSR ready")
