script_name("SRP-Scan-Online")
script_author("Serhiy_Rubin")
script_version("1.11.07.20")

local sampev = require "lib.samp.events"
local antiflood = os.clock() * 1000
local scan = false
local player_find = {}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('scan', scan_cmd)
	while true do
		wait(0)
		if scan then
			players_noafk = 0
			players_afk = 0
			players_sleep = 0
			all_players_int = 0
			checking_players_int = 0

			for id = 0, 999 do
				if sampIsPlayerConnected(id) then
					if sampGetPlayerScore(id) > 0 then
						all_players_int = all_players_int + 1
					end
				end
			end

			sampAddChatMessage(' >  Сканирование запущено. Ничего не пишите в чат!', 0xFF199119)
			local sec = (all_players_int * 800) / 1000
			sampAddChatMessage(' >  Примерное время выполнения: '..math.floor(sec / 60)..' мин. '..math.ceil(sec % 60)..' сек.', 0xFF199119)
			
			for id = 0, 999 do
				if sampIsPlayerConnected(id) then
					if sampGetPlayerScore(id) > 0 then
						repeat 
							wait(0)
						until math.ceil(os.clock() * 1000 - antiflood) > 800
						player_find.id = id
						player_find.name = sampGetPlayerNickname(id)
						respond = false
						sampSendChat('/id '..id)
						checking_players_int = checking_players_int + 1
						printStringNow('~G~Check ID:'..id..'~N~  '..checking_players_int..'/'..all_players_int, 800)
						repeat 
							wait(0)
						until respond
					end
				end
			end
			sampAddChatMessage(' >  Cканирование завершено! Общий онлайн: '..all_players_int, 0xFF199119)
			sampAddChatMessage(' >  Активные игроки: '..players_noafk, 0xFF199119)
			sampAddChatMessage(' >  Игроки в AFK: '..players_afk, 0xFF199119)
			sampAddChatMessage(' >  Игроки в SLEEP: '..players_sleep, 0xFF199119)
			respond = nil
			scan = false
		end
	end
end

function scan_cmd()
	scan = not scan
	printStringNow((scan and 'Scan - ON' or 'Scan - OFF'), 1000)
end

function sampev.onServerMessage(color, message)
	if message:find(player_find.name) and message:find('LVL') then
		if message:find('SLEEP') then
			players_sleep = players_sleep + 1
		elseif message:find('AFK') then
			players_afk = players_afk + 1
		else
			players_noafk = players_noafk + 1
		end
		respond = true
		return false
	end
	if message == ' Не флуди!' and respond ~= nil and not respond then
		lua_thread.create(function()
			repeat 
				wait(0)
			until math.ceil(os.clock() * 1000 - antiflood) > 800
			sampSendChat('/id '..player_find.id)
		end)
	end
end

function sampev.onSendChat(message)
    antiflood = os.clock() * 1000
end
function sampev.onSendCommand(cmd)
    antiflood = os.clock() * 1000
end