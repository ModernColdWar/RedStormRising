-- RedStormRising player info and chat logger
package.cpath = package.cpath .. [[;C:\dev\luarocks\lib\lua\5.1\?.dll]]
local sqlite3 = require("lsqlite3")
local lfs = require('lfs')

local M = {}

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

DCS.setUserCallbacks(M)

net.log("Loaded RSRPlayerLogger")
