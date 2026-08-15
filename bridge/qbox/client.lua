if Bridge.Framework ~= 'qbox' then return end

function Bridge.GetPlayerData()
    if QBX and QBX.PlayerData then
        return QBX.PlayerData
    end

    local ok, data = pcall(function()
        return exports.qbx_core:GetPlayerData()
    end)

    return ok and data or nil
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

