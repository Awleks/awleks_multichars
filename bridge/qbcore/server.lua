if Bridge.Framework ~= 'qbcore' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local ready = {}

local function waitReady(src)
    local timeout = GetGameTimer() + 10000
    while not ready[src] and GetGameTimer() < timeout do
        Wait(10)
    end
end

function Bridge.GetCharacters(src)
    local license = QBCore.Functions.GetIdentifier(src, 'license')
    local result = MySQL.query.await('SELECT citizenid, cid, charinfo, money, job, position FROM players WHERE license = ? ORDER BY cid', { license }) or {}
    local characters = {}

    for i = 1, #result do
        result[i].cid = tonumber(result[i].cid) or i
        result[i].charinfo = json.decode(result[i].charinfo)
        result[i].money = json.decode(result[i].money)
        result[i].job = json.decode(result[i].job)
        characters[#characters + 1] = result[i]
    end

    return characters
end

function Bridge.GetSkin(citizenid)
    local result = MySQL.query.await('SELECT skin FROM playerskins WHERE citizenid = ? AND active = ?', { citizenid, 1 })
    if result and result[1] then
        return json.decode(result[1].skin)
    end
    return nil
end

function Bridge.DeleteCharacter(src, citizenid)
    if not citizenid or citizenid == '' then return false end
    MySQL.query.await('DELETE FROM players WHERE citizenid = ?', { citizenid })
    MySQL.query.await('DELETE FROM playerskins WHERE citizenid = ?', { citizenid })
    return true
end

function Bridge.LoginExisting(src, character)
    if not character or not character.citizenid then return false end
    if not QBCore.Player.Login(src, character.citizenid) then return false end
    waitReady(src)
    return true
end

function Bridge.LoginNew(src, data)
    local newData = {
        cid = data.cid,
        charinfo = {
            firstname = data.firstname,
            lastname = data.lastname,
            birthdate = data.birthdate,
            gender = data.gender == 'male' and 0 or 1,
            nationality = data.nationality,
            height = data.height,
        },
    }

    if not QBCore.Player.Login(src, false, newData) then return false end
    waitReady(src)
    return true
end

function Bridge.Logout(src)
    QBCore.Player.Logout(src)
end

function Bridge.GiveStarterItems(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not QBCore.Shared.StarterItems then return end

    for _, item in pairs(QBCore.Shared.StarterItems) do
        local info = {}
        if item.item == 'id_card' then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif item.item == 'driver_license' then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = 'Class C Driver License'
        end
        Player.Functions.AddItem(item.item, item.amount, false, info)
    end
end

function Bridge.OnLoaded(src)
    QBCore.Commands.Refresh(src)
    Bridge.LoadHousing(src)
end

function Bridge.RegisterCommands()
    QBCore.Commands.Add('logout', 'Logout of current character', {}, false, function(source)
        Bridge.Logout(source)
        TriggerClientEvent('awleks_multichar:client:chooseChar', source)
    end, 'admin')

    QBCore.Commands.Add('closeNUI', 'Close character NUI', {}, false, function(source)
        TriggerClientEvent('awleks_multichar:client:closeNUI', source)
    end)
end

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    Wait(1000)
    ready[Player.PlayerData.source] = true
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    ready[src] = false
end)

Bridge.RegisterCommands()
