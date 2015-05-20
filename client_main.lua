local sX,sY = guiGetScreenSize()
--local sX,sY = 800,600
Dashboard = {
	Main = {
			rainbow = true,
			bR = 255, bG = 100, bB = 0, -- {bR = 255, bG = 165, bB = 0,},{bR = 0, bG = 204, bB = 204,}
			shader = dxCreateShader("shaders/shader.fx"),
			renderTarget = dxCreateRenderTarget(sX,sY),
			openTick = 0,
			something = -180,
			stats = "close",
			closed = true,
			-- Tabs
			taps = {"Main","Statistic","Map Shop","Garage","Settings"},
			tapsElements = {},
			currentTab = "Main",
			--
			},
	Mapshop = {
			mapInfo = {"Map name","Author","Last time played","Times played","Hunters","Likes"},
			miAlpha = 50,
			},
}

function startDashboard()
	createTabs()
	
	--- Main
		news = dxCreateGridList(20,sY*(80/720),sX-40,sY*(300/720))
			dxGridListAddColumn(news,"Title",sX*(950/1280),"left")
			dxGridListAddColumn(news,"By",sX*(100/1280),"center")
			dxGridListAddColumn(news,"Date",sX*(180/1280),"center")
			updateGridlist(news,"news")
		members = dxCreateGridList(20,sY*((80+300+10)/720),((sX-40)/2)-5,sY*(300/720))
			dxGridListAddColumn(members,"Name",sX*(200/1280),"left")
			dxGridListAddColumn(members,"Country",sX*(200/1280),"center")
			dxGridListAddColumn(members,"Rank",sX*(200/1280),"center")
			updateGridlist(members,"members")
		clanwars = dxCreateGridList((sX-40)-((sX-40)/2)+25,sY*((80+300+10)/720),((sX-40)/2)-5,sY*(300/720))
			dxGridListAddColumn(clanwars,"Type",sX*(100/1280),"left")
			dxGridListAddColumn(clanwars,"VS",sX*(200/1280),"left")
			dxGridListAddColumn(clanwars,"Score",sX*(100/1280),"center")
			dxGridListAddColumn(clanwars,"Result",sX*(200/1280),"center")
			updateGridlist(clanwars,"clanwars")
	--
	--- Map shop
		mapsEdit = dxCreateEdit(20,(sY*((80+300+10)/720)),sX-40,25,"Map name...")
		maps = dxCreateGridList(20,sY*(80/720),sX-40,sY*(300/720),mapsEdit)
			dxGridListAddColumn(maps,"Map name",sX*(501/1280),"left")
	--
end
addEventHandler("onClientResourceStart",resourceRoot,startDashboard)

function stopDashboard()

end
addEventHandler("onClientResourceStop",resourceRoot,startDashboard)

