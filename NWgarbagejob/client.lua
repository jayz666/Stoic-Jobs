-- Variables, do not touch
local isInJob = false
local JobStarted = false
local garbagePay = 0
local garbageTruck = nil
local waypointBlip = nil

-- Declare garbage can models
local garbageCanModels = {
    "prop_rub_binbag_sd_01",
    "prop_cs_bin_03",
    -- Add more garbage can models as needed
}

local garbageCanOptions = {
    label = "Search bin bag",   -- Updated label for the option
    distance = 5,               -- Max distance to display the option
    onSelect = function(data)   -- Function to execute when the option is selected
        if isInJob then
            SearchBinBag(data.entity) -- Call function to search bin bag
        end
    end
}

-- Register garbage can models with ox_target
for _, model in ipairs(garbageCanModels) do
    exports.ox_target:addModel(model, garbageCanOptions)
end

-- Function to search bin bag
function SearchBinBag(binBagEntity)
    -- Generate a random number of items found in the bin bag (between 0 and 3)
    local numItems = math.random(0, 3)
    
    if numItems > 0 then
        -- Notify the player about found items
        drawnotifcolor("You found " .. numItems .. " item(s) in the bin bag:", 140)
        for i = 1, numItems do
            -- Generate random item or resource
            local item = GenerateRandomItem()
            drawnotifcolor("- " .. item, 140)
        end
    else
        -- Notify the player that no items were found
        drawnotifcolor("You didn't find anything in the bin bag.", 140)
    end
    
    -- Determine if the player gets hurt while searching
    if math.random() < 0.1 then -- 10% chance of getting hurt
        drawnotifcolor("Ouch! You got hurt while searching the bin bag.", 255) 
        -- Add logic here to apply damage to the player
        -- Example: ApplyDamageToPlayer()
    end
    
    -- Destroy the bin bag entity after searching
    DeleteEntity(binBagEntity)
end

-- Function to generate a random item
function GenerateRandomItem()
    -- Add logic here to generate random items
    local items = {
        "Trash",
        "Empty can",
        "Useful item",
        -- Add more items as needed
    }
    local randomIndex = math.random(1, #items)
    return items[randomIndex]
end

-- Draw notification above the minimap
function drawnotifcolor(text, color)
    Citizen.InvokeNative(0x92F0DA1E27DB96DC, tonumber(color))
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end

-- Draw marker and check when to start the job
Citizen.CreateThread(function()
    -- Add your code here to draw markers and check when to start the job
    AddTextEntry("press_start_job", "Press ~INPUT_CONTEXT~ to start your shift")
    while true do
        Citizen.Wait(1)
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local distance = GetDistanceBetweenCoords(vector3(-343.36, 7114.91, 6.43), coords, true)
        DrawMarker(1, -343.36, 7114.91, 4.73, 0, 0, 0, 0, 0, 0, 2.001, 2.0001, 1.5001, 50, 205, 50, 75, 0, 1, 0, 0)

        if distance <= 2 then
            DisplayHelpTextThisFrame("press_start_job")
            if IsControlPressed(1, 38) then
                StartGarbageJob()
            end
        end
    end
end)

-- Function for starting the garbage collection job
function StartGarbageJob()
    isInJob = true
    local vehicle = Config.GarbageTruck
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(500)
    end

    -- Use the specified spawn location from Config.TrashTruckSpawn
    local spawnCoords = vector3(Config.TrashTruckSpawn.x, Config.TrashTruckSpawn.y, Config.TrashTruckSpawn.z)

    -- Spawn garbage truck
    garbageTruck = CreateVehicle(vehicle, spawnCoords, 0.0, true, false)
    SetVehicleEngineOn(garbageTruck, true, true, false)

    if DoesEntityExist(garbageTruck) then
        local netId = NetworkGetNetworkIdFromEntity(garbageTruck)
        -- Tell the server that the player has started the job and to give access to the truck
        TriggerServerEvent("TruckDriver:started", garbageTruck)
        -- Get the first objective
        NotifChoiceGarbage() -- Start the choice notification loop
    else
        print("Failed to create the garbage truck.")
    end
end

-- Function for choosing between a new objective or stopping the job
function NotifChoiceGarbage()
    drawnotifcolor("Press ~g~E~w~ for a new location.\nPress ~r~X~w~ if you want to stop the job.", 140)
    while true do
        Citizen.Wait(0)
        -- Client has pressed E for a new objective
        if IsControlJustPressed(1, 38) then
            NewChoiseGarbage()
            break
        end
        -- Client has pressed X to stop the job
        if IsControlJustPressed(1, 73) then
            drawnotifcolor("Bring back the truck.", 25)
            StopService()
            break
        end
    end
end

-- Function for stopping the service and deleting the vehicle
function StopService()
    isInJob = false
    local spawnCoords = vector3(Config.TrashTruckSpawn.x, Config.TrashTruckSpawn.y, Config.TrashTruckSpawn.z)
    local truckCoords = GetEntityCoords(garbageTruck)
    local truckDistance = Vdist(truckCoords.x, truckCoords.y, truckCoords.z, spawnCoords.x, spawnCoords.y, spawnCoords.z)

    if truckDistance < 5 then
        -- If the player is near the spawn location, display the notification to delete the vehicle
        drawnotifcolor("Press ~g~E~w~ to delete the vehicle.", 140)
        if IsControlJustPressed(1, 38) then
            -- If the player presses E, delete the vehicle
            DeleteEntity(garbageTruck)
            drawnotifcolor("Vehicle deleted.", 25)
            return
        end
    else
        -- If the player is not near the spawn location, instruct them to return the truck
        drawnotifcolor("Drive the truck back to its spawn location to end the job.", 140)
    end

    -- If the truck is far from the spawn location, set a waypoint

