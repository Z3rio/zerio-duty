![Thumbnail](https://user-images.githubusercontent.com/54480523/200033540-4105e4e7-f6a7-45b7-b084-47ab8a53b21e.png)

# Zerio Duty
This is a Duty system made for ESX, this is pretty much a library with all the functions and such.<br>
Making it very easy to link this to any UI or such.
<br><br>
The upside to this duty system is that in other duty systems it changes the actual job name which messes up other scripts, example: when off duty your job name is "offduty", when on duty your job name is "police".
<br><br>
**This is not how this script works**, this script does not change your job name, it simply uses player metadata.

# Contribution
If you want to contribute to this project, then please do. We are open to any help at all, simply open a PR (Pull Request) on the Github Repository, or open an Issue on the Github Repository.

# Exports

## Server

- getDuty(identifier<string>)
	> Gets the current duty status of the player, returns a boolean (true / false). 
	> If the player doesnt exist / isnt online, then false will be returned.
- setDuty(identifier<string>, newValue<boolean>)
	> Updates the duty status for the inputted player. Doesn't return anything.
- getPlayersOnDuty(jobName<string>)
	> Returns a table with all players on duty for a specific job. This is based on ESX.GetExtendedPlayers, therefore the players returned are actual player objects / ESX players.
- getPlayersOffDuty(jobName<string>)
	> Returns a table with all players that are off duty for a specific job. This is based on ESX.GetExtendedPlayers, therefore the players returned are actual player objects / ESX players.

## Client

- getDuty()
	> Gets the duty status of the local player / client, returns a boolean (true / false)

# Events

## Server
- zerio-duty:server:dutyChange
  > Gets triggered when a players duty value is changed. It passes through the source of the player and also the new duty value.

- zerio-duty:server:toggleDuty
  > Toggles the duty for the player that triggered this event. (Has to be triggered from the client)
  > Works great to be triggered from a "duty marker" / duty change function in a job script.

## Client
- zerio-duty:client:dutyChange
  > This gets triggered when the local player / clients duty value gets changed. Passes through the new duty value.

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
RegisterCommand("changeduty", function(source)
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

```lua
RegisterCommand("changeduty", function()
	TriggerServerEvent("zerio-duty:server:toggleDuty")
end)
```

## ESX Paycheck Integration
(es_extended/server/paycheck.lua)
Changed lines: line 11
```lua
function StartPayCheck()
  CreateThread(function()
    while true do
      Wait(Config.PaycheckInterval)
      local xPlayers = ESX.GetExtendedPlayers()
      for i = 1, #(xPlayers) do
        local xPlayer = xPlayers[i]
        local job = xPlayer.job.grade_name
        local salary = xPlayer.job.grade_salary

        if salary > 0 and exports["zerio-duty"]:getDuty(xPlayer.identifier) then
          if job == 'unemployed' then -- unemployed
            xPlayer.addAccountMoney('bank', salary, "Welfare Check")
            TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_help', salary),
              'CHAR_BANK_MAZE', 9)
          elseif Config.EnableSocietyPayouts then -- possibly a society
            TriggerEvent('esx_society:getSociety', xPlayer.job.name, function(society)
              if society ~= nil then -- verified society
                TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
                  if account.money >= salary then -- does the society money to pay its employees?
                    xPlayer.addAccountMoney('bank', salary, "Paycheck")
                    account.removeMoney(salary)

                    TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, TranslateCap('bank'), TranslateCap('received_paycheck'),
                      TranslateCap('received_salary', salary), 'CHAR_BANK_MAZE', 9)
                  else
                    TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, TranslateCap('bank'), '', TranslateCap('company_nomoney'), 'CHAR_BANK_MAZE', 1)
                  end
                end)
              else -- not a society
                xPlayer.addAccountMoney('bank', salary, "Paycheck")
                TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_salary', salary),
                  'CHAR_BANK_MAZE', 9)
              end
            end)
          else -- generic job
            xPlayer.addAccountMoney('bank', salary, "Paycheck")
            TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_salary', salary),
              'CHAR_BANK_MAZE', 9)
          end
        end
      end
    end
  end)
end
```
