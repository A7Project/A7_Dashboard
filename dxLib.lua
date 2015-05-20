---------------- Tab
local Tabs = {
Data = {},
Hover = {},
}

function dxCreateTab(text,x,y,w,h,r,g,b)
	local theTab = createElement("dxTab")
	Tabs.Hover[theTab] = false
	Tabs.Data[theTab] = {text=text,x=x,y=y,w=w,h=h,r=r or 255,g=g or 255,b=b or 255,alpha = 100}
	return theTab
end

function dxDrawTab(element,text,x,y,w,h,r,g,b)
	if isElement(element) and getElementType(element) == "dxTab" then
		local data = Tabs.Data[element]
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
			Tabs.Hover[element] = true
			alpha = math.min(170,alpha+10)
			else
			Tabs.Hover[element] = false
			alpha = math.max(100,alpha-5)
		end
		dxDrawRectangle(x,y,w,h,tocolor(r,g,b,alpha))
		dxDrawText(text,x,y,x+w,y+h,tocolor(r,g,b,255),1,"default-bold","center","center")
		Tabs.Data[element] = {text=text,x=x,y=y,w=w,h=h,r=r,g=g,b=b,alpha = alpha}
	end
end

function dxGetTabText(element)
	if isElement(element) and getElementType(element) == "dxTab" then
		return Tabs.Data[element].text
	end
end

addEventHandler("onClientClick",root,
function(button,state)
	if isDashboardOpen() and button == "left" and state == "down" then
		local tabs = getElementsByType("dxTab")
		if #tabs > 0 then
			for _,tab in ipairs(tabs) do
				local hover = Tabs.Hover[tab]
				if hover == true then
					triggerEvent("onClientdxTabClick",tab,localPlayer)
				end
			end
		end
	end
end
)

---------------- GridList
local GridList = {
Data = {},
Columns = {},
Rows = {},
rAlpha = {}, -- Row alpha
}

function dxCreateGridList(x,y,w,h,searchEdit)
	local theGird = createElement("dxGridList")
	GridList.Data[theGird] = {x=x,y=y,w=w,h=h,searchEdit=searchEdit or nil,hover=false,hoverAlpha=50,scroll=0,maxRows=(math.floor(h/20)-1),rowClicked=0}
	GridList.Columns[theGird] = {}
	GridList.Rows[theGird] = {}
	GridList.rAlpha[theGird] = {}
	return theGird
end

