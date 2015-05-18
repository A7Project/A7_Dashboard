local sX,sY = guiGetScreenSize()
--local sX,sY = 800,600
Dashboard = {
	Main = {
			bR = 0, bG = 204, bB = 204,
			shader = dxCreateShader("shaders/shader.fx"),
			renderTarget = dxCreateRenderTarget(sX,sY),
			openTick = 0,
			something = -180,
			stats = "close",
			closed = true,
			-- Tabs
			taps = {"Main","Map Shop","Garage"},
			tapsElements = {},
			currentTab = "Main",
			--
			},
}

function startDashboard()
	createTabs()
	news = dxCreateGridList(20,sY*(80/720),sX-40,sY*(300/720))
	dxGridListAddColumn(news,"Title",sX*(950/1280),"left")
	dxGridListAddColumn(news,"By",sX*(100/1280),"center")
	dxGridListAddColumn(news,"Date",sX*(180/1280),"center")
	dxGridListAddRow(news,"Just a small update","ALw7sH","17/5/2015")
	dxGridListAddRow(news,"Here we go","ALw7sH","15/5/2015")
	for i=1,10 do
	dxGridListAddRow(news,"Test")
	end
	members = dxCreateGridList(20,sY*((80+300+10)/720),((sX-40)/2)-5,sY*(300/720))
	dxGridListAddColumn(members,"Name",sX*(200/1280),"left")
	dxGridListAddColumn(members,"Country",sX*(200/1280),"center")
	dxGridListAddColumn(members,"Rank",sX*(200/1280),"center")
	dxGridListAddRow(members,"ALw7sH","Bahrain","Founder/Scripter")
	for i=1,20 do
	dxGridListAddRow(members,"Test")
	end
	clanwars = dxCreateGridList((sX-40)-((sX-40)/2)+25,sY*((80+300+10)/720),((sX-40)/2)-5,sY*(300/720))
	dxGridListAddColumn(clanwars,"Type",sX*(100/1280),"left")
	dxGridListAddColumn(clanwars,"VS",sX*(200/1280),"left")
	dxGridListAddColumn(clanwars,"Score",sX*(100/1280),"center")
	dxGridListAddColumn(clanwars,"Result",sX*(200/1280),"center")
	dxGridListAddRow(clanwars,"DM","NILL","17/3","Won")
	dxGridListAddRow(clanwars,"DM","NILL","19/1","Won")
	dxGridListAddRow(clanwars,"DM","NILL","20/0","Won")
	dxGridListAddRow(clanwars,"NEVER LOSE")
end
addEventHandler("onClientResourceStart",resourceRoot,startDashboard)

function stopDashboard()

end
addEventHandler("onClientResourceStop",resourceRoot,startDashboard)

function dashboardRender()
	dxSetRenderTarget(Dashboard.Main.renderTarget)
	dxDrawRectangle(0,0,sX,sY,tocolor(Dashboard.Main.bR,Dashboard.Main.bG,Dashboard.Main.bB,255))
	dxDrawRectangle(20,50,sX-40,2,tocolor(255,255,255,255))
	dxDrawRectangle(sX-20-75,25,75,25)
	dxSetBlendMode("modulate_add")
	dxDrawText("A7D 1.0.0",sX-20-75,25,(sX-20-75)+75,25+25,tocolor(Dashboard.Main.bR,Dashboard.Main.bG,Dashboard.Main.bB,255),1.2,"default","center","center")
	dxSetBlendMode("blend")
	drawTabs()
	
	if Dashboard.Main.currentTab == "Main" then
		dxDrawGridList(news)
		dxDrawGridList(members)
		dxDrawGridList(clanwars)
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
	local tab = dxCreateTab(text,posX,25,75,25)
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
	Dashboard.Main.currentTab = getElementData(source,"data").text
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
	else
		Dashboard.Main.openTick = getTickCount()
		Dashboard.Main.stats = "close"
		showCursor(false)
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

addCommandHandler("nvm",
function(cmd,n)
local R = (255 * (100 - n)) / 100 
local G = (255 * n) / 100
local B = 0
outputChatBox(n.."% - "..RGBToHex(R,G,B),R,G,B,false)
end
)
