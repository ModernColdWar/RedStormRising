env.info("RSR starting")

env.info("Loading MIST")
dofile(lfs.writedir()..[[Scripts\RSR\mist_4_3_74.lua]])
env.info("MIST loaded")

log = mist.Logger:new("RSR", "info")

log:info("Loading CTLD")
dofile(lfs.writedir()..[[Scripts\RSR\CTLD.lua]])
log:info("CTLD loaded")

log:info("RSR ready")
