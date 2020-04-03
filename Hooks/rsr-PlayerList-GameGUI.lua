net.log("############################################rsr-playerlist-hook opened")
local status, result = pcall(function()
    local rsrPlaylist = require('lfs');
    dofile(rsrPlaylist.writedir() .. [[Scripts\n0xy\playlist.lua]]);
end, nil)
if not status then
    net.log(result)
end
