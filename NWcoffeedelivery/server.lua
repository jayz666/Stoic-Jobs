--[[
Created by Lama Development
Eveloped by 5M-CodeX
]] --

-- Event handler for starting the Food Delivery job
RegisterNetEvent("FoodDelivery:started", function(spawned_car)
    local player = source -- Assuming source refers to the player who triggered the event

    if Config.UseND then
        -- Check if the entity exists before proceeding
        if DoesEntityExist(spawned_car) then
            local netId = NetworkGetNetworkIdFromEntity(spawned_car)
            exports["ND_VehicleSystem"]:giveAccess(player, spawned_car, netId)
            exports["ND_VehicleSystem"]:setVehicleOwned(player, { model = spawned_car }, false)
            exports["ND_VehicleSystem"]:giveKeys(spawned_car, player, player) -- You need to define targetPlayer based on your logic
        else
            print("Invalid vehicle entity!")
        end
    end
end)

-- Event handler for successful Food Delivery
RegisterServerEvent('FoodDelivery:success')
AddEventHandler('FoodDelivery:success', function(pay)
    local player = NDCore.getPlayer(source)
    local success = player.addMoney("cash", pay, "Food Delivery Reward")
    print(success)
end)

-- Event handler for penalty in Food Delivery
RegisterServerEvent("FoodDelivery:penalty")
AddEventHandler("FoodDelivery:penalty", function(money)
    local player = NDCore.getPlayer(source)
    local success = player.deductMoney("cash", money, "Food Delivery Penalty")
    print(success)
end)
