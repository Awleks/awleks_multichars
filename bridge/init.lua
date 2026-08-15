Bridge = Bridge or {}

local function resourceReady(name)
    if GetResourceState(name) == 'started' then
        return true
    end

    if not IsDuplicityVersion() then
        local ok = pcall(function()
            local resourceExports = exports[name]
            if name == 'illenium-appearance' or name == 'fivem-appearance' then
                return resourceExports.setPedAppearance ~= nil
            end
            if name == 'rcore_clothing' then
                return resourceExports.setPedSkin ~= nil
            end
            return resourceExports ~= nil
        end)
        if ok then return true end
    end

    return false
end

local function firstStarted(names)
    for i = 1, #names do
        if resourceReady(names[i]) then
            return names[i]
        end
    end
    return nil
end

local function isAuto(setting)
    return setting == true or setting == 'auto'
end

local function isFrameworkStarted(name)
    return GetResourceState(name) == 'started'
end

local function detectFramework()
    local configured = Config.Framework
    if configured and configured ~= 'auto' then
        return configured
    end
    if isFrameworkStarted('qbx_core') then return 'qbox' end
    if isFrameworkStarted('es_extended') then return 'esx' end
    if isFrameworkStarted('qb-core') then return 'qbcore' end
    return 'custom'
end

local weatherMap = {
    auto = { 'Renewed-Weathersync', 'renewed-weathersync', 'qb-weathersync', 'qbx_weathersync', 'vSync', 'vsync', 'cd_easytime', 'weathersync' },
    ['qb-weathersync'] = { 'qb-weathersync' },
    ['qbx_weathersync'] = { 'qbx_weathersync', 'qb-weathersync' },
    ['renewed-weathersync'] = { 'Renewed-Weathersync', 'renewed-weathersync' },
    renewed = { 'Renewed-Weathersync', 'renewed-weathersync' },
    vsync = { 'vSync', 'vsync' },
    ['cd_easytime'] = { 'cd_easytime' },
    weathersync = { 'weathersync' },
}

local apartmentMap = {
    auto = { 'qbx_properties', 'qbx_apartments', 'qb-apartments', 'ps-housing', 'loaf_apartment', 'qs-housing', 'qs-apartments' },
    core = { 'qbx_properties', 'qbx_apartments', 'qb-apartments', 'ps-housing', 'loaf_apartment', 'qs-housing', 'qs-apartments' },
    ['qb-apartments'] = { 'qb-apartments' },
    ['qbx_apartments'] = { 'qbx_apartments', 'qb-apartments' },
    ['qbx_properties'] = { 'qbx_properties' },
    ['ps-housing'] = { 'ps-housing' },
    ['loaf_apartment'] = { 'loaf_apartment' },
    ['qs-housing'] = { 'qs-housing', 'qs-apartments' },
}

local housingMap = {
    auto = { 'ps-housing', 'qbx_properties', 'qb-houses', 'loaf_housing', 'qs-housing' },
    ['qb-houses'] = { 'qb-houses' },
    ['qbx_properties'] = { 'qbx_properties' },
    ['ps-housing'] = { 'ps-housing' },
    ['loaf_housing'] = { 'loaf_housing' },
    ['qs-housing'] = { 'qs-housing' },
}

local appearanceMap = {
    auto = { 'illenium-appearance', 'fivem-appearance', 'qb-clothing', 'rcore_clothing', 'esx_skin' },
    ['illenium-appearance'] = { 'illenium-appearance' },
    ['fivem-appearance'] = { 'fivem-appearance' },
    ['qb-clothing'] = { 'qb-clothing' },
    ['esx_skin'] = { 'esx_skin' },
    ['rcore_clothing'] = { 'rcore_clothing' },
}

local weatherKey = {
    ['Renewed-Weathersync'] = 'renewed',
    ['renewed-weathersync'] = 'renewed',
    ['qb-weathersync'] = 'qb-weathersync',
    ['qbx_weathersync'] = 'qbx_weathersync',
    ['vSync'] = 'vsync',
    vsync = 'vsync',
    cd_easytime = 'cd_easytime',
    weathersync = 'weathersync',
}

local apartmentKey = {
    ['qb-apartments'] = 'qb-apartments',
    qbx_apartments = 'qbx_apartments',
    qbx_properties = 'qbx_properties',
    ['ps-housing'] = 'ps-housing',
    loaf_apartment = 'loaf_apartment',
    ['qs-housing'] = 'qs-housing',
    ['qs-apartments'] = 'qs-housing',
}

local housingKey = {
    ['qb-houses'] = 'qb-houses',
    qbx_properties = 'qbx_properties',
    ['ps-housing'] = 'ps-housing',
    loaf_housing = 'loaf_housing',
    ['qs-housing'] = 'qs-housing',
}

local appearanceKey = {
    ['illenium-appearance'] = 'illenium-appearance',
    ['fivem-appearance'] = 'fivem-appearance',
    ['qb-clothing'] = 'qb-clothing',
    esx_skin = 'esx_skin',
    rcore_clothing = 'rcore_clothing',
}

