ctld.slingLoad = true

ctld.maxExtractDistance = 200 -- max distance from vehicle to troops to allow a group extraction
ctld.maximumSearchDistance = 0 -- max distance for troops to search for enemy
ctld.minimumDeployDistance = 600 -- minimum distance from a friendly pickup zone where you can deploy a crate
ctld.cratesRequiredForFOB = 1 -- The amount of crates required to build a FOB. Once built, helis can spawn crates at this outpost to be carried and deployed in another area.
ctld.buildTimeFOB = 30 --time in seconds for the FOB to be built
ctld.crateWaitTime = 5 -- time in seconds to wait before you can spawn another crate
ctld.forceCrateToBeMoved = false -- a crate must be picked up at least once and moved before it can be unpacked. Helps to reduce crate spam. Only works if ctld.slingLoad = false -Swallow you might want to change this to True

ctld.unitActions = {
    ["UH-1H"] = { crates = true, troops = true },
}
