-- Local variables
local visits = 1
local l = 0
local area = 0
local isOnFoodJob = false
local foodPay = 0
local maxvisits = 10 -- Adjust this value according to your needs
local spawned_car = nil -- Added variable to store the spawned car
local deliveryblip = nil -- Added variable to store the delivery blip

-- These are all the delivery locations, sorted from close to far (earn less for close runs, more for far ones)
local destination = {
    { x = -470.18, y = 7089.24, z = 22.37, money = math.random(100, 350) },
    { x = -486.24, y = 7039.82, z = 24.19, money = math.random(100, 350) },
    { x = -536.22, y = 7004.64, z = 24.26, money = math.random(100, 350) },
    { x = -550.91, y = 6911.08, z = 24.29, money = math.random(100, 350) },
    { x = -538.76, y = 6913.82, z = 24.29, money = math.random(100, 350) },
    { x = -553.17, y = 6854.64, z = 25.69, money = math.random(100, 350) },
    { x = -531.93, y = 6717.26, z = 21.48, money = math.random(100, 350) },
    { x = -627.22, y = 6806.10, z = 28.13, money = math.random(100, 350) },
    { x = -636.51, y = 6894.42, z = 24.61, money = math.random(100, 350) },
    { x = -595.20, y = 6916.05, z = 24.76, money = math.random(100, 350) },
    { x = -623.14, y = 6930.84, z = 24.29, money = math.random(100, 350) },
    { x = -271.90, y = 6354.21, z = 31.96, money = math.random(100, 350) },
    { x = -213.27, y = 6445.75, z = 30.91, money = math.random(100, 350) },
    { x = -236.70, y = 6422.60, z = 30.91, money = math.random(100, 350) },
    { x = -272.36, y = 6400.48, z = 30.91, money = math.random(100, 350) },
    { x = -358.75, y = 6333.28, z = 29.20, money = math.random(100, 350) },
    { x = -406.29, y = 6313.53, z = 28.81, money = math.random(100, 350) },
    { x = -437.22, y = 6272.47, z = 29.47, money = math.random(100, 350) },
    { x = -448.11, y = 6260.08, z = 29.47, money = math.random(100, 350) },
    { x = -467.76, y = 6206.54, z = 28.86, money = math.random(100, 350) },
    { x = -373.87, y = 6190.85, z = 31.52, money = math.random(100, 350) },
    { x = -356.28, y = 6206.54, z = 31.52, money = math.random(100, 350) },
    { x = -347.60, y = 6224.83, z = 31.52, money = math.random(100, 350) },
    { x = -379.53, y = 6253.93, z = 31.52, money = math.random(100, 350) },
    { x = -371.22, y = 6267.35, z = 31.52, money = math.random(100, 350) },
    { x = -332.61, y = 6302.39, z = 32.85, money = math.random(100, 350) },
    { x = -303.06, y = 6327.98, z = 32.14, money = math.random(100, 350) },
    { x = -248.04, y = 6370.30, z = 31.20, money = math.random(100, 350) },
    { x = -227.39, y = 6377.66, z = 31.20, money = math.random(100, 350) },
    { x = -214.72, y = 6396.37, z = 32.63, money = math.random(100, 350) },
    { x = -189.16, y = 6409.95, z = 31.66, money = math.random(100, 350) },
    { x = -159.48, y = 6432.51, z = 31.66, money = math.random(100, 350) },
    { x = -157.29, y = 6409.07, z = 31.66, money = math.random(100, 350) },
    { x = -150.63, y = 6416.27, z = 35.83, money = math.random(100, 350) },
    { x = -130.54, y = 6551.59, z = 28.77, money = math.random(100, 350) },
    { x = -105.48, y = 6528.59, z = 29.30, money = math.random(100, 350) },
    { x = -45.15, y = 6582.50, z = 32.01, money = math.random(100, 350) },
    { x = -26.65, y = 6597.57, z = 32.01, money = math.random(100, 350) },
    { x = 1.35, y = 6613.38, z = 31.52, money = math.random(100, 350) },
    { x = -9.97, y = 6654.53, z = 31.52, money = math.random(100, 350) },
    { x = -41.54, y = 6636.74, z = 30.88, money = math.random(100, 350) },
    { x = 34.69, y = 6662.68, z = 31.67, money = math.random(100, 350) },
    { x = 105.05, y = 6613.83, z = 31.67, money = math.random(100, 350) },
    { x = 119.70, y = 6626.02, z = 31.67, money = math.random(100, 350) },
    { x = -102.16, y = 6330.38, z = 35.18, money = math.random(100, 350) },
    { x = -108.13, y = 6339.10, z = 35.18, money = math.random(100, 350) },
    { x = -84.65, y = 6362.20, z = 30.88, money = math.random(100, 350) },
    { x = -146.77, y = 6303.32, z = 30.80, money = math.random(100, 350) },
    { x = -271.98, y = 6182.64, z = 30.98, money = math.random(100, 350) },
    { x = -377.10, y = 6118.23, z = 30.91, money = math.random(100, 350) },
    { x = -449.87, y = 6016.48, z = 30.80, money = math.random(100, 350) },
}
-- draw marker and check when the client starts the job
Citizen.CreateThread(function()
    AddTextEntry("press_start_job", "Press ~INPUT_CONTEXT~ to start your shift")
    while true do
        Citizen.Wait(0)
        DrawMarker(1, -347.62, 7164.83, 5.00, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 1.5001, 139, 69, 19, 75, 0, 0, 0, 0)
        if GetDistanceBetweenCoords(-347.62, 7164.83, 6.40, GetEntityCoords(GetPlayerPed(-1))) <= 3 then
            if not isOnFoodJob then
                DisplayHelpTextThisFrame("press_start_job")
                if IsControlJustReleased(1, 38) then
                    SpawnDeliveryCar()
                end
            end
        end
    end
end)

