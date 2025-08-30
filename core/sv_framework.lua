Framework = nil
CreateCallback = nil

if GetResourceState("es_extended") ~= 'missing' then
    Framework = exports['es_extended']:getSharedObject()
    CreateCallback = Framework.RegisterServerCallback
    function GetPlayer(source)
        return Framework.GetPlayerFromId(source)
    end

    function GetMoney(source, account)
        local xPlayer = GetPlayer(source)
        return xPlayer.getAccount(account).money
    end

    function AddMoney(source, account, amount)
        local xPlayer = GetPlayer(source)
        return xPlayer.addMoney(account, amount)
    end

    function RemoveMoney(source, account, amount, reason)
        local xPlayer = GetPlayer(source)
        local last = xPlayer.getAccount(account).money
        xPlayer.removeAccountMoney(account, amount, reason)
        local current = xPlayer.getAccount(account).money
        if current < last then return true else return false end
    end

    function SetJob(source, job, grade)
        local xPlayer = GetPlayer(source)
        if Framework.DoesJobExist(job, grade) then xPlayer.setJob(job, grade) end
    end

    function GetJob(source)
        local xPlayer = GetPlayer(source)
        return xPlayer.job
    end

elseif GetResourceState("qb-core") ~= 'missing' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    
    function GetPlayer(source)
        return Framework.Functions.GetPlayer(source)
    end

    function AddMoney(source, account, amount)
        local Player = GetPlayer(source)
        if account == 'bank' then
            return Player.Functions.AddMoney('bank', amount)
        elseif account == 'cash' then
            return Player.Functions.AddMoney('cash', amount)
        elseif account == 'blackmoney' then
            return Player.Functions.AddMoney('blackmoney', amount)
        end
    end

    function GetMoney(source, account)
        local Player = GetPlayer(source)
        if account == 'bank' then
            return Player.PlayerData.money.bank
        elseif account == 'cash' then
            return Player.PlayerData.money.cash
        elseif account == 'blackmoney' then
            return Player.PlayerData.money.blackmoney
        end
    end

    function RemoveMoney(source, account, amount, reason)
        local Player = GetPlayer(source)
        if account == 'bank' then
            return Player.Functions.RemoveMoney('bank', amount, reason)
        elseif account == 'cash' then
            return Player.Functions.RemoveMoney('cash', amount, reason)
        elseif account == 'blackmoney' then
            return Player.Functions.RemoveMoney('blackmoney', amount, reason)
        end
    end

    function SetJob(source, job, grade)
        local Player = GetPlayer(source)
        Player.Functions.SetJob(job, grade)
    end

    function GetJob(source)
        local Player = GetPlayer(source)
        if not Player then return end
        return Player.PlayerData.job
    end
end