function dxDrawGridList(element)
	if isElement(element) and getElementType(element) == "dxGridList" then
		columns = GridList.Columns[element]
		local rows = GridList.Rows[element]
		local data = GridList.Data[element]
		local x = data.x
		local y = data.y
		local w = data.w
		local h = data.h
		if data.searchEdit then
			local editText = dxEditGetText(data.searchEdit)
			local editText = string.gsub(editText, "([%*%+%?%.%(%)%[%]%{%}%\%/%|%^%$%-])","%%%1")
			if string.len(editText) > 0 then
				local nvm = {}
				for i=1,#rows do
					if string.find(rows[i][1]:lower(),editText:lower()) then
						table.insert(nvm,rows[i])
					end
				end
				rows = nvm
			end
		end
		if isMouseInPosition( x, y, w, h ) then
			GridList.Data[element].hover = true
			GridList.Data[element].hoverAlpha = math.min(80,GridList.Data[element].hoverAlpha+6)
			else
			GridList.Data[element].hover = false
			GridList.Data[element].hoverAlpha = math.max(50,GridList.Data[element].hoverAlpha-3)
		end
		dxDrawRectangle(x,y,w,h,tocolor(255,255,255,GridList.Data[element].hoverAlpha))
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
				-- Row Text
				local posX = x+5
				for _=1,#columns do
				local posY = y+30
				if posX+columns[_].width > x+w then columns[_].width = (x+w) - posX - 5 end
					for i=1+data.scroll,math.min(#rows,data.maxRows)+data.scroll do
						if posY+20 < y+h then
							if type(rows[i]) == "table" then
								if type(rows[i][_]) == "string" then
									dxDrawText(rows[i][_],posX,posY,posX+columns[_].width,posY+20,tocolor(255,255,255,255),1,"default",columns[_].alignX,"center",true)
									posY = posY + 20
								end
							end
						end
					end
				posX = posX + columns[_].width
				end
				-- Row Hover
				local posY = y+30
				for i=1+data.scroll,math.min(#rows,data.maxRows)+data.scroll do
				if not GridList.rAlpha[element][i] then GridList.rAlpha[element][i] = 0 end
					if data.rowClicked == i then
						GridList.rAlpha[element][i] = math.min(80,GridList.rAlpha[element][i]+5)
					else
						if isMouseInPosition( x+5 ,posY ,w-10 ,20 ) then
							if getKeyState("mouse1") then
							GridList.Data[element].rowClicked = i
							triggerEvent("onClientGridListRowSelect",element,localPlayer,i)
							end
							GridList.rAlpha[element][i] = math.min(50,GridList.rAlpha[element][i]+5)
						else
							GridList.rAlpha[element][i] = math.max(0,GridList.rAlpha[element][i]-2)
						end
					end
				dxDrawRectangle(x+5,posY,w-10,20,tocolor(255,255,255,GridList.rAlpha[element][i]))
				posY = posY + 20
				end
			end
		end
	end
end

function dxGridListAddColumn(grid,title,width,alignX)
	if isElement(grid) and getElementType(grid) == "dxGridList" then
		table.insert(GridList.Columns[grid],{title=title,width=width,alignX=alignX or "left"})
		return true
	end
end

function dxGridListAddRow(grid,...)
	if isElement(grid) and getElementType(grid) == "dxGridList" then
		table.insert(GridList.Rows[grid],{...})
		return true
	end
end

function dxGridListClear(grid)
	if isElement(grid) and getElementType(grid) == "dxGridList" then
		GridList.Rows[grid] = {}
		return true
	end
end

function dxGridListScroll(state)
	if isDashboardOpen() and state then
		local grids = getElementsByType("dxGridList")
		for i=1,#grids do
			if GridList.Data[grids[i]].hover == true then
				if #GridList.Rows[grids[i]] > GridList.Data[grids[i]].maxRows then
					if state == "mouse_wheel_up" then
						if GridList.Data[grids[i]].scroll > 0 then
							GridList.Data[grids[i]].scroll = GridList.Data[grids[i]].scroll-1
							outputDebugString("Scrolled up")
						end
					elseif state == "mouse_wheel_down" then
						if GridList.Data[grids[i]].scroll < #GridList.Rows[grids[i]]-GridList.Data[grids[i]].maxRows then
							GridList.Data[grids[i]].scroll = GridList.Data[grids[i]].scroll+1
							outputDebugString("Scrolled down")
						end
					end
				end
			end
		end
	end
end
bindKey("mouse_wheel_up","down",dxGridListScroll)
bindKey("mouse_wheel_down","down",dxGridListScroll)

---------------- Edit

local Edit = {
Data = {},
}

function dxCreateEdit(x,y,w,h,defaultText)
	local theEdit = createElement("dxEdit")
	Edit.Data[theEdit] = {x=x,y=y,w=w,h=h,defaultText=defaultText,hoverAlpha=50,Text="",hover=false,clicked=false,selectAll=false}
	return theEdit
end

function dxDrawEdit(element)
	if isElement(element) and getElementType(element) == "dxEdit" then
	local data = Edit.Data[element]
	local x = data.x or 0
	local y = data.y or 0
	local w = data.w or 0
	local h = data.h or 0
	local text = (string.len(data.Text) > 0 and data.Text) or data.defaultText
	if data.clicked == false then
		if isMouseInPosition( x, y, w, h ) then
			Edit.Data[element].hover = true
			Edit.Data[element].hoverAlpha = math.min(80,Edit.Data[element].hoverAlpha+6)
		else
			Edit.Data[element].hover = false
			Edit.Data[element].hoverAlpha = math.max(50,Edit.Data[element].hoverAlpha-3)
		end
	else
		Edit.Data[element].hover = false
		Edit.Data[element].hoverAlpha = math.min(80,Edit.Data[element].hoverAlpha+6)
	end
	dxDrawRectangle(x,y,w,h,tocolor(255,255,255,Edit.Data[element].hoverAlpha))
		if text == data.defaultText then
			dxDrawText(text,x+5,y,x+w-10,y+h,tocolor(200,200,200,200),1,"default","left","center",true)
		else
			dxDrawText(text,x+5,y,x+w-10,y+h,tocolor(255,255,255,255),1,"default","left","center",true)
		end
		if data.selectAll == true then
		local tW = dxGetTextWidth(text)
		dxDrawRectangle(x+5,y,tW,h,tocolor(255,255,255,50))
		end
	dxDrawEmptyRec(x,y,w,h,tocolor(255,255,255,255),1)
	end
end

function dxEditGetText(edit)
	if isElement(edit) and getElementType(edit) == "dxEdit" then
		return Edit.Data[edit].Text
	end
end

addEventHandler("onClientClick",root,
function(button,state)
	if isDashboardOpen() and button == "left" and state == "down" then
		local edit = getElementsByType("dxEdit")
		if #edit > 0 then
			for _,editt in ipairs(edit) do
				local hover = Edit.Data[editt].hover
				if hover == true then
					guiSetInputEnabled(true)
					Edit.Data[editt].clicked = true
					triggerEvent("onClientdxEditClick",editt,localPlayer)
				elseif hover == false then
					guiSetInputEnabled(false)
					Edit.Data[editt].clicked = false
				end
			end
		end
	end
end
)

function addCharacterToEdit(character)
	if isDashboardOpen() then
		local edit = getElementsByType("dxEdit")
		for i=1,#edit do	
			if Edit.Data[edit[i]].clicked == true then
				if Edit.Data[edit[i]].selectAll == true then
					Edit.Data[edit[i]].selectAll = false
					Edit.Data[edit[i]].Text = ""
				end
				Edit.Data[edit[i]].Text = Edit.Data[edit[i]].Text..character
			end
		end
	end
end
addEventHandler("onClientCharacter", getRootElement(), addCharacterToEdit)

function backspace(key,sm)
	if isDashboardOpen() and sm then
		local edit = getElementsByType("dxEdit")
		for i=1,#edit do	
			if Edit.Data[edit[i]].clicked == true then
				if string.len(Edit.Data[edit[i]].Text) > 0 and key == "backspace" then
					if Edit.Data[edit[i]].selectAll == false then
						Edit.Data[edit[i]].Text = string.sub(Edit.Data[edit[i]].Text,1,string.len(Edit.Data[edit[i]].Text)-1)
					else
						Edit.Data[edit[i]].selectAll = false
						Edit.Data[edit[i]].Text = ""
					end
				elseif getKeyState("lctrl") and key == "a" or getKeyState("rctrl") and key == "a" then
					Edit.Data[edit[i]].selectAll = not Edit.Data[edit[i]].selectAll
				end
			end
		end
	end
end
addEventHandler("onClientKey", root, backspace)
