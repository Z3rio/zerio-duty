if ESX == nil then
	TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
end

-- EXPORTS
function getDuty(identifier)
	local Player = ESX.GetPlayerFromIdentifier(identifier)

	if Player then
		return Player.get("onDuty")
	else
		return false
	end
end
exports("getDuty", getDuty)

function setDuty(identifier, newValue)
	local Player = ESX.GetPlayerFromIdentifier(identifier)

	if Player then
		if type(newValue) == "boolean" then
			Player.set("onDuty", newValue)

			TriggerServerEvent("zerio-duty:server:dutyChange", Player.source, newValue)
			TriggerClientEvent("zerio-duty:client:dutyChange", Player.source, newValue)

			if newValue then
				TriggerClientEvent("esx:showNotification", Player.source, "You are now on duty")
			else
				TriggerClientEvent("esx:showNotification", Player.source, "You are now off duty")
			end
		else
			error("New value for setDuty must be a boolean")
		end
	end
end
exports("setDuty", setDuty)

-- CALLBACKS
ESX.RegisterServerCallback("zerio-duty:server:getDuty", function(source, cb)
	local Player = ESX.GetPlayerFromId(source)

	if Player then
		cb(Player.get("onDuty"))
	else
		cb(false)
	end
end)

-- EVENTS
RegisterNetEvent("onResourceStart")
AddEventHandler("onResourceStart", function()
	for idx,plr in pairs(ESX.GetExtendedPlayers()) do
		if plr.get("onDuty") == nil then
			plr.set("onDuty", Config.DefaultDuty)
		end
	end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(source, plr, isNew)
	if plr.get("onDuty") == nil then
		plr.set("onDuty", Config.DefaultDuty)
	end
end)
