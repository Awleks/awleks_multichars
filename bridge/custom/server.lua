if Bridge.Framework ~= 'custom' then return end

function Bridge.GetCharacters(src)
    print('^1[awleks_multichar]^7 Custom bridge: implement Bridge.GetCharacters(src)')
    return {}
end

function Bridge.GetSkin(_)
    return nil
end

function Bridge.DeleteCharacter(_)
    print('^1[awleks_multichar]^7 Custom bridge: implement Bridge.DeleteCharacter(id)')
    return false
end

function Bridge.LoginExisting(_, _)
    print('^1[awleks_multichar]^7 Custom bridge: implement Bridge.LoginExisting(src, character)')
    return false
end

function Bridge.LoginNew(_, _)
    print('^1[awleks_multichar]^7 Custom bridge: implement Bridge.LoginNew(src, data)')
    return false
end

function Bridge.Logout(_) end

function Bridge.GiveStarterItems(_) end

function Bridge.OnLoaded(src)
    Bridge.LoadHousing(src)
end

function Bridge.RegisterCommands()
    RegisterCommand('logout', function(source)
        if source == 0 then return end
        TriggerClientEvent('awleks_multichar:client:chooseChar', source)
    end, true)

    RegisterCommand('closeNUI', function(source)
        if source == 0 then return end
        TriggerClientEvent('awleks_multichar:client:closeNUI', source)
    end, false)
end

Bridge.RegisterCommands()
