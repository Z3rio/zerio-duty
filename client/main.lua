Citizen.CreateThread(function()
    if ESX == nil then
        while ESX == nil do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Citizen.Wait(250)
        end
    end

    -- EXPORTS
    function getDuty()
        local retVal = promise.new()

        ESX.TriggerServerCallback("zerio-duty:server:getDuty", function(result)
            retVal:resolve(result)
        end)

        Citizen.Await(retVal)

        return retVal.value
    end
    exports("getDuty", getDuty)

    function getDutyTime()
        local retVal = promise.new()
        
        ESX.TriggerServerCallback("zerio-duty:server:getDutyTime", function(result)
            retVal:resolve(result)
        end)

        Citizen.Await(retVal)

        return retVal.value
    end
    exports("getDutyTime", getDutyTime)
end)
