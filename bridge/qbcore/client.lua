if Bridge.Framework ~= 'qbcore' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function Bridge.GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

function Bridge.GetJobName()
    local player = Bridge.GetPlayerData()
    return player and player.job and player.job.name or nil
end

function Bridge.GetLastPosition()
    local player = Bridge.GetPlayerData()
    return player and player.position or nil
end

function Bridge.GetInsideMeta()
    local player = Bridge.GetPlayerData()
    return player and player.metadata and player.metadata.inside or {}
end

function Bridge.WaitForPlayerData()
    local timeout = GetGameTimer() + 5000
    while (not Bridge.GetPlayerData() or not Bridge.GetJobName()) and GetGameTimer() < timeout do
        Wait(50)
    end
end

