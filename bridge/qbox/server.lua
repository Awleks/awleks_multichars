if Bridge.Framework ~= 'qbox' then return end

local ready = {}

local function waitReady(src)
    local timeout = GetGameTimer() + 10000
    while not ready[src] and GetGameTimer() < timeout do
        Wait(10)
    end
end

function Bridge.GetCharacters(src)
    local license = Bridge.GetLicense(src)
    local license2 = GetPlayerIdentifierByType(src, 'license2')
    local result = MySQL.query.await(
        'SELECT citizenid, cid, charinfo, money, job, position FROM players WHERE license = ? OR license = ? ORDER BY cid',
        { license, license2 or license }
    ) or {}
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

local function deleteQboxCharacterData(citizenid)
    local ok, config = pcall(function()
        return require '@qbx_core.config.server'
    end)

    local queries = {}
    if ok and config.characterDataTables then
        for i = 1, #config.characterDataTables do
            local tableName = config.characterDataTables[i][1]
            local columnName = config.characterDataTables[i][2]
            queries[#queries + 1] = {
                query = ('DELETE FROM `%s` WHERE `%s` = ?'):format(tableName, columnName),
                values = { citizenid },
            }
        end
    else
        queries = {
            { query = 'DELETE FROM properties WHERE owner = ?', values = { citizenid } },
            { query = 'DELETE FROM playerskins WHERE citizenid = ?', values = { citizenid } },
            { query = 'DELETE FROM players WHERE citizenid = ?', values = { citizenid } },
        }
    end

    return MySQL.transaction.await(queries) ~= nil
end

function Bridge.DeleteCharacter(src, citizenid)
    if not citizenid or citizenid == '' then return false end

    local license = GetPlayerIdentifierByType(src, 'license')
    local license2 = GetPlayerIdentifierByType(src, 'license2')
    local ownerLicense = MySQL.scalar.await('SELECT license FROM players WHERE citizenid = ?', { citizenid })

    if not ownerLicense or (ownerLicense ~= license and ownerLicense ~= license2) then
        return false
    end

    return deleteQboxCharacterData(citizenid)
end

function Bridge.LoginExisting(src, character)
    if not character or not character.citizenid then return false end
    if not exports.qbx_core:Login(src, character.citizenid) then return false end
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

    if not exports.qbx_core:Login(src, nil, newData) then return false end
    waitReady(src)
    return true
end

function Bridge.Logout(src)
    exports.qbx_core:Logout(src)
end

function Bridge.GiveStarterItems(src)
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local items = Config.StarterItems
    if not items then return end

    local data = Player.PlayerData
    local charinfo = data and data.charinfo or {}

    for _, item in pairs(items) do
        local name = item.name or item.item
        local amount = item.amount or 1
        if name then
            local metadata = item.metadata
            if name == 'id_card' then
                metadata = {
                    citizenid = data.citizenid,
                    firstname = charinfo.firstname,
                    lastname = charinfo.lastname,
                    birthdate = charinfo.birthdate,
                    gender = charinfo.gender,
                    nationality = charinfo.nationality,
                }
            elseif name == 'driver_license' then
                metadata = {
                    firstname = charinfo.firstname,
                    lastname = charinfo.lastname,
                    birthdate = charinfo.birthdate,
                    type = 'Class C Driver License',
                }
            end

            if GetResourceState('ox_inventory') == 'started' then
                exports.ox_inventory:AddItem(src, name, amount, metadata)
            elseif Player.Functions and Player.Functions.AddItem then
                Player.Functions.AddItem(name, amount, false, metadata)
            end
        end
    end
end

function Bridge.OnLoaded(src)
    Bridge.LoadHousing(src)
end

function Bridge.RegisterCommands()
    lib.addCommand('logout', {
        help = 'Logout of current character',
        restricted = 'group.admin',
    }, function(source)
        Bridge.Logout(source)
        TriggerClientEvent('awleks_multichar:client:chooseChar', source)
    end)

    lib.addCommand('closeNUI', {
        help = 'Close character NUI',
    }, function(source)
        TriggerClientEvent('awleks_multichar:client:closeNUI', source)
    end)
end

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    Wait(1000)
    local src = Player and (Player.PlayerData and Player.PlayerData.source or Player.source) or source
    if src then ready[src] = true end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    ready[source] = true
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    ready[src] = false
end)

Bridge.RegisterCommands()
