-- RedStormRising player info and chat logger
-- This handles callbacks related to connections and chat; slot changes are handled by RSRSlotBlocker
package.cpath = package.cpath .. [[C:\dev\luarocks\lib\lua\5.1\?.dll]]
local sqlite3 = require("lsqlite3")
local lfs = require('lfs')

local M = {}

-- Banned IP addresses
M.bannedIps = {

}

-- Banned player UCIDs
M.bannedUcids = {
    "7c0dc87190061fd98dcf2936444ba05c", -- "nuke china!!!" 2020-04-09
}

M.db = sqlite3.open(lfs.writedir() .. [[Scripts\RSR\rsr.sqlite]], sqlite3.OPEN_READWRITE)

M.insert_stmt = M.db:prepare("INSERT INTO connection(ucid, name, ipaddr) VALUES(?, ?, ?)")

function M.onPlayerConnect(playerId)
    local ucid = net.get_player_info(playerId, 'ucid')
    local name = net.get_player_info(playerId, 'name')
    local ipaddr = net.get_player_info(playerId, 'ipaddr')
    net.log("RSRPlayerLogger: logging connection from " .. name)
    M.insert_stmt:bind_values(ucid, name, ipaddr)
    M.insert_stmt:step()
    M.insert_stmt:reset()
end

-- based on slmod from https://github.com/mrSkortch/DCS-SLmod/blob/master/Scripts/net/Slmodv7_5/SlmodCallbacks.lua
function M.onPlayerTryConnect(ipaddr, name, ucid)
    if M.bannedIps[ipaddr] then
        net.log("RSRPlayerLogger: not allowing " .. name .. ", ucid " .. ucid .. " from banned IP" .. ipaddr)
        return false, "You are banned from this server."
    end

    if M.bannedUcids[ucid] then
        net.log("RSRPlayerLogger: not allowing " .. name .. ", ucid " .. ucid .. " from banned ucid" .. ucid)
        return false, "You are banned from this server."
    end
    -- return nothing
end

DCS.setUserCallbacks(M)

net.log("Loaded RSRPlayerLogger")
