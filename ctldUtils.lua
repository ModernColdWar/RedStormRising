local missionUtils = require("missionUtils")

local M = {}

function M.getLogisticUnits(mission)
    return missionUtils.getZoneNames(mission, " logistics$")
end

return M