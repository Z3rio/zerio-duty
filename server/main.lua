if ESX == nil then
	TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
end

-- VARIABLES
local timers = {}

-- FUNCTIONS
function formatDate(date)
	local retValStr = ""

	local hours = math.floor((date / 60 / 60) + 0.5)
	local minutes = math.floor((date / 60) + 0.5 - (hours * 60))
	local seconds = math.floor(date + 0.5 - (minutes * 60 + (hours * 60 * 60)))

	if seconds > 0 then
		if retValStr ~= "" then
			retValStr = retValStr .. " & "
		end
		retValStr = retValStr .. seconds .. " second"
		if seconds > 1 then
			retValStr = retValStr .. "s"
		end
	end

	if minutes > 0 then
		if retValStr ~= "" then
			retValStr = retValStr .. " & "
		end
		retValStr = retValStr .. minutes .. " minute"
		if minutes > 1 then
			retValStr = retValStr .. "s"
		end
	end

	if hours > 0 then
		if retValStr ~= "" then
			retValStr = retValStr .. " & "
		end
		retValStr = retValStr .. hours .. " hour"
		if hours > 1 then
			retValStr = retValStr .. "s"
		end
	end

	return retValStr
end

function DiscordLog(title, message, fields)
	PerformHttpRequest(Config.DiscordLogs.link, function(err, text, headers) end, 'POST', json.encode({
		username = Config.DiscordLogs.username,
		embeds = {
			{
				["color"] = Config.DiscordLogs.color,
				["author"] = {
					["name"] = Config.DiscordLogs.communityName,
					["icon_url"] = Config.DiscordLogs.avatar,
				},
				["fields"] = fields,
				["title"] = title,
				["description"] = message,
				["footer"] = {
					["text"] = "2022 © Zerio#0880 • " .. os.date("%x %X %p"),
				}
			}
		},
		avatar_url = Config.DiscordLogs.avatar
	}), {['Content-Type'] = 'application/json'})
end

function getName(plr)
	if plr.getName() ~= nil then
		return plr.getName()
	else
		Functions.ExecuteSQL("SELECT * FROM `users` WHERE `identifier` = '" .. plr.identifier .. "'", function(result)
			if result and result[1] then
				return result[1].firstname .. " " .. result[1].lastname
			else
				return ""
			end
		end)
	end
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

function getDutyTime(identifier)
	local Player = ESX.GetPlayerFromIdentifier(identifier)
	
	if Player then
		if Player.get("onDuty") and timers[identifier] then
			return timers[identifier]
		else
			return 0
		end
	else
		return 0
	end
end
exports("getDutyTime", getDutyTime)

function setDuty(identifier, newValue, loggingOff, hideNotification)
	local Player = ESX.GetPlayerFromIdentifier(identifier)

	if Player then
		if type(newValue) == "boolean" then
			if Config.DiscordLogs.enabled then
				if newValue then
					timers[identifier] = os.time()
				else
					if timers[identifier] ~= nil then
						local name = getName(Player)

						DiscordLog("Zerio-Duty - Logs", name .. " (`" .. identifier .. "`) was on duty for " .. formatDate(os.difftime(os.time(), timers[identifier])), {
							{
								["name"] = "Name",
								["value"] = name,
								["inline"] = true
							},
							{
								["name"] = "Identifier",
								["value"] = identifier,
								["inline"] = true
							},
							{
								["name"] = "Job",
								["value"] = Player.job.label .. " " .. Player.job.grade_label,
								["inline"] = true
							},

							{
								["name"] = "Time Started",
								["value"] = os.date("%x %X %p", timers[identifier]),
								["inline"] = true
							},
							{
								["name"] = "Time Stopped",
								["value"] = os.date("%x %X %p"),
								["inline"] = true
							}
						})
						timers[identifier] = nil
					end
				end
			end

			if loggingOff ~= true then
				Player.set("onDuty", newValue)

				TriggerEvent("zerio-duty:server:dutyChange", Player.source, newValue)
				TriggerClientEvent("zerio-duty:client:dutyChange", Player.source, newValue)

				if hideNotification ~= true then
					if newValue then
						TriggerClientEvent("esx:showNotification", Player.source, "You are now on duty")
					else
						TriggerClientEvent("esx:showNotification", Player.source, "You are now off duty")
					end
				end
			end
		else
			error("New value for setDuty must be a boolean")
		end
	end
end
exports("setDuty", setDuty)

function getPlayersOnDuty(jobName)
	local retVal = {}

	if jobName and type(jobName) == "string" then
		for idx,plr in pairs(ESX.GetExtendedPlayers("job",jobName)) do
			if plr.get("onDuty") == true then
				table.insert(retVal, plr)
			end
		end
	else
		error("Either no job name is passed through, or it is not a string")
	end

	return retVal
end
exports("getPlayersOnDuty", getPlayersOnDuty)

function getPlayersOffDuty(jobName)
	local retVal = {}
	
	if jobName and type(jobName) == "string" then
		for idx,plr in pairs(ESX.GetExtendedPlayers("job",jobName)) do
			if plr.get("onDuty") == false then
				table.insert(retVal, plr)
			end
		end
	else
		error("Either no job name is passed through, or it is not a string")
	end

	return retVal
end
exports("getPlayersOffDuty", getPlayersOffDuty)

-- CALLBACKS
ESX.RegisterServerCallback("zerio-duty:server:getDuty", function(source, cb)
	local Player = ESX.GetPlayerFromId(source)

	if Player then
		cb(Player.get("onDuty"))
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback("zerio-duty:server:getDutyTime", function(source, cb)
	local Player = ESX.GetPlayerFromId(source)

	return exports["zerio-duty"]:getDutyTime(Player.identifier)
end)

-- EVENTS
RegisterNetEvent("zerio-duty:server:toggleDuty")
AddEventHandler("zerio-duty:server:toggleDuty", function()
	local Player = ESX.GetPlayerFromId(source)

	if Player then
		local current = Player.get("onDuty")

		exports["zerio-duty"]:setDuty(Player.identifier, not current)
	end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(source, plr, isNew)
	if plr.get("onDuty") == nil then
		exports["zerio-duty"]:setDuty(plr.identifier, Config.DefaultDuty, nil, true)
	end
end)

RegisterNetEvent("esx:playerDropped")
AddEventHandler('esx:playerDropped', function(source)
  local plr = ESX.GetPlayerFromId(source)
	exports["zerio-duty"]:setDuty(plr.identifier, false, true, nil)
end)

-- ON START
for idx,plr in pairs(ESX.GetExtendedPlayers()) do
	if plr.get("onDuty") == nil then
		exports["zerio-duty"]:setDuty(plr.identifier, Config.DefaultDuty, nil, true)
	end
end
