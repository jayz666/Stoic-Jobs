--[[
Created by Lama Development
Eveloped by 5M-CodeX
]] --

-- Event handler for starting the Trash Collector job
RegisterNetEvent("TrashCollector:started", function(garbageTruck)
    local player = source -- Assuming source refers to the player who triggered the event

    if Config.UseND then
        if DoesEntityExist(garbageTruck) then
            local netId = NetworkGetNetworkIdFromEntity(garbageTruck)
            exports["ND_VehicleSystem"]:giveAccess(player, garbageTruck, netId)
            exports["ND_VehicleSystem"]:setVehicleOwned(player, { model = garbageTruck }, false)
            exports["ND_VehicleSystem"]:giveKeys(garbageTruck, player, player) -- You need to define targetPlayer based on your logic
        else
            print("Invalid garbage truck entity!")
        end
    end
end)

-- Event handler for giving reward to the player
RegisterServerEvent('TrashCollector:GiveReward')
AddEventHandler('TrashCollector:GiveReward', function(randomPayment)
    local player = NDCore.getPlayer(source)
    local success = player.addMoney("cash", randomPayment, "Trash Collection Reward")
    print(success)
end)
