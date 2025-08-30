Framework = nil
TriggerCallback = nil
OnPlayerLoaded = nil
OnPlayerUnload = nil
OnJobUpdate = nil
PlayerData = {}
isLoggedIn = false

if GetResourceState("es_extended") ~= 'missing' then
    Framework = exports['es_extended']:getSharedObject()
    OnPlayerLoaded = 'esx:playerLoaded'
    OnPlayerUnload = 'esx:playerUnLoaded'
    OnJobUpdate = 'esx:setJob'
    TriggerCallback = Framework.TriggerServerCallback

    function GetPlayerData()
        TriggerCallback('esx:getPlayerData', function(data)
            PlayerData = data
        end)
        return PlayerData
    end

elseif GetResourceState("qb-core") ~= 'missing' then
    Framework = exports['qb-core']:GetCoreObject()
    OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    OnPlayerUnload = 'QBCore:Client:OnPlayerUnload'
    OnJobUpdate = "QBCore:Client:OnJobUpdate"
    TriggerCallback = Framework.Functions.TriggerCallback

    function GetPlayerData()
        return Framework.Functions.GetPlayerData()
    end
end

function IsDriver(ped, vehicle)
    return (GetPedInVehicleSeat(vehicle, -1) == ped)
end

function Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if GetResourceState('progressbar') ~= 'missing' then
        exports['progressbar']:Progress(
            {
                name = name:lower(),
                duration = duration,
                label = label,
                useWhileDead = useWhileDead,
                canCancel = canCancel,
                controlDisables = disableControls,
                animation = animation,
                prop = prop,
                propTwo = propTwo
            }, function(cancelled)
            if not cancelled then
                if onFinish then
                    onFinish()
                end
            else
                if onCancel then
                    onCancel()
                end
            end
        end)
    elseif GetResourceState('ox_lib') ~= 'missing' then
        local progressbar = lib.progressBar({duration = duration, label = label, useWhileDead = false, canCancel = true, disable = { car = true, }, anim = animation, prop = { model = prop, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) }, })
        if progressbar then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
    end
end