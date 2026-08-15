function Bridge.GetLicense(src)
    return GetPlayerIdentifierByType(src, 'license')
end

function Bridge.GetCharacterLimit(src)
    local license = Bridge.GetLicense(src)
    local limit = Config.DefaultNumberOfCharacters
    if not Config.PlayersNumberOfCharacters then return limit end

    for _, player in pairs(Config.PlayersNumberOfCharacters) do
        if player.license == license then
            return player.numberOfChars
        end
    end

    return limit
end

function Bridge.OpenApartmentCreator(src, data)
    if not Bridge.UseApartments() then return end
    if Bridge.Apartments == 'qbx_properties' then return end

    local payload = { cid = data.cid, charinfo = data }

    if Bridge.Apartments == 'qb-apartments' or Bridge.Apartments == 'qbx_apartments' then
        TriggerClientEvent('apartments:client:setupSpawnUI', src, payload)
    elseif Bridge.Apartments == 'ps-housing' then
        TriggerClientEvent('ps-housing:client:setupSpawnUI', src, payload)
        TriggerClientEvent('apartments:client:setupSpawnUI', src, payload)
    elseif Bridge.Apartments == 'loaf_apartment' then
        TriggerClientEvent('loaf_apartment:spawnMenu', src, payload)
    elseif Bridge.Apartments == 'qs-housing' then
        TriggerClientEvent('qs-housing:client:CreateApartment', src, payload)
    end
end

function Bridge.LoadHousing(src)
    if Bridge.Housing == 'none' then return end

    if Bridge.Housing == 'qb-houses' then
        local ok, houses = pcall(function()
            return MySQL.query.await('SELECT * FROM houselocations', {})
        end)
        if not ok or not houses then return end

        local HouseGarages = {}
        local Houses = {}
        for _, row in pairs(houses) do
            local garage = row.garage and json.decode(row.garage) or {}
            Houses[row.name] = {
                coords = json.decode(row.coords),
                owned = tonumber(row.owned) == 1,
                price = row.price,
                locked = true,
                adress = row.label,
                tier = row.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[row.name] = {
                label = row.label,
                takeVehicle = garage,
            }
        end

        TriggerClientEvent('qb-garages:client:houseGarageConfig', src, HouseGarages)
        TriggerClientEvent('qb-houses:client:setHouseConfig', src, Houses)
        return
    end

    if Bridge.Housing == 'ps-housing' then
        TriggerClientEvent('ps-housing:client:setupReady', src)
        return
    end

    if Bridge.Housing == 'qbx_properties' then
        TriggerClientEvent('qbx_properties:client:setupProperties', src)
    end
end

