
package.path  = package.path..";.\\LuaSocket\\?.lua;"..'.\\Scripts\\?.lua;'.. '.\\Scripts\\UI\\?.lua;'
package.cpath = package.cpath..";.\\LuaSocket\\?.dll;"

local JSON = require("json")
local socket = require("socket")
local udpEventHost = "127.0.0.1"
local udpEventPort = 6969


function sendBotEvent(dataToSend)
    local udp = socket.udp()
    udp:settimeout(0.01)
    udp:setsockname("*", 0)
    udp:setpeername(udpEventHost, udpEventPort)
    local jsonEventTableForBot = JSON:encode(dataToSend)
    udp:send(jsonEventTableForBot)
end


--Airbase Table
bot_Airbases = {
['redOwnership'] = {},
['blueOwnership'] = {},
['noOwnership'] = {},
}


for i,airbase in pairs(coalition.getAirbases(1)) do
	local aName = airbase:getCallsign()
	bot_Airbases['redOwnership'][#bot_Airbases.redOwnership + 1] = aName
end


for i,airbase in pairs(coalition.getAirbases(2)) do
	local aName = airbase:getCallsign()
	bot_Airbases['blueOwnership'][#bot_Airbases.blueOwnership + 1] = aName
end
bot_Airbases.id = 51
sendBotEvent(bot_Airbases)