function dashboardRender()
	if Dashboard.Main.rainbow == true then
	
	end
	dxSetRenderTarget(Dashboard.Main.renderTarget)
	dxDrawRectangle(0,0,sX,sY,tocolor(Dashboard.Main.bR,Dashboard.Main.bG,Dashboard.Main.bB,255))
	dxDrawRectangle(20,sY*(50/720),sX-40,2,tocolor(255,255,255,255))
	dxDrawRectangle(sX-20-75,sY*(50/720)-25,75,25)
	dxSetBlendMode("modulate_add")
	dxDrawText("A7D 1.0.0",sX-20-75,sY*(50/720)-25,(sX-20-75)+75,(sY*(50/720)-25)+25,tocolor(Dashboard.Main.bR,Dashboard.Main.bG,Dashboard.Main.bB,255),1.2,"default","center","center")
	dxSetBlendMode("blend")
	drawTabs()
	
	if Dashboard.Main.currentTab == "Main" then
		dxDrawGridList(news)
		dxDrawGridList(members)
		dxDrawGridList(clanwars)
	elseif Dashboard.Main.currentTab == "Map Shop" then
		dxDrawGridList(maps)
		dxDrawEdit(mapsEdit)
			if isMouseInPosition( (sX/2)-(500/2),sY*((80+300+10+10)/720)+25,sX*(500/1280),sY*((300-10)/720)-25 ) then
				Dashboard.Mapshop.miAlpha = math.min(80,Dashboard.Mapshop.miAlpha+6)
			else
				Dashboard.Mapshop.miAlpha = math.max(50,Dashboard.Mapshop.miAlpha-3)
			end
		dxDrawRectangle((sX/2)-(500/2),sY*((80+300+10+10)/720)+25,sX*(500/1280),sY*((300-10)/720)-25,tocolor(255,255,255,Dashboard.Mapshop.miAlpha))
		local sizeY = (sY*((300-10)/720)-25)/#Dashboard.Mapshop.mapInfo
		local posY = sY*((80+300+10+10)/720)+25
		for i=1,#Dashboard.Mapshop.mapInfo do
			local tH = dxGetTextWidth(Dashboard.Mapshop.mapInfo[i]..":")
			dxDrawText(Dashboard.Mapshop.mapInfo[i]..":",(sX/2)-((sX*(500/1280))/2)+5,posY,(sX/2)-((sX*(500/1280))/2)+(tH),posY+sizeY,tocolor(255,255,255,255),1,"default","left","center",false)
			dxDrawText(" ".."ALw7sH!",(sX/2)-((sX*(500/1280))/2)+5+tH,posY,(sX/2)-((sX*(500/1280))/2)+(sX*(500/1280)),posY+sizeY,tocolor(255,255,255,255),1,"default","left","center",true)
			posY = posY + sizeY
		end
	end
	dxSetRenderTarget()
	
	if Dashboard.Main.stats == "open" then
		local tick = getTickCount() - Dashboard.Main.openTick
		local progress = math.min(tick/1000,1)
		rot = interpolateBetween(Dashboard.Main.something,0,0,0,0,0,progress,"OutQuad")
		Dashboard.Main.something = rot
	elseif Dashboard.Main.stats == "close" then
		local tick = getTickCount() - Dashboard.Main.openTick
		local progress = math.min(tick/1000,1)
		rot = interpolateBetween(Dashboard.Main.something,0,0,-180,0,0,progress,"OutQuad")
		Dashboard.Main.something = rot
		if progress >= 1 then
			outputDebugString("Dashboard: Closed")
			Dashboard.Main.closed = true
			removeEventHandler("onClientRender",root,dashboardRender)
		end
	end
	
	dxSetShaderTransform(Dashboard.Main.shader,0,rot,0,0,1,0,false,0,0,false)
	dxSetShaderValue(Dashboard.Main.shader,"A7D",Dashboard.Main.renderTarget)
	dxSetBlendMode("modulate_add")
	dxDrawImage(0,0,sX,sY,Dashboard.Main.shader)
	dxSetBlendMode("blend")
end

function createTabs()
local posX = 20
	for _,text in ipairs(Dashboard.Main.taps) do
	local tab = dxCreateTab(text,posX,sY*(50/720)-25,75,25)
	table.insert(Dashboard.Main.tapsElements,tab)
	posX = posX + 75
	end
end

function drawTabs()
	for k,v in ipairs(Dashboard.Main.tapsElements) do
	dxDrawTab(v)
	end
end

addEvent("onClientdxTabClick")
addEventHandler("onClientdxTabClick",root,
function()
	Dashboard.Main.currentTab = dxGetTabText(source)
end
)

function toggleDashboard()
	if Dashboard.Main.stats == "close" then
		if Dashboard.Main.closed == true then
			addEventHandler("onClientRender",root,dashboardRender)
			Dashboard.Main.closed = false
		end
		Dashboard.Main.openTick = getTickCount()
		Dashboard.Main.stats = "open"
		showCursor(true)
		showChat(false)
	else
		Dashboard.Main.openTick = getTickCount()
		Dashboard.Main.stats = "close"
		showCursor(false)
		showChat(true)
	end
end
bindKey("F7","down",function() toggleDashboard() end)

function isDashboardOpen()
	if Dashboard.Main.stats == "open" then
	return true
	else
	return false
	end
end
