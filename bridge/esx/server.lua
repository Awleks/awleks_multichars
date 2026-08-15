if Bridge.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

local function accounts(raw)
    if type(raw) == 'string' then
        raw = json.decode(raw) or {}
    end
    raw = raw or {}
    if raw.money or raw.bank then
        return { cash = tonumber(raw.money) or 0, bank = tonumber(raw.bank) or 0 }
    end

    local cash, bank = 0, 0
    for _, account in pairs(raw) do
        if account.name == 'money' then cash = tonumber(account.money) or 0 end
        if account.name == 'bank' then bank = tonumber(account.money) or 0 end
    end
    return { cash = cash, bank = bank }
end

local function slotFromIdentifier(identifier)
    local slot = identifier and identifier:match('^char(%d+):')
    return tonumber(slot) or 1
end

local function genderFromSex(sex)
    if sex == 'f' or sex == 'female' or sex == 1 then return 'female' end
    return 'male'
end

function Bridge.GetCharacters(src)
    local identifier = ESX.GetIdentifier(src)
    local result = MySQL.query.await('SELECT * FROM users WHERE identifier LIKE ?', { ('char%%:%s'):format(identifier) }) or {}
    local characters = {}

    for i = 1, #result do
        local row = result[i]
        local cid = slotFromIdentifier(row.identifier)
        characters[#characters + 1] = {
            cid = cid,
            citizenid = row.identifier,
            charinfo = {
                firstname = row.firstname or 'Unknown',
                lastname = row.lastname or '',
                birthdate = row.dateofbirth or '',
                gender = genderFromSex(row.sex),
                nationality = row.nationality or Config.DefaultNationality,
                height = tonumber(row.height) or Config.Identity.defaultHeight,
            },
            money = accounts(row.accounts),
            job = {
                name = row.job or 'unemployed',
                label = row.job or 'Unemployed',
                grade = { name = tostring(row.job_grade or 0) },
            },
            position = type(row.position) == 'string' and json.decode(row.position) or row.position,
        }
    end

    return characters
end

function Bridge.GetSkin(citizenid)
    local result = MySQL.query.await('SELECT skin FROM users WHERE identifier = ?', { citizenid })
    if result and result[1] and result[1].skin then
        local skin = result[1].skin
        return type(skin) == 'string' and json.decode(skin) or skin
    end
    return nil
end

function Bridge.DeleteCharacter(src, citizenid)
    if not citizenid or citizenid == '' then return false end
    MySQL.query.await('DELETE FROM users WHERE identifier = ?', { citizenid })
    return true
end

function Bridge.LoginExisting(src, character)
    if not character or not character.citizenid then return false end
    local cid = character.cid or slotFromIdentifier(character.citizenid)
    TriggerEvent('esx:onPlayerJoined', src, ('char%s'):format(cid))
    Wait(500)
    return true
end

function Bridge.LoginNew(src, data)
    local identifier = ESX.GetIdentifier(src)
    local charId = ('char%s:%s'):format(data.cid, identifier)

    MySQL.insert.await(
        'INSERT INTO users (identifier, firstname, lastname, dateofbirth, sex, height, accounts) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            charId,
            data.firstname,
            data.lastname,
            data.birthdate,
            data.gender == 'male' and 'm' or 'f',
            data.height,
            json.encode({ money = 0, bank = 0 }),
        }
    )

    TriggerEvent('esx:onPlayerJoined', src, ('char%s'):format(data.cid), {
        firstname = data.firstname,
        lastname = data.lastname,
        dateofbirth = data.birthdate,
        sex = data.gender == 'male' and 'm' or 'f',
        height = data.height,
    })
    Wait(500)
    return true
end

function Bridge.Logout(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    TriggerClientEvent('awleks_multichar:client:chooseChar', src)
end

function Bridge.GiveStarterItems(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    -- add starter items here if you want them for ESX
end

function Bridge.OnLoaded(src)
    Bridge.LoadHousing(src)
end

function Bridge.RegisterCommands()
    ESX.RegisterCommand('logout', 'admin', function(xPlayer)
        local src = xPlayer.source
        TriggerClientEvent('awleks_multichar:client:chooseChar', src)
    end, false, { help = 'Logout of current character' })

    ESX.RegisterCommand('closeNUI', 'user', function(xPlayer)
        TriggerClientEvent('awleks_multichar:client:closeNUI', xPlayer.source)
    end, false, { help = 'Close character NUI' })
end

Bridge.RegisterCommands()
