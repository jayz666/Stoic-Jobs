--[[
Created by Lama Development
For support - https://discord.gg/etkAKTw3M7
Do not edit below if you don't know what you are doing
]] --

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
    "prop_cs_bin_01_skinned",
    "prop_cs_bin_02",
    "prop_cs_bin_01",
    "prop_ld_rub_binbag_01",
    "prop_rub_binbag_sd_02",
    "prop_ld_binbag_01",
    "prop_cs_rub_binbag_01",
    "prop_bin_07b",
    "prop_bin_01a",
    "prop_recyclebin_05_a",
    "prop_recyclebin_02_c",
    "prop_recyclebin_03_a",
    "zprop_bin_01a_old",
    "prop_bin_07c",
    "prop_bin_14a",
    "prop_bin_02a",
    "prop_bin_08a",
    "prop_bin_08open",
    "prop_bin_14b",
    "prop_cs_dumpster_01a",
    "p_dumpster_t",
    "prop_dumpster_3a",
    "prop_dumpster_4b",
    "prop_dumpster_4a",
    "prop_dumpster_01a",
    "prop_dumpster_02b",
    "prop_dumpster_02a"
}

local garbageCanOptions = {
    label = "Pick up trash",  -- Label for the option
    distance = 5,              -- Max distance to display the option
    onSelect = function(data)  -- Function to execute when the option is selected
        if isInJob then
            PayForTrash()          -- Pay the player for picking up trash
        end
    end
}

-- Register garbage can models with ox_target
for _, model in ipairs(garbageCanModels) do
    exports.ox_target:addModel(model, garbageCanOptions)
end

-- Function to pay the player for picking up trash
function PayForTrash()
    if isInJob then
        local randomPayment = math.random(Config.MinRandomPayment, Config.MaxRandomPayment)
        garbagePay = garbagePay + randomPayment
        drawnotifcolor("You've earned $" .. randomPayment .. " for picking up trash.", 140)
        TriggerServerEvent("TrashCollector:GiveReward", randomPayment)
        print("Random payment: $" .. randomPayment)
    else
        drawnotifcolor("You must be in a job to pick up trash.", 140)
    end
end

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

    -- If the truck is far from the spawn location, set a waypoint to it
    if truckDistance > 100 then
        -- Remove the waypoint blip
        if waypointBlip ~= nil then
            RemoveBlip(waypointBlip)
            waypointBlip = nil
        end
    elseif waypointBlip == nil then
        -- Add waypoint blip if it doesn't exist
        waypointBlip = AddBlipForCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
        SetBlipSprite(waypointBlip, 1)
        SetBlipColour(waypointBlip, 2)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Truck Spawn")
        EndTextCommandSetBlipName(waypointBlip)
    end
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

-- Function to continuously check if the player is in the return spot
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Adjust the interval as needed
        if not isInJob then
            -- If the player is not in a job, there's no need to check
            return
        end

        local spawnCoords = vector3(Config.TrashTruckSpawn.x, Config.TrashTruckSpawn.y, Config.TrashTruckSpawn.z)
        local truckCoords = GetEntityCoords(garbageTruck)
        local truckDistance = Vdist(truckCoords.x, truckCoords.y, truckCoords.z, spawnCoords.x, spawnCoords.y, spawnCoords.z)

        if truckDistance < 5 then
            -- If the truck is near the spawn location, check if the player wants to delete it
            drawnotifcolor("Press ~g~E~w~ to delete the vehicle.", 140)
            if IsControlJustPressed(1, 38) then
                -- If the player presses E, delete the vehicle
                DeleteEntity(garbageTruck)
                drawnotifcolor("Vehicle deleted.", 25)
                return
            end
        end
    end
end)


-- Draw notification above the minimap
function drawnotifcolor(text, color)
    Citizen.InvokeNative(0x92F0DA1E27DB96DC, tonumber(color))
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end