local frameworkAutoPriority = {
    qbox = {
        weather = { 'Renewed-Weathersync', 'renewed-weathersync', 'qbx_weathersync', 'qb-weathersync' },
        apartments = { 'qbx_properties', 'qbx_apartments', 'qb-apartments', 'ps-housing' },
        housing = { 'qbx_properties', 'ps-housing', 'qb-houses' },
        appearance = { 'illenium-appearance', 'fivem-appearance', 'qb-clothing' },
    },
    esx = {
        weather = { 'Renewed-Weathersync', 'renewed-weathersync', 'qb-weathersync', 'qbx_weathersync' },
        apartments = { 'ps-housing' },
        housing = { 'ps-housing' },
        appearance = { 'illenium-appearance', 'esx_skin', 'fivem-appearance', 'rcore_clothing' },
    },
    qbcore = {
        weather = { 'Renewed-Weathersync', 'renewed-weathersync', 'qb-weathersync', 'qbx_weathersync' },
        apartments = { 'qb-apartments', 'qbx_apartments', 'ps-housing' },
        housing = { 'qb-houses', 'ps-housing', 'qbx_properties' },
        appearance = { 'illenium-appearance', 'fivem-appearance', 'qb-clothing' },
    },
}

local trackedResources = {}

local function trackResources(names)
    for i = 1, #names do
        trackedResources[names[i]] = true
    end
end

for _, names in pairs(weatherMap) do trackResources(names) end
for _, names in pairs(apartmentMap) do trackResources(names) end
for _, names in pairs(housingMap) do trackResources(names) end
for _, names in pairs(appearanceMap) do trackResources(names) end

local function prioritizedAutoList(kind, baseList)
    local priorities = frameworkAutoPriority[Bridge.Framework]
    if not priorities or not priorities[kind] then
        return baseList
    end

    local list = {}
    local seen = {}

    for i = 1, #priorities[kind] do
        local name = priorities[kind][i]
        list[#list + 1] = name
        seen[name] = true
    end

    for i = 1, #baseList do
        local name = baseList[i]
        if not seen[name] then
            list[#list + 1] = name
        end
    end

    return list
end

local function getQboxCoreConfig()
    local ok, config = pcall(function()
        return require '@qbx_core.config.client'
    end)
    return ok and config or nil
end

local function applyQboxApartmentPolicy()
    if Bridge.Framework ~= 'qbox' then return end

    local coreConfig = getQboxCoreConfig()
    local startingApartment = coreConfig and coreConfig.characters and coreConfig.characters.startingApartment
    Bridge.QboxStartingApartment = startingApartment

    if Config.Apartments == 'none' then
        Bridge.Apartments = 'none'
        Bridge.ApartmentResource = nil
        return
    end

    if Config.Apartments == 'core' or Config.Apartments == 'auto' then
        if startingApartment == false then
            Bridge.Apartments = 'none'
            Bridge.ApartmentResource = nil
            return
        end

        if startingApartment == true and Bridge.Apartments == 'none' and resourceReady('qbx_properties') then
            Bridge.Apartments = 'qbx_properties'
            Bridge.ApartmentResource = 'qbx_properties'
        end
    end
end

local function resolve(setting, map, keys, kind)
    if setting == false or setting == 'none' or setting == nil then
        return 'none', nil
    end
    if setting == true or setting == 'core' then
        setting = 'auto'
    end

    local names = map[setting] or map.auto
    if setting == 'auto' and kind then
        names = prioritizedAutoList(kind, names)
    end

    local resource = firstStarted(names)
    if not resource then
        return 'none', nil
    end
    return keys[resource] or resource, resource
end

function Bridge.ResourceStarted(name)
    return resourceReady(name)
end

function Bridge.RefreshIntegrations()
    Bridge.Framework = detectFramework()
    Bridge.Weather, Bridge.WeatherResource = resolve(Config.Weather, weatherMap, weatherKey, 'weather')
    Bridge.Apartments, Bridge.ApartmentResource = resolve(Config.Apartments, apartmentMap, apartmentKey, 'apartments')
    Bridge.Housing, Bridge.HousingResource = resolve(Config.Housing, housingMap, housingKey, 'housing')
    Bridge.Appearance, Bridge.AppearanceResource = resolve(Config.Appearance, appearanceMap, appearanceKey, 'appearance')
    applyQboxApartmentPolicy()
end

function Bridge.UseApartments()
    if Config.Apartments == 'none' then
        return false
    end

    if Bridge.Framework == 'qbox' then
        if Bridge.QboxStartingApartment == false then
            return false
        end
        if Config.Apartments == 'core' or Config.Apartments == 'auto' then
            return Bridge.QboxStartingApartment == true and Bridge.Apartments ~= 'none'
        end
    end

    return Bridge.Apartments ~= 'none'
end

local function needsRetry(setting, value)
    if setting == 'core' then
        if Bridge.Framework == 'qbox' and Bridge.QboxStartingApartment == false then
            return false
        end
        setting = 'auto'
    end
    return isAuto(setting) and value == 'none'
end

local function allAutoResolved()
    if needsRetry(Config.Weather, Bridge.Weather) then return false end
    if needsRetry(Config.Apartments, Bridge.Apartments) then return false end
    if needsRetry(Config.Housing, Bridge.Housing) then return false end
    if needsRetry(Config.Appearance, Bridge.Appearance) then return false end
    return true
end

local function integrationSummary()
    return ('^2[awleks_multichar]^7 Framework: ^5%s^7 | Weather: ^5%s^7 | Apartments: ^5%s^7 | Housing: ^5%s^7 | Appearance: ^5%s^7'):format(
        Bridge.Framework,
        Bridge.Weather,
        Bridge.Apartments,
        Bridge.Housing,
        Bridge.Appearance
    )
end

Bridge.RefreshIntegrations()

CreateThread(function()
    local lastSummary = integrationSummary()
    print(lastSummary)

    local deadline = GetGameTimer() + 30000
    while GetGameTimer() < deadline and not allAutoResolved() do
        Wait(500)
        Bridge.RefreshIntegrations()

        local summary = integrationSummary()
        if summary ~= lastSummary then
            print(summary)
            lastSummary = summary
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if not trackedResources[resource] then return end
    Bridge.RefreshIntegrations()
end)
