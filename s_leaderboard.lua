db = dbConnect("sqlite", "database.db")

function startResource()
	dbExec(db, "CREATE TABLE IF NOT EXISTS top_killers(nick, kills, deaths)")
	dbExec(db, "CREATE TABLE IF NOT EXISTS top_killers_kd(nick, kills, deaths, kd)")
	dbExec(db, "CREATE TABLE IF NOT EXISTS top_zkillers(nick, kills)")
	dbExec(db, "CREATE TABLE IF NOT EXISTS top_alive(nick, alive)")
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), startResource)

function ShowTopKillers()
	allData = {}
	local data = dbQuery(db, "SELECT * FROM top_killers_kd ORDER BY kd DESC LIMIT 50")
	local result = dbPoll(data, -1)
	local counter = 1
	for ind, val in ipairs( result ) do
		local killer = {}
		
		killer.id = counter
		killer.nick = val.nick
		killer.kills = val.kills
		killer.deaths = val.deaths
		if val.kd > 0 then
			killer.kd = val.kd
		else 
			killer.kd = 0
		end
		allData[killer.id] = killer
		counter = counter +1
	end
	
	triggerClientEvent ( source, "Leaderboard:createGui", source, allData )
	
end
addEvent("ShowTopKillers", true)
addEventHandler("ShowTopKillers", getRootElement(), ShowTopKillers)

function ShowTopZKillers()
	allData = {}
	local data = dbQuery(db, "SELECT * FROM top_zkillers ORDER BY kills DESC LIMIT 50")
	local result = dbPoll(data, -1)
	local counter = 1
	
	for ind, val in ipairs( result ) do
		local killer = {}
		killer.id = counter
		killer.nick = val.nick
		killer.kills = val.kills
		
		allData[killer.id] = killer
		counter = counter +1
	end
	
	triggerClientEvent ( source, "Leaderboard:showZkillersC", source, allData )
	
end
addEvent("ShowTopZKillers", true)
addEventHandler("ShowTopZKillers", getRootElement(), ShowTopZKillers)

function ShowTopATime()
	allData = {}
	local data = dbQuery(db, "SELECT * FROM top_alive ORDER BY alive DESC LIMIT 50")
	local result = dbPoll(data, -1)
	local counter = 1
	
	for ind, val in ipairs( result ) do
		local killer = {}
		
		killer.id = counter
		killer.nick = val.nick
		killer.alive = val.alive
		
		allData[killer.id] = killer
		counter = counter +1
	end
	
	triggerClientEvent ( source, "Leaderboard:ShowTopATimeC", source, allData )
	
end
addEvent("ShowTopATime", true)
addEventHandler("ShowTopATime", getRootElement(), ShowTopATime)

function round2(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function updateKdRatio()
	local data = dbQuery(db, "SELECT * FROM top_killers ORDER BY kills DESC LIMIT 50")
	local result = dbPoll(data, -1)
	dbExec(db, "DELETE FROM top_killers_kd WHERE kills < 99999999")
	for ind, val in ipairs( result ) do
		local kd = val.kills / val.deaths
		local kd = round2(kd, 2)
		dbExec(db, "INSERT INTO top_killers_kd (nick, kills, deaths, kd) VALUES (?, ?, ?, ?)", val.nick, val.kills, val.deaths, kd)
	end
end
setTimer(updateKdRatio, 600000, 0) -- 10 min

function checkExistKiller(nick)
	local data = dbQuery(db, "SELECT * FROM top_killers WHERE nick = ?", nick)
	local result = dbPoll(data, -1)
	
	if next(result) == nil then
		return false
	else
		return true
	end
end

function checkExistSurvivor(nick)
	local data = dbQuery(db, "SELECT * FROM top_alive WHERE nick = ?", nick)
	local result = dbPoll(data, -1)
	
	if next(result) == nil then
		return false
	else
		return true
	end
end

function checkAliveTimeBigger(nick, minutes)
	local data = dbQuery(db, "SELECT * FROM top_alive WHERE nick = ?", nick)
	local result = dbPoll(data, -1)
	
	for ind, val in ipairs( result ) do
		if tonumber(val.alive) < tonumber(minutes) then
			return true
		else
			return false
		end
	end
end

function kilLDayZPlayer (killer,headshot,weapon)
	if killer and getElementType(source) == "player" then
		local killerNick = getPlayerName ( killer )
		local deadNick = getPlayerName ( source )
		local alive = getElementData(source, "alivetime")
		
		if checkExistSurvivor(deadNick) == true then
			if checkAliveTimeBigger(deadNick, alive) == true then
				dbExec(db, "UPDATE top_alive SET alive = ? WHERE nick = ?", alive, deadNick)
			end
		else
			if alive > 10 then
				dbExec(db, "INSERT INTO top_alive(nick, alive) VALUES(?,?)", deadNick, alive)
			end
		end
		
		if checkExistKiller(killerNick) == false then
			dbExec(db, "INSERT INTO top_killers(nick, kills, deaths) VALUES(?,1,0)", 
			killerNick)
			if checkExistKiller(deadNick) == false then
				dbExec(db, "INSERT INTO top_killers(nick, kills, deaths) VALUES(?,0,1)", 
				deadNick)
			else
				dbExec(db, "UPDATE top_killers SET deaths = deaths +1 WHERE nick = ?", 
				deadNick)
			end
		else
			dbExec(db, "UPDATE top_killers SET kills = kills +1 WHERE nick = ?", 
			killerNick)
			if checkExistKiller(deadNick) == false then
				dbExec(db, "INSERT INTO top_killers(nick, kills, deaths) VALUES(?,0,1)", 
				deadNick)
			else
				dbExec(db, "UPDATE top_killers SET deaths = deaths +1 WHERE nick = ?", 
				deadNick)
			end
		end
	end
end
addEvent("kilLDayZPlayer",true)
addEventHandler("kilLDayZPlayer",getRootElement(),kilLDayZPlayer)

function checkExistZombieKiller(nick)
	local data = dbQuery(db, "SELECT * FROM top_zkillers WHERE nick = ?", nick)
	local result = dbPoll(data, -1)
	
	if next(result) == nil then
		return false
	else
		return true
	end
end

addEventHandler("onElementDataChange",getRootElement(), function(dataName, oldValue)
	if dataName == "zombieskilled" and oldValue > 0 and getElementType(source) == "player" and getElementData(source, "logedin") then
		local killerNick = getPlayerName ( source )
		if checkExistZombieKiller(killerNick) == false then
			dbExec(db, "INSERT INTO top_zkillers(nick, kills) VALUES(?,1)", 
			killerNick)
		else
			dbExec(db, "UPDATE top_zkillers SET kills = kills +1 WHERE nick = ?", 
			killerNick)
		end
	end
end)