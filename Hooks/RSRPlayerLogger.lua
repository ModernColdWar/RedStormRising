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

M.insert_connection = M.db:prepare("INSERT INTO connection(ucid, name, ipaddr) VALUES(?, ?, ?)")
M.insert_chat = M.db:prepare("INSERT INTO chat(ucid, name, to_all, message) VALUES(?, ?, ?, ?)")

-- populated on connect; used in callbacks which just pass in a playerId
M.connectedPlayerInfo = {
    -- {name = <name>, ucid = <ucid>},
}

function M.onPlayerConnect(playerId)
    local ucid = net.get_player_info(playerId, 'ucid')
    local name = net.get_player_info(playerId, 'name')
    local ipaddr = net.get_player_info(playerId, 'ipaddr')
    net.log("RSRPlayerLogger: logging connection from " .. name)
    M.connectedPlayerInfo[playerId] = { name = name, ucid = ucid }
    M.insert_connection:bind_values(ucid, name, ipaddr)
    M.insert_connection:step()
    M.insert_connection:reset()
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

function M.onPlayerTrySendChat(playerId, msg, all)
    local playerInfo = M.connectedPlayerInfo[playerId]
    local name = playerInfo.name
    local ucid = playerInfo.ucid
    -- all is -1 for chat to all, -2 for chat to allies (!!!)
    local toAll = all == -1
    local destination = toAll and "ALL" or "ALLIES"
    net.log("RSRPlayerLogger: CHAT [" .. name .. "] (" .. ucid .. ") <" .. destination .. ">: " .. msg)
    M.insert_chat:bind_values(ucid, name, toAll, msg)
    M.insert_chat:step()
    M.insert_chat:reset()
end

DCS.setUserCallbacks(M)

net.log("Loaded RSRPlayerLogger")
