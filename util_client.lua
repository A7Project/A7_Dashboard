function dxDrawEmptyRec(startX, startY, endX, endY, color, width, postGUI)
	dxDrawLine ( startX, startY, startX+endX, startY, color, width, postGUI )
	dxDrawLine ( startX, startY, startX, startY+endY, color, width, postGUI )
	dxDrawLine ( startX, startY+endY, startX+endX, startY+endY,  color, width, postGUI )
	dxDrawLine ( startX+endX, startY, startX+endX, startY+endY, color, width, postGUI )
end

function dxDrawText_(text,x,y,w,h,color,scale,font,alignX,alignY,clip,wordBreak,postGUI,colorCoded)
	dxDrawText(text,x,y,x + w,y + h,color,scale,font,alignX,alignY,clip or false,wordBreak or false,postGUI or true,colorCoded or true)
end

function isMouseInPosition ( x, y, width, height )
    if ( not isCursorShowing ( ) ) then
        return false
    end
 
    local sx, sy = guiGetScreenSize ( )
    local cx, cy = getCursorPosition ( )
    local cx, cy = ( cx * sx ), ( cy * sy )
    if ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) then
        return true
    else
        return false
    end
end

function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end

function updateGridlist(grid,thing)
	if isElement(grid) and getElementType(grid) == "dxGridList" then
		if thing == "news" then
			local xml = xmlLoadFile("xml/News.xml")
			for k,v in ipairs(xmlNodeGetChildren(xml)) do
			local title = xmlNodeGetAttribute(v,"Title")
			local by = xmlNodeGetAttribute(v,"By")
			local datee = xmlNodeGetAttribute(v,"Date")
			dxGridListAddRow(grid,title,by,datee)
			end
			xmlUnloadFile(xml)
		elseif thing == "members" then
			local xml = xmlLoadFile("xml/Memebers.xml")
			for k,v in ipairs(xmlNodeGetChildren(xml)) do
			local name = xmlNodeGetAttribute(v,"Name")
			local country = xmlNodeGetAttribute(v,"Country")
			local rank = xmlNodeGetAttribute(v,"Rank")
			dxGridListAddRow(grid,name,country,rank)
			end
			xmlUnloadFile(xml)
		elseif thing == "clanwars" then
			local xml = xmlLoadFile("xml/Clanwars.xml")
			for k,v in ipairs(xmlNodeGetChildren(xml)) do
			local typee = xmlNodeGetAttribute(v,"Type")
			local vs = xmlNodeGetAttribute(v,"Vs")
			local score = xmlNodeGetAttribute(v,"Score")
			local result = xmlNodeGetAttribute(v,"Result")
			dxGridListAddRow(grid,typee,vs,score,result)
			end
			xmlUnloadFile(xml)
		end
	end
end

function getMaps(player)
	if player and isElement(player) then
	triggerServerEvent("Mapshop:clientWantMaps",localPlayer)
	end
end

function setMapsGridList(mapsTable)
	if mapsTable and type(mapsTable) == "table" then
	dxGridListClear(maps)
		for _,map in ipairs(mapsTable) do
			dxGridListAddRow(maps,map)
		end
	end
end
addEvent("Mapshop:sendMapsToClient",true)
addEventHandler("Mapshop:sendMapsToClient",root,setMapsGridList)

addEventHandler("onClientResourceStart",resourceRoot,
function()
getMaps(localPlayer)
end
)
