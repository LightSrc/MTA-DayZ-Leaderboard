local openKey = "F1"
local killerTable = {}
hl = "e8e7e7" --[Fare Buton üstüne getirdiğinizde oluşan renk ]-(http://html-color-codes.info/)
hl2 = "FFFFFF" --[Bu ayarla oynamanıza gerek yoktur.]
panel, icon, closeBTN, logo_image, tabs = nil
opened = false
openedZKillers = false
openedATime = false

function createGUI(allKillers)
	local sw, sh = guiGetScreenSize()
	local screenW, screenH = guiGetScreenSize()
	panel = guiCreateStaticImage((screenW - 673) / 2, (screenH - 464) / 2, 673, 464, "panel.png", false)
	icon = guiCreateStaticImage(288, 20, 100, 100, "leaderboard.png", false, panel)
	closeBTN = guiCreateStaticImage(628, 0, 45, 22, "btn-close.png", false, panel)
	addEventHandler("onClientGUIClick", closeBTN, closeGUI, false )
	logo_image = guiCreateStaticImage(10, 139, 650, 315, "memo_arka.png", false, panel)
	tabs = guiCreateTabPanel (4, 4, 643, 307, false, logo_image)
	tabKillers = guiCreateTab( "Top 50 killers", tabs )
	killersScreenGridList = guiCreateGridList ( 0, 0.1, 1, 0.9, true, tabKillers )
	guiGridListAddColumn ( killersScreenGridList, "#", 0.1 )
	guiGridListAddColumn ( killersScreenGridList, "Nick", 0.5 )
	guiGridListAddColumn ( killersScreenGridList, "Kills", 0.1 )
	guiGridListAddColumn ( killersScreenGridList, "Deaths", 0.1 )
	guiGridListAddColumn ( killersScreenGridList, "K/D Ratio", 0.1 ) 
	tabZombies = guiCreateTab( "Top 50 zombie killers", tabs )
	zombiesScreenGridList = guiCreateGridList ( 0, 0.1, 1, 0.9, true, tabZombies )
	guiGridListAddColumn ( zombiesScreenGridList, "#", 0.2 )
	guiGridListAddColumn ( zombiesScreenGridList, "Nick", 0.5 )
	guiGridListAddColumn ( zombiesScreenGridList, "Zombies killed", 0.2 ) 
	tabAlive = guiCreateTab( "Top 50 alive time", tabs )
	aliveScreenGridList = guiCreateGridList ( 0, 0.1, 1, 0.9, true, tabAlive )
	guiGridListAddColumn ( aliveScreenGridList, "#", 0.2 )
	guiGridListAddColumn ( aliveScreenGridList, "Nick", 0.5 )
	guiGridListAddColumn ( aliveScreenGridList, "Alive time", 0.2 )  
	killerTable = allKillers
	killerCounter = 1
	for id, killer in pairs(killerTable) do
		local row = guiGridListAddRow ( killersScreenGridList)
		guiGridListSetItemText ( killersScreenGridList, row, 1, killerCounter, false, true )
		guiGridListSetItemText ( killersScreenGridList, row, 2, killer.nick, false, false )
		guiGridListSetItemText ( killersScreenGridList, row, 3, killer.kills, false, false )
		guiGridListSetItemText ( killersScreenGridList, row, 4, killer.deaths, false, false )
		guiGridListSetItemText ( killersScreenGridList, row, 5, toDecimals(killer.kd), false, true )
		killerCounter = killerCounter +1
	end
end
addEvent("Leaderboard:createGui", true)
addEventHandler("Leaderboard:createGui", root, createGUI)

function toDecimals(x)
	local digits = 2
	local shift = 10 ^ digits
	local result = math.floor( x*shift + 0.5 ) / shift
	return result
end

function OnChange(selectedTab)
	if selectedTab == tabZombies then 
		if openedZKillers == false then
			triggerServerEvent ( "ShowTopZKillers", localPlayer)
			openedZKillers = true
		end
	elseif selectedTab == tabAlive then
		if openedATime == false then
			triggerServerEvent ( "ShowTopATime", localPlayer)
			openedATime = true
		end
	end	
end
addEventHandler("onClientGUITabSwitched", root, OnChange)

function showZkillersC(data)
	killerTable = data
	killerCounter = 1
	for id, killer in pairs(killerTable) do
		local row = guiGridListAddRow ( zombiesScreenGridList)
		guiGridListSetItemText ( zombiesScreenGridList, row, 1, killerCounter, false, true )
		guiGridListSetItemText ( zombiesScreenGridList, row, 2, killer.nick, false, false )
		guiGridListSetItemText ( zombiesScreenGridList, row, 3, killer.kills, false, true )
		killerCounter = killerCounter +1
	end
end
addEvent("Leaderboard:showZkillersC", true)
addEventHandler("Leaderboard:showZkillersC", root, showZkillersC)

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function formatTimeFromMinutes(value)
	if value then
		local hours = math.floor(value/60)
		local minutes = math.round(((value/60) - math.floor(value/60))*100/(100/60))
		if minutes < 10 then minutes = "0"..minutes end
		value = hours..":"..minutes
		return value
	end
	return false
end

function ShowTopATimeC(data)
	killerTable = data
	killerCounter = 1
	for id, killer in pairs(killerTable) do
		local row = guiGridListAddRow ( aliveScreenGridList)
		guiGridListSetItemText ( aliveScreenGridList, row, 1, killerCounter, false, true )
		guiGridListSetItemText ( aliveScreenGridList, row, 2, killer.nick, false, false )
		guiGridListSetItemText ( aliveScreenGridList, row, 3, formatTimeFromMinutes(killer.alive), false, true )
		killerCounter = killerCounter +1
	end
end
addEvent("Leaderboard:ShowTopATimeC", true)
addEventHandler("Leaderboard:ShowTopATimeC", root, ShowTopATimeC)

addEventHandler("onClientMouseEnter",root,function()
	 if source == closeBTN then
		playSFX("feet", 5, 2, false)
        guiSetProperty(closeBTN, "ImageColours", "tl:FF"..hl.."tr:FF"..hl.."bl:FF"..hl.."br:FF"..hl)
	end
end)

addEventHandler("onClientMouseLeave",root,function()
	if source == closeBTN then
		guiSetProperty(closeBTN, "ImageColours", "tl:FF"..hl2.."tr:FF"..hl2.."bl:FF"..hl2.."br:FF"..hl2)
	end 
end)

function closeGUI()
	destroyElement(panel)
	showCursor(false)
	opened = false
	openedZKillers = false
	openedATime = false
end

function bind()
	if opened == false then
		showCursor(true)
		triggerServerEvent ( "ShowTopKillers", localPlayer)
		opened = true
	else
		closeGUI()
	end 
end
bindKey (openKey, "down", bind)