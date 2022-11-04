# Zerio Duty
This is a Duty system made for ESX, this is pretty much a library with all the functions and such.<br>
Making it very easy to link this to any UI or such.<br>
The upside to this duty system is that in other duty systems it changes the actual job name which messes up other scripts, example: when off duty your job name is "offduty", when on duty your job name is "police".<br>
**This is not how this script works**, this script does not change your job name, it simply uses player metadata.

# Contribution
If you want to contribute to this project, then please do. We are open to any help at all, simply open a PR (Pull Request) on the Githu Repository, or open an Issue on the Github Repository.

# Exports

## Server

- getDuty(identifier<string>)
	> Gets the current duty status of the player, returns a boolean (true / false). 
	> If the player doesnt exist / isnt online, then false will be returned.
- setDuty(identifier<string>, newValue<boolean>)
	> Updates the duty status for the inputted player. Doesn't return anything.

## Client

- getDuty()
	> Gets the duty status of the local player / client, returns a boolean (true / false)

# Examples

## Server:
```lua
RegisterCommand("duty", function(source)
	local Player = ESX.GetPlayerFromId(source)

	if Player then
		local onduty = exports["zerio-duty"]:getDuty(Player.identifier)
		local str = "You are on duty"
		
		if onduty == false then
				str = "You are not on duty"
		end

		TriggerClientEvent("chat:addMessage", Player.source, {
				color = {255, 255, 255},
				multiline = true,
				args = {"Zerio-Duty", str}
		})
	end
end)
```

```lua
RegisterCommand("setduty", function(source)
	local Player = ESX.GetPlayerFromId(source)

	if Player then
		local duty = exports["zerio-duty"]:getDuty(Player.identifier)
		exports["zerio-duty"]:setDuty(Player.identifier, not duty)
	end
end)
```

## Client:
```lua
RegisterCommand("duty", function()
		local onduty = exports["zerio-duty"]:getDuty()
		local str = "You are on duty"
		
		if onduty == false then
				str = "You are not on duty"
		end

		TriggerEvent("chat:addMessage", {
				color = {255, 255, 255},
				multiline = true,
				args = {"Zerio-Duty", str}
		})
end)
```
