local function resourceReady(name)
    if GetResourceState(name) == 'started' then
        return true
    end

    local ok = pcall(function()
        local resourceExports = exports[name]
        if name == 'illenium-appearance' or name == 'fivem-appearance' then
            return resourceExports.setPedAppearance ~= nil
        end
        return resourceExports ~= nil
    end)

    return ok
end

function Bridge.EnableWeather()
    local sys = Bridge.Weather
    if sys == 'none' then return end

    if sys == 'renewed' then
        pcall(function()
            exports[Bridge.WeatherResource]:setSyncEnabled(true)
        end)
        TriggerEvent('Renewed-Weathersync:client:EnableSync')
    elseif sys == 'qb-weathersync' then
        TriggerEvent('qb-weathersync:client:EnableSync')
        TriggerServerEvent('qb-weathersync:server:RequestStateSync')
    elseif sys == 'qbx_weathersync' then
        TriggerEvent('qbx_weathersync:client:EnableSync')
        TriggerEvent('qb-weathersync:client:EnableSync')
        TriggerServerEvent('qb-weathersync:server:RequestStateSync')
    elseif sys == 'vsync' then
        TriggerEvent('vSync:pauseSync', false)
        TriggerEvent('vSync:toggleSync', true)
    elseif sys == 'cd_easytime' then
        TriggerEvent('cd_easytime:PauseSync', false)
        pcall(function()
            exports.cd_easytime:PauseSync(false)
        end)
    elseif sys == 'weathersync' then
        TriggerEvent('weathersync:toggleSync', true)
    end
end

function Bridge.DisableWeather()
    local sys = Bridge.Weather
    if sys == 'none' then return end

    if sys == 'renewed' then
        pcall(function()
            exports[Bridge.WeatherResource]:setSyncEnabled(false)
        end)
        TriggerEvent('Renewed-Weathersync:client:DisableSync')
    elseif sys == 'qb-weathersync' then
        TriggerEvent('qb-weathersync:client:DisableSync')
    elseif sys == 'qbx_weathersync' then
        TriggerEvent('qbx_weathersync:client:DisableSync')
        TriggerEvent('qb-weathersync:client:DisableSync')
    elseif sys == 'vsync' then
        TriggerEvent('vSync:pauseSync', true)
        TriggerEvent('vSync:toggleSync', false)
    elseif sys == 'cd_easytime' then
        TriggerEvent('cd_easytime:PauseSync', true)
        pcall(function()
            exports.cd_easytime:PauseSync(true)
        end)
    elseif sys == 'weathersync' then
        TriggerEvent('weathersync:toggleSync', false)
    end
end

function Bridge.SetOutsideMeta()
    if Bridge.Housing == 'qb-houses' then
        TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    end
    if Bridge.Apartments == 'qb-apartments' or Bridge.Apartments == 'qbx_apartments' then
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    end
end

function Bridge.NotifyPlayerLoaded()
    if Bridge.Framework == 'esx' then
        TriggerEvent('esx:onPlayerSpawn')
        TriggerServerEvent('esx:onPlayerSpawn')
        return
    end
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
end

function Bridge.EnterLastInterior()
    local inside = Bridge.GetInsideMeta and Bridge.GetInsideMeta() or {}
    local propertyId = inside.propertyId or inside.property_id

    if (Bridge.Apartments == 'ps-housing' or Bridge.Housing == 'ps-housing') and propertyId then
        TriggerEvent('ps-housing:client:enterProperty', propertyId)
        return
    end

    if Bridge.Housing == 'qb-houses' and inside.house then
        TriggerEvent('qb-houses:client:LastLocationHouse', inside.house)
        return
    end

    if Bridge.Housing == 'qbx_properties' and inside.property then
        TriggerEvent('qbx_properties:client:enterProperty', inside.property)
        return
    end

    local apartment = inside.apartment
    if apartment and (apartment.apartmentType or apartment.apartmentId) then
        if Bridge.Apartments == 'qb-apartments' or Bridge.Apartments == 'qbx_apartments' then
            TriggerEvent('qb-apartments:client:LastLocationHouse', apartment.apartmentType, apartment.apartmentId)
        end
    end
end

function Bridge.CreateApartment(location)
    if not location then return end
    if Bridge.Apartments == 'qb-apartments' or Bridge.Apartments == 'qbx_apartments' then
        TriggerServerEvent('apartments:server:CreateApartment', location.key, location.label, true)
    elseif Bridge.Apartments == 'ps-housing' then
        TriggerServerEvent('ps-housing:server:createApartment', location.key, location.label)
    elseif Bridge.Apartments == 'loaf_apartment' then
        TriggerServerEvent('loaf_apartment:createApartment', location.key)
    elseif Bridge.Apartments == 'qs-housing' then
        TriggerServerEvent('qs-housing:server:CreateApartment', location.key, location.label)
    end
end

function Bridge.ApplyAppearance(ped, skin)
    if not skin or not ped then return end
    Bridge.RefreshIntegrations()
    local sys = Bridge.Appearance

    if sys == 'none' and resourceReady('illenium-appearance') then
        sys = 'illenium-appearance'
        Bridge.Appearance = sys
        Bridge.AppearanceResource = 'illenium-appearance'
    end

    if sys == 'illenium-appearance' then
        exports['illenium-appearance']:setPedAppearance(ped, skin)
    elseif sys == 'fivem-appearance' then
        exports['fivem-appearance']:setPedAppearance(ped, skin)
    elseif sys == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:loadPlayerClothing', skin, ped)
    elseif sys == 'rcore_clothing' then
        pcall(function()
            exports.rcore_clothing:setPedSkin(ped, skin)
        end)
    elseif sys == 'esx_skin' then
        TriggerEvent('skinchanger:loadSkin', skin)
    end
end

function Bridge.OpenAppearanceCreator(onFinished)
    Bridge.RefreshIntegrations()
    local sys = Bridge.Appearance

    if sys == 'none' and resourceReady('illenium-appearance') then
        sys = 'illenium-appearance'
        Bridge.Appearance = sys
        Bridge.AppearanceResource = 'illenium-appearance'
    end

    if sys == 'illenium-appearance' then
        if Bridge.Framework == 'esx' then
            TriggerEvent('esx_skin:openSaveableMenu', onFinished)
            return
        end
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    elseif sys == 'qb-clothing' then
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    elseif sys == 'fivem-appearance' then
        TriggerEvent('fivem-appearance:client:CreateFirstCharacter')
    elseif sys == 'esx_skin' then
        TriggerEvent('esx_skin:openSaveableMenu', onFinished)
    elseif sys == 'rcore_clothing' then
        TriggerEvent('rcore_clothing:openCreator')
    end
end

CreateThread(function()
    while Config.Appearance ~= 'none' and Bridge.Appearance == 'none' do
        Bridge.RefreshIntegrations()
        if Bridge.Appearance == 'none' and resourceReady('illenium-appearance') then
            Bridge.Appearance = 'illenium-appearance'
            Bridge.AppearanceResource = 'illenium-appearance'
        end
        if Bridge.Appearance ~= 'none' then break end
        Wait(500)
    end
end)
