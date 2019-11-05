env.info("RSR starting")

env.info("Loading MIST")
dofile(lfs.writedir()..[[Scripts\RSR\mist_4_3_74.lua]])
env.info("MIST loaded")

log = mist.Logger:new("RSR", "info")

log:info("Loading CTLD")
dofile(lfs.writedir()..[[Scripts\RSR\CTLD.lua]])
log:info("CTLD loaded")

function markRemoved(event)
  if event.id == world.event.S_EVENT_MARK_REMOVED then
    log:info(string.format("Mark removed: id %s, idx %s, coalition %s, group %s, text %s", event.id, event.idx, event.coalition, event.groupID, event.text))
  end
end

mist.addEventHandler(markRemoved)

log:info("RSR ready")
