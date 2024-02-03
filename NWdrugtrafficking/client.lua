    -- variables, do not touch
    local JobStarted = false
    local pay = 0
    local bliplocation = vector3(-541.37, 6918.69, 24.29)

    SetBlipSprite(blip, 514)
    SetBlipDisplay(blip, 4)
    SetBlipColour(blip, 44)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drug Trafficking Job")
    EndTextCommandSetBlipName(blip)

    -- new objective
    function NewDrugBlip()
        -- get random objective location
        local objective = math.randomchoice(Config.DrugPositions)
        local ped = GetPlayerPed(-1)
        local blip = AddBlipForCoord(objective.x, objective.y, objective.z)
        SetBlipSprite(blip, 51)
        SetBlipColour(blip, 44)
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, 44)
        local coords = GetEntityCoords(ped)
        local distance = Vdist2(coords, objective.x, objective.y, objective.z)

        while true do
            local opti = 5000
            coords = GetEntityCoords(ped)
            distance = Vdist2(coords, objective.x, objective.y, objective.z)
            AddTextEntry("press_collect_drugs2", 'Press ~INPUT_CONTEXT~ to deliver the drugs')
            if distance <= 50 then
                opti = 1000
                if distance <= 10 then
                    opti = 2
                    -- client is near objective
                    DisplayHelpTextThisFrame("press_collect_drugs2")
                    -- client has pressed E
                    if IsControlJustPressed(1, 38) then
                        TriggerServerEvent("DrugTrafficking:DrugsDelivered", objective)
                        -- sum up the pay
                        pay = pay + Config.DrugPay
                        RemoveBlip(blip)
                        ChoiceNotif()
                        break
                    end
                end
            end
            -- client has pressed X to stop the job
            if IsControlJustPressed(1, 73) then
                RemoveBlip(blip)
                drawnotifcolor("Bring back the van.", 25)
                StopDrugJob()
                break
            end
            Wait(opti)
        end
    end

    function ChoiceNotif()
        drawnotifcolor("Press ~g~E~w~ for more drug deliveries.\nPress ~r~X~w~ if you want to stop the job.", 140)
        local timer = 5000
        
        while timer >= 1 do
            Wait(10)
            timer = timer - 1

            -- client has pressed E to continue the job
            if IsControlJustPressed(1, 38) then
                NewDrugChoice()
                break
            end

            -- client has pressed X to stop the job
            if IsControlJustPressed(1, 73) then
                drawnotifcolor("Bring back the van.", 25)
                StopDrugJob()
                break
            end

            -- timer is up
            if timer == 1 then
                drawnotifcolor("You took too much time! The deal is off, bring back the drugs.", 208)
                StopDrugJob()
                break
            end

        end
    end

    function NewDrugChoice()
        local route = math.randomchoice(Config.DrugPositions)
        local ped = GetPlayerPed(-1)
        local blip = AddBlipForCoord(route.x, route.y, route.z)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 3)
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, 3)
        drawnotifcolor("New location is set, press ~r~X~w~ if you want to stop the job.", 140)
        local coords = GetEntityCoords(ped)
        local distance = Vdist2(coords, route.x, route.y, route.z)

        while true do
            local opti = 5000
            -- get distance between client and objective
            coords = GetEntityCoords(ped)
            distance = Vdist2(coords, route.x, route.y, route.z)
            AddTextEntry("press_collect_drugs", 'Press ~INPUT_CONTEXT~ to collect the drugs.')
            if distance <= 60 then
                opti = 1000
                if distance <= 10 then
                    opti = 2
                    -- client is near objective
                    DisplayHelpTextThisFrame("press_collect_drugs")
                    if IsControlJustPressed(1, 38) then
                        RemoveBlip(blip)
                        NewDrugBlip()
                        break
                    end
                end
            end
            -- client has pressed X to stop the job
            if IsControlJustPressed(1, 73) then
                RemoveBlip(blip)
                if Config.UseND then
                    drawnotifcolor("Bring back the van to get the money.", 140)
                else
                    drawnotifcolor("Bring back the van to complete the job.", 140)
                end
                StopDrugJob()
                break
            end
            Wait(opti)
        end
    end

    function StopDrugJob()
        local coordsEndService = Config.DrugReturnPosition
        local ped = GetPlayerPed(-1)
        AddTextEntry("press_ranger_ha420", 'Press ~INPUT_CONTEXT~ to return the van and complete the job.')
        local blip = AddBlipForCoord(coordsEndService)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 1)
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, 1)

        while true do
            local opti = 5000
            local coords = GetEntityCoords(ped)
            local distance = Vdist2(coordsEndService, coords)
            if distance <= 50 then
                opti = 1000
                if distance <= 10 then
                    opti = 2
                    DisplayHelpTextThisFrame("press_ranger_ha420")
                    -- client has pressed E to store the van
                    if IsControlJustPressed(1, 38) then
                        local playerPed = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(playerPed, false) 
                        DeleteEntity(vehicle)
                        if Config.UseND then
                            -- tell server we need payment along with the location
                            TriggerServerEvent("DrugTrafficking:NeedsPayment", coordsEndService)
                            drawnotifcolor("You've received ~g~$" .. pay .. "~w~ for completing the job.", 140)
                        else
                            drawnotifcolor("You've completed the job.", 140)
                        end
                        RemoveBlip(blip)
                        JobStarted = false
                        pay = 0
                        break
                    end
                end
            end
            Wait(opti)
        end
    end

    function StartDrugJob()
        local ped = GetPlayerPed(-1)
        local vehicleName = math.randomchoice(Config.DrugVehicle)
        RequestModel(vehicleName)
        while not HasModelLoaded(vehicleName) do
            Wait(500)
        end
        -- spawn the vehicle
        drugVan = CreateVehicle(vehicleName, -541.28, 6907.87, 24.29, 192.76, true, false)
        SetVehicleEngineOn(drugVan, true, true, false)
        SetVehicleFixed(drugVan)
        SetEntityAsMissionEntity(drugVan, true, true)
        SetModelAsNoLongerNeeded(vehicleName)
        JobStarted = true
        -- first objective
        NewDrugChoice()
		-- tell server we started the job and give access to vehicle
        TriggerServerEvent("DrugTrafficking:StartedCollecting", drugVan)
    end

    -- draw marker and check when to start the job
    CreateThread(function()
        AddTextEntry("press_start_job", "Press ~INPUT_CONTEXT~ to start the job")
        while true do
            local opti = 5000
            local ped = GetPlayerPed(-1)
            local coords = GetEntityCoords(ped)
            local distance = Vdist2(vector3(-541.37, 6918.69, 24.29), coords)
            if distance <= 50 and not JobStarted then
                opti = 1000
                if distance <= 10 then
                    opti = 2
                    DrawMarker(1, -541.37, 6918.69, 23.29, 0, 0, 0, 0, 0, 0, 2.001, 2.0001, 1.5001, 255, 165, 0, 75, 0, 0, 0, 0)

                    if distance <= 2 then
                        DisplayHelpTextThisFrame("press_start_job")
                        if IsControlJustPressed(1, 38) then
                            StartDrugJob()
                        end
                    end
                end
            end
            Wait(0)
        end
    end)

    -- draw notification above minimap
    function drawnotifcolor(text, color)
        Citizen.InvokeNative(0x92F0DA1E27DB96DC, tonumber(color))
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, true)
    end

    function math.randomchoice(d)
        local keys = {}
        for key, _ in pairs(d) do
            table.insert(keys, key)
        end
        local randomKey = keys[math.random(1, #keys)]
        return d[randomKey]
    end