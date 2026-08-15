RegisterNetEvent('awleks_multichar:server:disconnect', function()
    DropPlayer(source, 'Disconnected')
end)

RegisterNetEvent('awleks_multichar:server:loadUserData', function(cData)
    local src = source
    if not cData or not cData.citizenid then return end
    if not Bridge.LoginExisting(src, cData) then return end

    print(('^2[awleks_multichar]^7 %s (ID: %s) loaded'):format(GetPlayerName(src), cData.citizenid))
    Bridge.OnLoaded(src)

    if Config.SkipSelection then
        local coords = type(cData.position) == 'string' and json.decode(cData.position) or cData.position
        TriggerClientEvent('awleks_multichar:client:spawnLastLocation', src, coords, cData)
    else
        TriggerClientEvent('awleks_multichar:client:setupSpawns', src, cData, false, nil)
        TriggerClientEvent('awleks_multichar:client:openSpawnUI', src, true)
    end
end)

RegisterNetEvent('awleks_multichar:server:createCharacter', function(data)
    local src = source
    if not data then return end

    local valid = false
    if type(data.nationality) == 'string' then
        for i = 1, #Nationalities do
            if Nationalities[i].name == data.nationality then
                valid = true
                break
            end
        end
    end
    if not valid then
        data.nationality = Config.DefaultNationality
    end

    if not Bridge.LoginNew(src, data) then return end

    print(('^2[awleks_multichar]^7 %s created a character'):format(GetPlayerName(src)))
    Bridge.OnLoaded(src)
    Bridge.GiveStarterItems(src)

    if Bridge.UseApartments() then
        if Bridge.Apartments == 'qbx_properties' then
            TriggerClientEvent('awleks_multichar:client:closeForQboxApartments', src)
        else
            TriggerClientEvent('awleks_multichar:client:closeNUI', src)
            Bridge.OpenApartmentCreator(src, data)
        end
    else
        TriggerClientEvent('awleks_multichar:client:closeNUIdefault', src)
    end
end)

lib.callback.register('awleks_multichar:server:GetCharacters', function(source)
    return {
        characters = Bridge.GetCharacters(source),
        maxChars = Bridge.GetCharacterLimit(source),
    }
end)

lib.callback.register('awleks_multichar:server:getSkin', function(_, citizenid)
    return Bridge.GetSkin(citizenid)
end)

lib.callback.register('awleks_multichar:server:deleteCharacter', function(source, citizenid)
    return Bridge.DeleteCharacter(source, citizenid)
end)
