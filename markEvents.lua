--- Handles mark removals
--- "-crate <weight>" spawns a RED crate at the marker
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

if rsr.devMode then
    mist.addEventHandler(markRemoved)
end
