local M = {}

local function configureJtacs(jtacPrefix, hqName, sideName)
    local jtacSetGroup = SET_GROUP:New():FilterPrefixes(jtacPrefix):FilterStart()
    local hq = GROUP:FindByName(hqName)
    local cc = COMMANDCENTER:New(hq, hqName)
    local jtacDetection = DETECTION_AREAS:New(jtacSetGroup, 5000)
    local attackSet = SET_GROUP:New():FilterCoalitions(sideName):FilterStart()
    DESIGNATE:New(cc, jtacDetection, attackSet)
end

function M.startCtldJtacDesignation()
    configureJtacs("CTLD_UAZ", "Red HQ", "red")
    configureJtacs("CTLD_Hummer", "Blue HQ", "blue")
end

return M