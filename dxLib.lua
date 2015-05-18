---------------- Tab
function dxCreateTab(text,x,y,w,h,r,g,b)
	local theTab = createElement("dxTab")
	setElementData(theTab,"hover",false)
	setElementData(theTab,"data",{text=text,x=x,y=y,w=w,h=h,r=r or 255,g=g or 255,b=b or 255,alpha = 100},false)
	return theTab
end

function dxDrawTab(element,text,x,y,w,h,r,g,b)
	if isElement(element) and getElementType(element) == "dxTab" then
		local data = getElementData(element,"data")
		local text = text or data.text
		local x = x or data.x
		local y = y or data.y
		local w = w or data.w
		local h = h or data.h
		local r = r or data.r
		local g = g or data.g
		local b = b or data.b
		local alpha = data.alpha
		if isMouseInPosition( x, y, w, h ) then
			setElementData(element,"hover",true)
			alpha = math.min(170,alpha+10)
			else
			setElementData(element,"hover",false)
			alpha = math.max(100,alpha-5)
		end
		dxDrawRectangle(x,y,w,h,tocolor(r,g,b,alpha))
		dxDrawText(text,x,y,x+w,y+h,tocolor(r,g,b,255),1,"default-bold","center","center")
		setElementData(element,"data",{text=text,x=x,y=y,w=w,h=h,r=r,g=g,b=b,alpha = alpha},false)
	end
end

addEventHandler("onClientClick",root,
function(button,state)
	if isDashboardOpen() and button == "left" and state == "down" then
		local tabs = getElementsByType("dxTab")
		if #tabs > 0 then
			for _,tab in ipairs(tabs) do
				local hover = getElementData(tab,"hover")
				if hover == true then
					triggerEvent("onClientdxTabClick",tab,localPlayer)
				end
			end
		end
	end
end
)
----------------------

local rAlpha = {} -- Row alpha

function dxCreateGridList(x,y,w,h)
	local theGird = createElement("dxGridList")
	local theRenderTarget = dxCreateRenderTarget(w,h-30,true)
	setElementData(theGird,"data",{x=x,y=y,w=w,h=h,rT=theRenderTarget},false)
	setElementData(theGird,"columns",{},false)
	setElementData(theGird,"rows",{},false)
	rAlpha[theGird] = {}
	return theGird
end

function dxDrawGridList(element)
	if isElement(element) and getElementType(element) == "dxGridList" then
		local columns = getElementData(element,"columns")
		local rows = getElementData(element,"rows")
		local data = getElementData(element,"data")
		local x = data.x
		local y = data.y
		local w = data.w
		local h = data.h
		local rT = data.rT
		dxDrawRectangle(x,y,w,h,tocolor(255,255,255,50))
		dxDrawRectangle(x,y+25,w,1,tocolor(255,255,255,255))
		if #columns > 0 then
			local posX = x+5
			--- Columns
			for _,column in ipairs(columns) do
				if posX+column.width > x+w then column.width = (x+w) - posX - 5 end
				dxDrawText(column.title,posX,y,posX+column.width,y+25,tocolor(255,255,255,255),1,"default",column.alignX,"center",true)
				posX = posX + column.width
			end
			--- Rows
			if #rows > 0 then
				dxSetRenderTarget(rT)
				-- Row Text
				local posX = 5
				for _=1,#columns do
				local posY = 0
				if posX+columns[_].width > x+w then columns[_].width = (x+w) - posX - 5 end
					for i=1,#rows do
						if type(rows[i]) == "table" then
							if type(rows[i][_]) == "string" then
								dxDrawText(rows[i][_],posX,posY,posX+columns[_].width,posY+20,tocolor(255,255,255,255),1,"default",columns[_].alignX,"center",true)
								posY = posY + 20
							end
						end
					end
				posX = posX + columns[_].width
				end
				-- Row Hover
				local posY = 0
				for i=1,#rows do
				if not rAlpha[element][i] then rAlpha[element][i] = 0 end
					if isMouseInPosition( x+5 ,posY ,w-10 ,20 ) then
						rAlpha[element][i] = math.min(50,rAlpha[element][i]+5)
					else
						rAlpha[element][i] = math.max(0,rAlpha[element][i]-2)
					end
				dxDrawRectangle(x+5,posY,w-10,20,tocolor(255,255,255,rAlpha[element][i]))
				posY = posY + 20
				end
				dxSetRenderTarget()
			end
		end
		dxDrawImage(x,y+30,w,h-30,rT)
	end
end

function dxGridListAddColumn(grid,title,width,alignX)
	if isElement(grid) and getElementType(grid) == "dxGridList" then
		local columns = getElementData(grid,"columns")
		table.insert(columns,{title=title,width=width,alignX=alignX or "left"})
		setElementData(grid,"columns",columns,false)
		return true
	end
end

function dxGridListAddRow(grid,...)
	if isElement(grid) and getElementType(grid) == "dxGridList" then
		local rows = getElementData(grid,"rows")
		table.insert(rows,{...})
		setElementData(grid,"rows",rows,false)
		return true
	end
end
