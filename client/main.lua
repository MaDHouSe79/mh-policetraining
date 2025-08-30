local enableChase, isCrashed, hit, disableControll = false, false, false, false
local config, suspectData, blips, plates, MarkerColor = {}, {}, {}, {}, {}
local text, textCoords, DutyBlip, cuffedEntity = nil, nil, nil, nil
local enableTraining, openMenu, timer, maxtimer = false, false, 0, 60
local isEscorting, isCuffed, isSearchingSuspect = false, false, false

local function Notify(message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify({title = "MH Police Training", description = message, type = type})
    else
        QBCore.Functions.Notify({text = "MH Police Training", caption = message}, type, length)
    end
end

local function LoadDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(1) end
end

local function LoadAnimationDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(1) end
    end
end

local function DisplayHelpText(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function DrawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

local function CuffEntity(entity)
    disableControll = true
    LoadDict("mp_arrest_paired")
    ClearPedTasks(entity)
    ClearPedTasksImmediately(entity)
    SetPedFleeAttributes(entity, 0, false)
    FreezeEntityPosition(entity, true)
    FreezeEntityPosition(PlayerPedId(), true)
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'cop_p2_back_right', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Cuff', 0.5)
    TaskPlayAnim(entity, 'mp_arrest_paired', 'crook_p2_back_right', 3.0, 3.0, -1, 32, 0, 0, 0, 0, true, true, true)
    Wait(3500)
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'exit', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    Wait(100)
    FreezeEntityPosition(PlayerPedId(), false)
    disableControll = false
    isCuffed = true
    isEscorting = true
    cuffedEntity = entity
end

local function UnCuffEntity(entity)
    disableControll = true
    LoadDict("mp_arresting")
    LoadDict('amb@world_human_drinking@coffee@female@base')
    FreezeEntityPosition(PlayerPedId(), true)
    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Uncuff', 0.5)
    StopAnimTask(cuffedEntity, 'mp_arresting', 'walk', -8.0)
    StopAnimTask(cuffedEntity, 'mp_arresting', 'idle', -8.0)
    DetachEntity(cuffedEntity)
    FreezeEntityPosition(cuffedEntity, false)
    FreezeEntityPosition(PlayerPedId(), false)
    Wait(100)
    disableControll = false
    isEscorting = false
    isCuffed = false
    cuffedEntity = nil
end

local function EscortEntity(entity)
    if entity == cuffedEntity then
        LoadDict("mp_arresting")
        LoadDict('amb@world_human_drinking@coffee@female@base')
        FreezeEntityPosition(cuffedEntity, false)
        if not isEscorting then
            DetachEntity(cuffedEntity)
            if isCuffed then
                StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
                StopAnimTask(cuffedEntity, 'mp_arresting', 'walk', -8.0)
                StopAnimTask(cuffedEntity, 'mp_arresting', 'run', -8.0)
                if not IsEntityPlayingAnim(cuffedEntity, 'mp_arresting', 'idle', 3) then
                    TaskPlayAnim(cuffedEntity, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
                    SetPedKeepTask(cuffedEntity, true)
                end
                FreezeEntityPosition(cuffedEntity, true)
            end
        end
    end
end

local function SearchSuspect()
    disableControll = true
    isSearchingSuspect = true
    LoadDict("random@shop_robbery")
    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    TaskPlayAnim(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', 3.0, 3.0, -1, 16, 0, false, false, false)
    Wait(3500)
    StopAnimTask(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', -8.0)
    TaskPlayAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', "base", 8.0, 8.0, -1, 50, 0, false, false, false)
    isSearchingSuspect = false
    disableControll = false
end

local function SearchVehicle()
    disableControll = true
    isSearchingVehicle = true
    LoadDict("random@shop_robbery")
    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    TaskPlayAnim(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', 3.0, 3.0, -1, 16, 0, false, false, false)
    Wait(3500)
    StopAnimTask(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', -8.0)
    TaskPlayAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', "base", 8.0, 8.0, -1, 50, 0, false, false, false)
    isSearchingVehicle = false
    disableControll = false
end

local function RemoveSuspectTarget(suspect)
    exports['qb-target']:RemoveTargetEntity(suspect)
end

local function RemoveVehicleTarget(vehicle)
    exports['qb-target']:RemoveTargetEntity(vehicle)
end

local function LoadVehicleTarget(vehicle)
    local netid = NetworkGetNetworkIdFromEntity(vehicle)
    exports['qb-target']:AddTargetEntity(netid, {
        options = {
            {
                type = "client",
                icon = "fas fa-sack-dollar",
                label = "Search Vehicle",
                action = function(entity)
                    SearchVehicle(entity)
                end,
                canInteract = function(entity)
                    return true
                end,
            },
            {
                type = "client",
                icon = "fas fa-car",
                label = "Get Out",
                action = function(entity)
                    isCuffed = true
                    local ped = GetPedInVehicleSeat(entity, -1)
                    if IsDriver(ped, entity) then
                        TaskLeaveVehicle(ped, entity, 0)
                        Wait(1500)
                        CuffEntity(ped)
                    end
                end,
                canInteract = function(entity)                 
                    return true
                end,
            },
        },
        distance = 3.0
    })
end

local function LoadSuspectTarget(suspect)
    local netid = NetworkGetNetworkIdFromEntity(suspect)
    exports['qb-target']:AddTargetEntity(netid, {
        options = {
            -- Cuff/UnCuff
            {
                type = "client",
                icon = "fas fa-handcuffs",
                label = "Cuff",
                action = function(entity)
                    CuffEntity(entity)
                end,
                canInteract = function(entity, distance, data)
                    if isCuffed then return false end
                    return true
                end
            },
            {
                type = "client",
                icon = "fas fa-handcuffs",
                label = "UnCuff",
                action = function(entity)
                    UnCuffEntity(entity)
                end,
                canInteract = function(entity, distance, data)
                    if not isCuffed then return false end
                    return true
                end
            },
            -- Escort
            {
                type = "client",
                icon = "fas fa-handcuffs",
                label = "Start Escort",
                action = function(entity)
                    isEscorting = true
                    EscortEntity(entity)
                end,
                canInteract = function(entity, distance, data)
                    if not isCuffed then return false end
                    if isEscorting then return false end
                    return true
                end
            },
            {
                type = "client",
                icon = "fas fa-handcuffs",
                label = "Stop Escort",
                action = function(entity)
                    isEscorting = false
                    EscortEntity(entity)
                end,
                canInteract = function(entity, distance, data)
                    if not isCuffed then return false end
                    if not isEscorting then return false end
                    return true
                end
            },
            -- Search Suspect
            {
                type = "client",
                icon = "fas fa-sack-dollar",
                label = "Search Suspect",
                action = function(entity)
                    SearchSuspect(entity)
                end,
                canInteract = function(entity)
                    if not isCuffed then return false end
                    if isSearchingSuspect then return false end
                    if isEscorting then return false end
                    return true
                end,
            },
        },
        distance = 2.0
    })
end

local function LoadTarget()
    for k, v in pairs(config.PedModels) do
        exports['qb-target']:AddTargetModel(GetHashKey(v[2]), {
            options = {
                -- Cuff/UnCuff
                {
                    type = "client",
                    icon = "fas fa-handcuffs",
                    label = "Cuff",
                    action = function(entity)
                        disableControll = true
                        CuffEntity(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if isCuffed then return false end
                        return true
                    end
                },
                {
                    type = "client",
                    icon = "fas fa-handcuffs",
                    label = "UnCuff",
                    action = function(entity)
                        disableControll = true
                        UnCuffEntity(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if not isCuffed then return false end
                        return true
                    end
                },
                -- Escort
                {
                    type = "client",
                    icon = "fas fa-handcuffs",
                    label = "Start Escort",
                    action = function(entity)
                        isEscorting = true
                        EscortEntity(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if not isCuffed then return false end
                        if isEscorting then return false end
                        return true
                    end
                },
                {
                    type = "client",
                    icon = "fas fa-handcuffs",
                    label = "Stop Escort",
                    action = function(entity)
                        isEscorting = false
                        EscortEntity(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if not isCuffed then return false end
                        if not isEscorting then return false end
                        return true
                    end
                },
                -- Search Suspect
                {
                    icon = "fas fa-sack-dollar",
                    label = "Search Suspect",
                    action = function(entity)
                        disableControll = true
                        SearchSuspect(entity)
                    end,
                    canInteract = function(entity)
                        if not isCuffed then return false end
                        if isSearchingSuspect then return false end
                        if isEscorting then return false end
                        return true
                    end,
                },
            },
            distance = 2.0
        })
    end
end

local function RemovePlate(plate)
    for p, _ in ipairs(plates) do
        if p == plate then p = nil end
    end
end

local function GetModelName(vehicle)
    local newName = nil
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local model_label = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    if newName == nil then
        if model ~= nil then
            newName = model
        else
            if model_label ~= nil then newName = model_label end
        end
    end
    return newName:lower()
end

local function GetDistance(pos1, pos2)
    return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
end

local function GetClosestVehicle(coords)
    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        if GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicles[i] then
            local vehicleCoords = GetEntityCoords(vehicles[i])
            local distance = #(vehicleCoords - coords)
            if closestDistance == -1 or closestDistance > distance then
                closestVehicle = vehicles[i]
                closestDistance = distance
            end
        end
    end
    return closestVehicle, closestDistance
end

local function CreateDutyBlip()
    if PlayerData.job ~= nil and PlayerData.job.type == 'leo' and PlayerData.job.onduty then
        local blip = AddBlipForCoord(config.Startpoint.x, config.Startpoint.y, config.Startpoint.z)
        SetBlipSprite(blip, 304)
        SetBlipScale(blip, 0.7)
        SetBlipDisplay(blip, 4)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Training")
        EndTextCommandSetBlipName(blip)
        DutyBlip = blip
    end
end

local function IsWanted(data)
    if plates[data.plate] then return end
    plates[data.plate] = {}
    plates[data.plate].model = data.model
    plates[data.plate].wanted = false
    if math.random(100) <= config.WantedChange then
        plates[data.plate].wanted = true
    end
end

local function DeleteBlips()
    for k, blip in pairs(blips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    blips = {}
end

local function Reset()
    if DoesEntityExist(suspectData.driver) and DoesEntityExist(suspectData.vehicle) then
        RemoveSuspectTarget(suspectData.driver)
        RemoveVehicleTarget(suspectData.vehicle)
        Wait(10)
        DeleteEntity(suspectData.driver)
        DeleteEntity(suspectData.vehicle) 
    end
    Wait(10)
    text = nil
    textCoords = nil
    suspectData = nil
    suspectData = {}
    DeleteBlips()
end

local function CreateWantedVehicleBlip(entity, label)
    if PlayerData.job.type == 'leo' and PlayerData.job.onduty then
        local blip = GetBlipFromEntity(entity)
        if not DoesBlipExist(blip) then
            blip = AddBlipForEntity(entity)
            SetBlipSprite(blip, 161)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 5)
            SetBlipAsShortRange(blip, true)
            ShowHeadingIndicatorOnBlip(blip, true)
            SetBlipRotation(blip, math.ceil(GetEntityHeading(entity)))
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(label)
            EndTextCommandSetBlipName(blip)
            blips[#blips + 1] = blip
        end
        if GetBlipFromEntity(PlayerPedId()) == blip then
            RemoveBlip(blip)
        end
    end
end

local function Flee()
    if (suspectData.driver ~= nil and suspectData.vehicle ~= nil) then
        local police = GetVehiclePedIsIn(PlayerPedId(), true)
        if police ~= 0 and GetVehicleClass(police) == 18 then SetVehicleSiren(police, true) end
        local vehicle_distance = GetDistance(GetEntityCoords(suspectData.driver), GetEntityCoords(suspectData.vehicle))
        enableChase = true
        suspectData.handsup = false
        suspectData.pullover = false
        suspectData.countRotations = 0
        if vehicle_distance < 25 then
            TaskEnterVehicle(suspectData.driver, suspectData.vehicle, 1000, -1, 1.0, 1, 0)
            SetDriverRacingModifier(suspectData.driver, 0.5)
            SetDriverAggressiveness(suspectData.driver, 1.0)
            TaskVehicleDriveWander(suspectData.driver, suspectData.vehicle, config.Speed, config.DriveStyle)
            suspectData.isinvehicle = true
        end
        CreateWantedVehicleBlip(suspectData.vehicle, Lang:t('suspect_vehicle'))
    end
end

local function DoHandActionAnimation(ped)
    LoadAnimationDict("missminuteman_1ig_2")
    suspectData.handsup = true
    suspectData.pullover = false
    TaskPlayAnim(ped, "missminuteman_1ig_2", "handsup_base", -8.0, 8.0, -1, 50, 0, false, false, false)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)
    SetPedKeepTask(ped, true)
    FreezeEntityPosition(ped, true)
end

local function CheckVehicleRotation(vehicle)
    local rotation = GetEntityRotation(vehicle)
    isCrashed = false
    if (rotation.x > 75.0 or rotation.x < -75.0 or rotation.y > 75.0 or rotation.y < -75.0) then suspectData.countRotations = suspectData.countRotations + 1 end
    if suspectData.countRotations >= 1 then isCrashed = true end
end

local function GetVehicleAngle(vehicle)
    if not vehicle then return false end
    local vx, vy, vz = table.unpack(GetEntityVelocity(vehicle))
    local modV = math.sqrt(vx * vx + vy * vy)
    local rx, ry, rz = table.unpack(GetEntityRotation(vehicle, 0))
    local sn, cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
    if GetEntitySpeed(vehicle) * config.SpeedMultiplier < 5 or GetVehicleCurrentGear(vehicle) == 0 then return 0, modV end
    local cosX = (sn * vx + cs * vy) / modV
    if cosX > 0.966 or cosX < 0 then return 0, modV end
    return math.deg(math.acos(cosX)) * 0.5, modV
end

local function SetPedDamagePack(driver)
    if DoesEntityExist(driver) then
        suspectData.hasDamage = true
        ApplyPedDamagePack(driver, "TD_SHOTGUN_FRONT_KILL", 0, 10)
        ApplyPedDamagePack(driver, "BigRunOverByVehicle ", 0, 10)
        ApplyPedDamagePack(driver, "Dirt_Mud", 0, 10)
        ApplyPedDamagePack(driver, "Explosion_Large", 0, 10)
        ApplyPedDamagePack(driver, "RunOverByVehicle", 0, 10)
        ApplyPedDamagePack(driver, "Splashback_Face_0", 0, 10)
        ApplyPedDamagePack(driver, "Splashback_Face_1", 0, 10)
        ApplyPedDamagePack(driver, "SCR_Shark", 0, 10)
        ApplyPedDamagePack(driver, "SCR_Cougar", 0, 10)
        ApplyPedDamagePack(driver, "Car_Crash_Heavy", 0, 10)
        ApplyPedDamagePack(driver, "TD_SHOTGUN_REAR_KILL", 0, 10)
        ApplyPedDamagePack(driver, "SCR_Torture", 0, 10)
        ApplyPedDamagePack(driver, "TD_melee_face_l", 0, 10)
        ApplyPedDamagePack(driver, "MTD_melee_face_r", 0, 10)
        ApplyPedDamagePack(driver, "MTD_melee_face_jaw", 0, 10)
    end
end

local function SetText(wanted, coords, plate, press)
    if press then
        text = wanted .. " " .. Lang:t('plate') .. ":~g~" .. plate .. "~s~ Model:~g~"..plates[plate].model.."~s~ " .. Lang:t('press_to_chase_plate', {interact = config.InterActDisplay})
    else
        text = wanted .. " " .. Lang:t('plate') .. ":~g~" .. plate .. "~s~ Model:~g~"..plates[plate].model.."~s~"
    end
    textCoords = coords
end

local function Progress()
    disableControll = true
    SetEntityVisible(suspectData.driver, false, 0)
    LoadDict("amb@world_human_gardener_plant@male@base")
    TaskPlayAnim(PlayerPedId(), "amb@world_human_gardener_plant@male@base", "base", 3.0, 3.0, -1, 49, 0, false, false, false)
    Wait(10000)
    StopAnimTask(PlayerPedId(), "amb@world_human_gardener_plant@male@base", "base", 1.0)
    disableControll = false
    ClearPedBloodDamage(suspectData.driver, 200.0)
    SetEntityHealth(suspectData.driver, 200.0)
    SetEntityVisible(suspectData.driver, true, 0)
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'cop_p2_back_right', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    DisplayHelpText(Lang:t('suspect_has_recovered'))
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent('mh-policetraining:server:onjoin')
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if suspectData.driver ~= nil and suspectData.vehicle ~= nil then
            PlayerData = {}
            isLoggedIn = false
            DetachEntity(suspectData.driver, false, false)
            DeleteEntity(suspectData.driver)
            DeleteEntity(suspectData.vehicle)
            cooldown = false
            if DoesBlipExist(DutyBlip) then RemoveBlip(DutyBlip) end
            plates = {}
        end
    end
end)

RegisterNetEvent(OnJobUpdate, function(job)
    PlayerData.job = job
    if PlayerData.job.type == 'leo' then
        if PlayerData.job.onduty then
            enableTraining = true
            DisplayHelpText(Lang:t('job_enable'))
        else
            enableTraining = false
            DisplayHelpText(Lang:t('job_disable'))
        end
    end
end)

AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent('mh-policetraining:server:onjoin')
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if suspectData.driver ~= nil and suspectData.vehicle ~= nil then
        if event == "CEventNetworkEntityDamage" then
            if enableTraining then
                local victim, attacker, isDead = data[1], data[2], data[4]
                if isDead then
                    if victim == attacker then return end
                    if victim == suspectData.driver then
                        if PlayerData.job.type == 'leo' and PlayerData.job.onduty then
                            TriggerServerEvent('mh-policetraining:server:update_deads')
                            Reset()
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('mh-policetraining:client:toggleduty', function()
    if PlayerData.job.type == 'leo' and PlayerData.job.onduty then
        enableTraining = not enableTraining
        if enableTraining then
            DisplayHelpText(Lang:t('job_enable'))
        else
            DisplayHelpText(Lang:t('job_disable'))
        end
    end
end)

RegisterNetEvent('mh-policetraining:client:ReceiveData', function(data)
    openMenu = true
    local options = {}
    if #data >= 1 then
        for k, v in pairs(data) do
            options[#options + 1] = {
                id = v.source, 
                title = "Agent ".. v.username .." Job "..v.job.name..' Rank '..v.job.level,
                description = "Arrested: "..v.arrested.."\nEscaped: "..v.escaped.."\nDamages: "..v.damages.."\nFailed: "..v.failed.."\nDeads: "..v.deads.."\nPoints: "..v.points, 
                arrow = false, 
                onSelect = function()
                    openMenu = false
                end
            }
        end
        table.sort(options, function(a, b) return a.id < b.id end)
        options[#options + 1] = {title = 'Close', icon = "fa-solid fa-close", description = '', arrow = false, onSelect = function() openMenu = false end}
        lib.registerContext({id = 'menu', title = "MH Police Training", icon = "fa-solid fa-car", options = options})
        lib.showContext('menu')
    elseif #data <= 0 then
        Notify("No data found..")
        openMenu = false
    end
end)

RegisterNetEvent('mh-policetraining:client:onjoin', function(data)
    config = data
    Wait(10)
    PlayerData = GetPlayerData()
    isLoggedIn = true
    if config.AutoEnable then TriggerServerEvent('mh-policetraining:server:ToggleDuty') end
    plates = {}
    LoadTarget()
    CreateDutyBlip()
end)

RegisterCommand('openduty', function()
    TriggerServerEvent('mh-policetraining:server:GetData')
end, false)

RegisterCommand('toggleduty', function()
    TriggerServerEvent('mh-policetraining:server:ToggleDuty')
end, false)

CreateThread(function()
    while true do
        text = nil
        local sleep = 1000
        if isLoggedIn and enableTraining and not openMenu then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
            if vehicle ~= 0 then
                if GetVehicleClass(vehicle) == 18 then
                    if suspectData.driver == nil and suspectData.vehicle == nil then
                        local front_vehicle_coords = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(PlayerPedId(), 0), 0.0, 5.0, -1.0)
                        local vehicle, distance = GetClosestVehicle(front_vehicle_coords)
                        if not config.IgnoreClasses[GetVehicleClass(vehicle)] then
                            if IsThisModelACar(GetEntityModel(vehicle)) then
                                local plate = GetVehicleNumberPlateText(vehicle)
                                local model = GetModelName(vehicle) or "unknow"
                                IsWanted({plate = plate, model = model})
                                local wanted = ""
                                if plates[plate].wanted then
                                    wanted = Lang:t('wanted')
                                    MarkerColor = {r = 255, g = 0, b = 0}
                                else
                                    MarkerColor = {r = 255, g = 26, b = 126}
                                end
                                if vehicle ~= -1 and distance ~= -1 then
                                    sleep = 50
                                    local driver = GetPedInVehicleSeat(vehicle, -1)
                                    if distance < 15 and driver ~= 0 then
                                        textCoords = GetEntityCoords(vehicle)
                                        SetText(wanted, textCoords, plate, true)
                                        sleep = 10
                                        if IsControlJustPressed(0, config.InterActButton) then
                                            suspectData.plate = GetVehicleNumberPlateText(vehicle)
                                            suspectData.vehicle = vehicle
                                            suspectData.driver = driver
                                            suspectData.isinvehicle = true
                                            LoadSuspectTarget(suspectData.driver)
                                            LoadVehicleTarget(suspectData.vehicle)
                                            SetEntityAsMissionEntity(suspectData.vehicle, true, true)
                                            SetEntityAsMissionEntity(suspectData.driver, true, true)
                                            CreateWantedVehicleBlip(suspectData.vehicle, Lang:t('suspect_vehicle'))
                                        end
                                    else
                                        textCoords = nil
                                    end
                                end
                            end
                        end

                    elseif suspectData.driver ~= nil and suspectData.vehicle ~= nil then
                        local plate = GetVehicleNumberPlateText(suspectData.vehicle)
                        if suspectData.isinvehicle then
                            sleep = 1
                            -- pullover
                            if not enableChase then
                                if not suspectData.pullover then
                                    if GetDistance(GetEntityCoords(vehicle), GetEntityCoords(suspectData.vehicle)) < 15.0 then
                                        sleep = 1
                                        text = Lang:t('press_pullover', {interact = config.InterActDisplay})
                                        if IsControlJustPressed(0, config.InterActButton) then
                                            if plates[plate].wanted then
                                                Flee()
                                            else
                                                if math.random(1, 100) < 5 then
                                                    plates[plate].wanted = true
                                                    Flee()
                                                else
                                                    suspectData.pullover = true
                                                end
                                            end
                                        end
                                    end

                                elseif suspectData.pullover then
                                    sleep = 10
                                    if GetEntitySpeed(suspectData.vehicle) * config.SpeedMultiplier > 0.9 then
                                        TaskVehicleTempAction(suspectData.driver, suspectData.vehicle, 24, 5000)
                                        Wait(1500)
                                    elseif GetEntitySpeed(suspectData.vehicle) * config.SpeedMultiplier == 0.0 then
                                        TaskLeaveVehicle(suspectData.driver, suspectData.vehicle, 1)
                                        Wait(1500)
                                        DoHandActionAnimation(suspectData.driver)
                                        suspectData.isinvehicle = false
                                        FreezeEntityPosition(suspectData.driver, true)
                                    end
                                end
                            elseif enableChase then
                                if GetDistance(GetEntityCoords(PlayerPedId()), GetEntityCoords(suspectData.vehicle)) > config.MinDistance and not suspectData.lost then
                                    suspectData.lost = true
                                    TriggerServerEvent('mh-policetraining:server:update_escaped')
                                    Wait(1000)
                                    Reset()
                                end
                            end
                        elseif not suspectData.isinvehicle and not suspectData.isinpolicevehicle then
                            -- handcuff
                            if GetDistance(GetEntityCoords(PlayerPedId()), GetEntityCoords(suspectData.driver)) < 2.5 then
                                sleep = 1
                                if not suspectData.cuffed then
                                    text = Lang:t('press_handcuff', {interact = config.InterActDisplay})
                                    if IsControlJustPressed(0, config.InterActButton) then
                                        if not IsEntityAttachedToAnyPed(suspectData.driver) then
                                            suspectData.cuffed = true
                                            DeleteBlips()
                                            CuffEntity(suspectData.driver)
                                        end
                                    end
                                end
                            end

                            -- Set suspect in vehicle
                            if IsEntityAttachedToAnyPed(suspectData.driver) then
                                if GetDistance(GetEntityCoords(PlayerPedId()), GetEntityCoords(vehicle)) < 3 then
                                    sleep = 1
                                    text = Lang:t('press_set_in_vehicle', {interact = config.InterActDisplay})
                                    if IsControlJustPressed(0, config.InterActButton) then
                                        UnCuffEntity(suspectData.driver)
                                        SetPedIntoVehicle(suspectData.driver, vehicle, 1)
                                        suspectData.isinpolicevehicle = true
                                        suspectData.cuffed = false
                                        Wait(1000)
                                    end
                                end
                            end
                        end

                        if suspectData.isinpolicevehicle then
                            -- Get suspect out of vehicle
                            if GetDistance(GetEntityCoords(PlayerPedId()), GetEntityCoords(vehicle)) < 3 then
                                if GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
                                    text = Lang:t('press_get_out_vehicle', {interact = config.InterActDisplay})
                                    sleep = 1
                                    if IsControlJustPressed(0, config.InterActButton) then
                                        TaskLeaveVehicle(suspectData.driver, vehicle, 1)
                                        Wait(1500)
                                        CuffEntity(suspectData.driver)
                                        suspectData.cuffed = true
                                        suspectData.isinpolicevehicle = false
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- sitting back in police vehicle
            if suspectData.driver ~= nil and not suspectData.isinvehicle and not isEscorting then
                if suspectData.cuffed or suspectData.isinpolicevehicle then
                    sleep = 10
                    TaskPlayAnim(suspectData.driver, "mp_arresting", "idle", 8.0, -8, -1, 16, 0, 0, 0, 0)
                end
            end

            -- display job done text
            if GetDistance(GetEntityCoords(PlayerPedId()), config.Deliverpoint) < 2.0 then
                if suspectData.driver ~= nil and suspectData.vehicle ~= nil then
                    sleep = 1
                    text = Lang:t('press_to_deliver', {interact = config.InterActDisplay})
                    if IsControlJustPressed(0, config.InterActButton) then
                        if suspectData.hasDamage then
                            DisplayHelpText(Lang:t('suspect_has_damage'))
                        else
                            UnCuffEntity(suspectData.driver)
                            if plates[suspectData.plate].wanted then
                                RemovePlate(suspectData.plate)
                                suspectData.plate = nil
                                DisplayHelpText( Lang:t('job_done'))
                                TriggerServerEvent('mh-policetraining:server:update_arrested')
                                Reset()
                            else
                                DisplayHelpText( Lang:t('job_failed'))
                                TriggerServerEvent('mh-policetraining:server:update_failed')
                                Reset()
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if (GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()) then
                local company_distance = GetDistance(GetEntityCoords(vehicle), config.Startpoint)
                if company_distance < 2 then
                    sleep = 5
                    if enableTraining then text = Lang:t('press_to_stop', {interact = config.InterActDisplay}) else text = Lang:t('press_to_start', {interact = config.InterActDisplay}) end
                    if IsControlJustPressed(0, config.InterActButton) then
                        TriggerServerEvent('mh-policetraining:server:ToggleDuty')
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and enableChase then
            if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
                if IsDriver(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId(), false)) then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if IsEntityTouchingEntity(vehicle, suspectData.vehicle) and not hit then
                        hit = true
                        local health = GetVehicleEngineHealth(suspectData.vehicle)
                        if math.random(1, 100) < 25 then
                            SetVehicleEngineHealth(suspectData.vehicle, health - config.ReduseVehicleHealthWhenCrashed)
                        end
                        if health < 250.0 then
                            SetVehicleEngineHealth(suspectData.vehicle, 150.0)
                            TaskVehicleTempAction(suspectData.driver, suspectData.vehicle, 24, 5000)
                            Wait(2000)
                            TaskLeaveVehicle(suspectData.driver, suspectData.vehicle, 1)
                            Wait(1500)
                            DoHandActionAnimation(suspectData.driver)
                            TaskSetBlockingOfNonTemporaryEvents(suspectData.driver, true)
                            suspectData.isinvehicle = false
                            suspectData.isinpolicevehicle = false
                            suspectData.lost = false
                            enableChase = false
                        end
                        Wait(1000)
                        hit = false
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and enableChase then
            sleep = 100
            if suspectData.driver ~= nil and suspectData.vehicle ~= nil and isCrashed then
                SetVehicleEngineHealth(suspectData.vehicle, 150.0)
                Wait(5000)
                TaskLeaveVehicle(suspectData.driver, suspectData.vehicle, 1)
                Wait(1500)
                DoHandActionAnimation(suspectData.driver)
                TaskSetBlockingOfNonTemporaryEvents(suspectData.driver, true)
                Wait(500)
                FreezeEntityPosition(suspectData.driver, true)
                suspectData.isinvehicle = false
                suspectData.isinpolicevehicle = false
                enableChase = false
                isCrashed = false
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and enableChase then
            if suspectData.driver ~= nil and suspectData.vehicle ~= nil then
                if IsDriver(suspectData.driver, suspectData.vehicle) then
                    sleep = 10
                    local angle, speed = GetVehicleAngle(suspectData.vehicle)
                    if speed * config.SpeedMultiplier >= config.MinDriveSpeedChangeToCrash and angle > config.MaxAngleForChangeToCrash then
                        if math.random(1, 100) < config.ChangeToCrash then
                            SetVehicleHandlingField(suspectData.vehicle, "CHandlingData", "fRollCentreHeightFront", -2.0)
                            Wait(2000)
                            SetPedDamagePack(suspectData.driver)
                            SetVehicleHandlingField(suspectData.vehicle, "CHandlingData", "fRollCentreHeightFront", 1.0)
                            sleep = 1000
                        end
                    end
                    if not isCrashed then
                        CheckVehicleRotation(suspectData.vehicle)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if disableControll then
            sleep = 5
            if IsPauseMenuActive() then 
                SetFrontendActive(false)
            end
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 38, true)
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 322, true)
            EnableControlAction(0, 288, true)
            EnableControlAction(0, 213, true)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 46, true)
            EnableControlAction(0, 47, true)
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and enableTraining then
            if suspectData.driver ~= nil and suspectData.vehicle ~= nil then
                if suspectData.isinvehicle then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if IsEntityTouchingEntity(vehicle, suspectData.vehicle) then
                        local speed = GetEntitySpeed(suspectData.vehicle)
                        if speed == 0.0 then
                            if timer < config.MinSecsBeforeArrestTimer then
                                timer = timer + 1
                            elseif timer >= config.MinSecsBeforeArrestTimer then
                                timer = 0
                                suspectData.isinvehicle = false
                                TaskLeaveVehicle(suspectData.driver, suspectData.vehicle, 1)
                                Wait(1500)
                                DoHandActionAnimation(suspectData.driver)
                                FreezeEntityPosition(suspectData.driver, true)
                            end
                        elseif speed > 0.3 then
                            timer = 0
                        end
                    end
                end
            elseif suspectData.driver == nil and suspectData.vehicle == nil then
                timer = 0
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and enableTraining then
            local coords = GetEntityCoords(PlayerPedId())
            if GetDistance(config.HospitalPoint, coords) < 25.0 and suspectData.hasDamage then
                sleep = 5
                local textCoords = config.HospitalPoint
                DrawMarker(2, textCoords.x, textCoords.y, textCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 255, 26, 126, false, false, false, true, false, false, false)
                if GetDistance(config.HospitalPoint, coords) < 2.0 then
                    if suspectData.hasDamage then 
                        text = Lang:t('press_to_recover_suspect', {interact = config.InterActDisplay}) 
                        if IsControlJustPressed(0, config.InterActButton) then
                            suspectData.hasDamage = false
                            text = ""
                            Progress()
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and not openMenu then
            if text ~= nil then
                sleep = 0
                DrawTxt(0.90, 1.44, 1.0, 1.0, 0.6, text, 255, 255, 255, 255)
            end
            if textCoords ~= nil then
                sleep = 0
                DrawMarker(2, textCoords.x, textCoords.y, textCoords.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, MarkerColor.r, MarkerColor.g, MarkerColor.b, false, false, false, true, false, false, false)
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    LoadDict("mp_arresting")
    LoadDict('amb@world_human_drinking@coffee@female@base')
    while true do
        local sleep = 1000
        if isLoggedIn and isCuffed then
            sleep = 0
            if isEscorting then
                DisableControlAction(0, 21)
                if not IsEntityAttachedToEntity(cuffedEntity, PlayerPedId()) then
                    AttachEntityToEntity(cuffedEntity, PlayerPedId(), 11816, 0.38, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
                end
                if not IsEntityPlayingAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', 3) then
                    TaskPlayAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', "base", 8.0, 8.0, -1, 50, 0, false, false, false)
                end
                if IsPedWalking(PlayerPedId()) then
                    if not IsEntityPlayingAnim(cuffedEntity, 'mp_arresting', 'walk', 3) then
                        TaskPlayAnim(cuffedEntity, 'mp_arresting', 'walk', 8.0, -8, -1, 1, 0.0, false, false, false)
                        SetPedKeepTask(cuffedEntity, true)
                    end
                elseif not IsPedWalking(PlayerPedId()) then
                    StopAnimTask(cuffedEntity, 'mp_arresting', 'walk', -8.0)
                    if not IsEntityPlayingAnim(cuffedEntity, 'mp_arresting', 'idle', 3) then
                        TaskPlayAnim(cuffedEntity, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
                        SetPedKeepTask(cuffedEntity, true)
                    end
                end
            elseif not isEscorting then
                if not IsEntityPlayingAnim(cuffedEntity, 'mp_arresting', 'idle', 3) then
                    TaskPlayAnim(cuffedEntity, 'mp_arresting', 'idle', 8.0, -8, -1, 16, 0.0, false, false, false)
                    SetPedKeepTask(cuffedEntity, true)
                end
            end
        end
        Wait(sleep)
    end
end)