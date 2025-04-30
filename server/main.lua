--- Get Points
---@param data table
local function GetPoints(data)
    local pts = data.arrested
    pts = pts - data.escaped
    pts = pts - data.failed
    pts = pts - data.deads
    return pts
end

local function isPlayeraCopBoss(src)
    local job = GetJob(src)
    if job.type == 'leo' and job.grade.isboss then return true end
    return false
end

local function isPlayeraCop(src)
    local job = GetJob(src)
    if job and job.type == 'leo' and job.grade.level >= 0 then return true end
    return false
end

--- Get Identifier
---@param src number
---@param idtype string
local function GetIdentifier(src, idtype)
    if GetConvarInt('sv_fxdkMode', 0) == 1 then return 'license:fxdk' end
    return GetPlayerIdentifierByType(src, idtype or 'license')
end

--- Update Job Rank
---@param src number
local function UpdateJobRank(src)
    local license = GetIdentifier(src, 'license')
    local query = MySQL.Sync.fetchAll('SELECT * FROM police_training WHERE license = ?', {license})
    if #query > 0 then
        for k, v in pairs(query) do
            local points = GetPoints(v)
            local job = GetJob(src)
            if Config.Points[job.grade.level] then
                local earnRank = Config.Points[job.grade.level].earnrank
                local minPoints = Config.Points[job.grade.level].minPoints
                if job.grade.level < earnRank and points >= minPoints then
                    SetJob(src, 'police', earnRank)
                end
            end
        end
    end
end

--- func desc
---@param src number
---@param action string
local function UpdatePlayer(src, action)
    local license = GetIdentifier(src, 'license')
    if isPlayeraCop(src) then
        local username = GetPlayerName(src)
        local target = MySQL.Sync.fetchScalar('SELECT license FROM police_training WHERE license = ? LIMIT 1', {license})
        if not target then MySQL.Async.execute("INSERT INTO police_training (license, username) VALUES (?, ?)", {license, username}) end
        if action == "arrested" then
            MySQL.Async.execute('UPDATE police_training SET arrested = arrested + 1, earned = earned + ? WHERE license = ?', {Config.Reward, license})
            AddMoney(src, 'bank', Config.Reward)
        elseif action == "escaped" then
            MySQL.Async.execute('UPDATE police_training SET escaped = escaped + 1, earned = earned - ? WHERE license = ?', {Config.Punishment, license})
            RemoveMoney(src, 'bank', Config.Punishment)
        elseif action == "failed" then
            MySQL.Async.execute('UPDATE police_training SET failed = failed + 1, earned = earned - ? WHERE license = ?', {Config.Punishment, license})
            RemoveMoney(src, 'bank', Config.Punishment)
        elseif action == "deads" then
            MySQL.Async.execute('UPDATE police_training SET deads = deads + 1, earned = earned - ? WHERE license = ?', {Config.Punishment, license})
            RemoveMoney(src, 'bank', Config.Punishment)
        end
        Wait(10)
        UpdateJobRank(src)
    end
end

--- Toggle Duty
---@param src number
local function ToggleDuty(src)
    local isCop = isPlayeraCop(src)
    if isCop then TriggerClientEvent('mh-policetraining:client:toggleduty', src) end
end

RegisterServerEvent('mh-policetraining:server:GetData', function()
    local src = source
    local license = GetIdentifier(src, 'license')
    local data = {}
    local query = nil
    local isCop = isPlayeraCop(src)
    local isCopBoss = isPlayeraCopBoss(src)
    if isCop then query = MySQL.Sync.fetchAll('SELECT * FROM police_training WHERE license = ?', {license}) end
    if isCopBoss then query = MySQL.Sync.fetchAll('SELECT * FROM police_training', {}) end
    if #query > 0 then

        local player = MySQL.Sync.fetchAll('SELECT * FROM players WHERE license = ?', {license})[1]
        local job = json.decode(player.job)

        for _, v in pairs(query) do
            local pts = GetPoints(v)
            data[#data + 1] = {
                id = v.id, 
                license = v.license, 
                username = v.username or 'unknow', 
                arrested = v.arrested or 0, 
                escaped = v.escaped or 0, 
                damages = v.damages or 0, 
                failed = v.failed or 0, 
                deads = v.deads or 0, 
                earned = v.earned or 0,
                job = {name = job.label, level = job.level or 0},
                points = pts
            }
        end
    end
    TriggerClientEvent('mh-policetraining:client:ReceiveData', src, data)
end)

RegisterServerEvent('mh-policetraining:server:ToggleDuty', function()
    local src = source
    ToggleDuty(src)
end)

RegisterServerEvent('mh-policetraining:server:update_arrested', function()
    local src = source
    UpdatePlayer(src, 'arrested')
end)

RegisterServerEvent('mh-policetraining:server:update_escaped', function()
    local src = source
    UpdatePlayer(src, 'escaped')
end)

RegisterServerEvent('mh-policetraining:server:update_failed', function()
    local src = source
    UpdatePlayer(src, 'failed')
end)

RegisterServerEvent('mh-policetraining:server:update_deads', function()
    local src = source
    UpdatePlayer(src, 'deads')
end)

RegisterServerEvent('mh-policetraining:server:onjoin', function()
    local src = source
    TriggerClientEvent('mh-policetraining:client:onjoin', src, SV_Config)
end)

CreateThread(function()
    Wait(5100)
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_training` (
            `id` int(10) NOT NULL AUTO_INCREMENT,
            `license` varchar(255) NOT NULL,
            `username` varchar(255) NOT NULL,
            `arrested` int(11) DEFAULT 0,
            `escaped` int(11) DEFAULT 0,
            `failed` int(11) DEFAULT 0,
            `deads` int(11) DEFAULT 0,
            `earned` int(11) DEFAULT 0,
            PRIMARY KEY (`id`) USING BTREE
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;     
    ]])
end)