function IsInVehicle()
    local ply = GetPlayerPed(-1)
    return IsPedSittingInAnyVehicle(ply)
end

function StartFoodDeliveryJob()
    AddTextEntry("press_deliver_food", "Press ~INPUT_CONTEXT~ to deliver the coffee")
    isOnFoodJob = true
    local message = Config.UseND and "Drive to the destination.\nPress ~r~X~s~ at any time to cancel the delivery. You will be penalized"
                                    or "Drive to the destination.\nPress ~r~X~s~ at any time to cancel the delivery."
    drawnotifcolor(message, 140)

    -- choose random destination
    area = math.random(1, #destination)
    l = area

    -- remove the previous blip
    if deliveryblip ~= nil then
        RemoveBlip(deliveryblip)
    end

    -- create blip and route
    deliveryblip = AddBlipForCoord(destination[l].x, destination[l].y, destination[l].z)
    SetBlipSprite(deliveryblip, 280)
    SetBlipColour(deliveryblip, 31)
    SetBlipRoute(deliveryblip, true)
    SetBlipRouteColour(deliveryblip, 31)

    while isOnFoodJob do
        Citizen.Wait(0)
        -- client has cancelled the delivery
        if IsControlJustReleased(1, 73) then
            if Config.UseND then
                TriggerServerEvent('FoodDelivery:penalty', destination[l].money)
            end
            isOnFoodJob = false
            RemoveBlip(deliveryblip)
            SetBlipRoute(deliveryblip, false)
            visits = 1
            local penaltyMessage = Config.UseND and "You've cancelled the delivery and paid $" .. destination[l].money .. " as penalty. You may return the car."
                                                or "You've cancelled the delivery. You may return the car."
            drawnotifcolor(penaltyMessage, 208)
            SetNewWaypoint(-321.85, 7151.46, 6.65)
            -- delete the car
            if spawned_car ~= nil then
                DeleteEntity(spawned_car)
                spawned_car = nil
            end
            ReturnJobCar()
            break
        end
        -- check if the client is near the destination
        if GetDistanceBetweenCoords(destination[l].x, destination[l].y, destination[l].z, GetEntityCoords(GetPlayerPed(-1))) < 10.0 then
            DisplayHelpTextThisFrame("press_deliver_food")
            -- client has pressed E
            if IsControlJustReleased(1, 38) then
                FoodDeliverySuccessful()
                break
            end
        end
    end
end

function SpawnDeliveryCar()
    -- if the client is already in a vehicle, don't spawn one
    if IsInVehicle() then
        isOnFoodJob = true
        StartFoodDeliveryJob()
    else
        Citizen.Wait(0)
        local myPed = GetPlayerPed(-1)
        local player = PlayerId()
        local vehicle = math.randomchoice(Config.FoodCarModels)
        RequestModel(vehicle)
        while not HasModelLoaded(vehicle) do
            Wait(1)
        end
        local spawnCoords = vector3(-321.85, 7151.46, 6.65) -- Replace with your desired spawn location
        local heading = 184.25 -- Replace with your desired heading
        -- spawn food delivery car
        spawned_car = CreateVehicle(vehicle, spawnCoords, heading, true, false)
        SetVehicleEngineOn(spawned_car, true, true, false)
        SetVehicleOnGroundProperly(spawned_car)
        SetModelAsNoLongerNeeded(vehicle)
        Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
        
        -- Create a blip for the spawned vehicle
        local vehicleBlip = AddBlipForEntity(spawned_car)
        SetBlipSprite(vehicleBlip, 227) -- Choose your preferred blip sprite
        SetBlipColour(vehicleBlip, 31) -- Choose your preferred blip color

        -- start job
        isOnFoodJob = true
        StartFoodDeliveryJob()
        -- tell the server we started the job and to give access to the vehicle
        TriggerServerEvent("TruckDriver:started", spawned_car)
    end
end


function FoodDeliverySuccessful()
    -- add the delivery foodPay to the total
    foodPay = foodPay + destination[l].money
    -- if the client has completed all deliveries, end the job
    if visits == maxvisits then 
        RemoveBlip(deliveryblip)
        visits = 1
        if Config.UseND then
            TriggerServerEvent('FoodDelivery:success', foodPay)
            drawnotifcolor("You've received ~g~$" .. foodPay .. "~w~ for completing the job. You may return the car.", 140)
        else 
            drawnotifcolor("You've completed the job. You may return the car.", 140)
        end
        -- set waypoint to the starting location
        SetNewWaypoint(-347.62, 7164.83, 6.40)
        isOnFoodJob = false
        ReturnJobCar()
    else
        visits = visits + 1
        StartFoodDeliveryJob()
    end
end

function ReturnJobCar()
    -- Prompt to return the job car
    AddTextEntry("press_return_car", "Press ~INPUT_CONTEXT~ to return the job car")
    while true do
        Citizen.Wait(0)
        DrawMarker(1, -321.85, 7151.46, 5.65, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 1.5001, 139, 69, 19, 75, 0, 0, 0, 0)

        if GetDistanceBetweenCoords(-321.85, 7151.46, 6.65, GetEntityCoords(GetPlayerPed(-1))) <= 3 then
            DisplayHelpTextThisFrame("press_return_car")
            if IsControlJustReleased(1, 38) then
                DeleteEntity(spawned_car)
                spawned_car = nil
                drawnotifcolor("You've returned the job car.", 140)
                break
            end
        end
    end
end

-- draw notification above minimap
function drawnotifcolor(text, color)
    Citizen.InvokeNative(0x92F0DA1E27DB96DC, tonumber(color))
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end

local blips = {{
    title = "Coffee Delivery Job",
    colour = 53,
    id = 827,
    x = -347.62,
    y = 7164.83,
    z = 6.40
}}

-- draw job blip
Citizen.CreateThread(function()
    for _, info in pairs(blips) do
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end
end)

function math.randomchoice(d)
    local keys = {}
    for key, _ in pairs(d) do
        table.insert(keys, key)
    end
    local randomKey = keys[math.random(1, #keys)]
    return d[randomKey]
end
