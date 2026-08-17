if Bridge.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

function Bridge.GetPlayerData()
    return ESX.GetPlayerData()
end

function Bridge.GetJobName()
    local player = Bridge.GetPlayerData()
    return player and player.job and player.job.name or nil
end

function Bridge.GetLastPosition()
    local coords = Bridge.CurrentCharacter and Bridge.CurrentCharacter.position

    if not coords then
        local player = Bridge.GetPlayerData()
        coords = player and (player.coords or player.position)
    end
    if not coords then return nil end

    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = coords.heading or coords.w or 0.0,
    }
end

function Bridge.GetInsideMeta()
    return {}
end

function Bridge.WaitForPlayerData()
    local timeout = GetGameTimer() + 10000
    while GetGameTimer() < timeout do
        local data = Bridge.GetPlayerData()
        if data and data.identifier and data.sex then
            return
        end
        Wait(50)
    end
end

