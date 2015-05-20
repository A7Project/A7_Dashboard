function getRaceMaps(player)
	local client = player or client
	local mapsTable = {}
	local maps = call(getResourceFromName("mapmanager"), "getMapsCompatibleWithGamemode" , getResourceFromName("race"))
	for k,res in ipairs(maps) do
		table.insert(mapsTable,getResourceInfo(res,"name") or getResourceName(res))
	end
	triggerClientEvent(client,"Mapshop:sendMapsToClient",client,mapsTable)
end
addEvent("Mapshop:clientWantMaps",true)
addEventHandler("Mapshop:clientWantMaps",root,getRaceMaps)

addCommandHandler("refreshMaps",
function (player)
	if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)),aclGetGroup("Admin")) then
	for k,v in ipairs(getElementsByType("player")) do
	getRaceMaps(v)
	end
	outputChatBox("[Map shop] #FFFFFFMaps has been refreshed by "..getPlayerName(player),root,0,204,204,true)
	end
end
)
