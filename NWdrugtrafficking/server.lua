-- variables, do not touch
local deliveries = {}
local playersOnJob = {}

RegisterNetEvent("DrugTrafficking:StartedCollecting", function(drugVan)
    local src = source
    playersOnJob[src] = true
    -- No exploit check for starting the job
end)

RegisterNetEvent("DrugTrafficking:DrugsDelivered", function(location)
    local src = source
    -- keep track of amount of deliveries made
    if not deliveries[src] then
        deliveries[src] = 0
    end
    deliveries[src] = deliveries[src] + 1
end)

RegisterNetEvent("DrugTrafficking:NeedsPayment", function()
    local src = source
    if not deliveries[src] or deliveries[src] == 0 then
        print(string.format("^1Warning: Player %s requested payment without completing the job", GetPlayerName(src)))
        return
    end
    -- calculate amount of money to give to the player
    local amount = Config.DrugPay * deliveries[src]
    -- give the money to player
    -- if using another framework than ND, change the function below to your framework's
    deliveries[src] = 0
    playersOnJob[src] = false
    local player = NDCore.getPlayer(src)
    local success = player.addMoney("cash", amount, "Drug Trafficking Reward")
    print(success)
end)
