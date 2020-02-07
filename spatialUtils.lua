local M = {}

function M.isPointInZone(point, zonePoint, zoneRadius)
    local pX = point.x
    local pY = point.z
    local zX = zonePoint.x
    local zY = zonePoint.z

    local dX = pX - zX
    local dY = pY - zY

    return dX * dX + dY * dY < zoneRadius * zoneRadius
end

return M
