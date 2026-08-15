local spawnCam = nil
local choosingSpawn = false
local currentCharacter = nil
local spawnLocations = {}
local apartmentLocations = {}
local spawnIsNew = false
local previewGen = 0

local function setSpawnUi(visible)
    choosingSpawn = visible
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        action = 'setVisible',
        data = visible,
    })
end

local function stopSceneLoad()
    if IsNewLoadSceneActive() then
        NewLoadSceneStop()
    end
end

local function beginStream(coords, gen)
    if not coords then return end

    local x = coords.x + 0.0
    local y = coords.y + 0.0
    local z = coords.z + 0.0
    local ped = PlayerPedId()

    stopSceneLoad()
    ClearHdArea()
    SetFocusPosAndVel(x, y, z, 0.0, 0.0, 0.0)
    SetHdArea(x, y, z, 120.0)
    RequestCollisionAtCoord(x, y, z)
    RequestAdditionalCollisionAtCoord(x, y, z)

    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    FreezeEntityPosition(ped, true)

    CreateThread(function()
        local interior = GetInteriorAtCoords(x, y, z)
        if interior and interior ~= 0 then
            PinInteriorInMemory(interior)
            LoadInterior(interior)
        end

        NewLoadSceneStartSphere(x, y, z, 80.0, 0)

        local timeout = GetGameTimer() + 5000
        while gen == previewGen and not IsNewLoadSceneLoaded() and GetGameTimer() < timeout do
            RequestCollisionAtCoord(x, y, z)
            Wait(0)
        end
        stopSceneLoad()

        while gen == previewGen and not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
            RequestCollisionAtCoord(x, y, z)
            Wait(50)
        end
    end)
end

local function destroySpawnCam()
    previewGen = previewGen + 1
    stopSceneLoad()
    ClearHdArea()
    ClearFocus()
    if spawnCam then
        RenderScriptCams(false, true, 800, true, true)
        SetCamActive(spawnCam, false)
        DestroyCam(spawnCam, true)
        spawnCam = nil
    end
end

local function openSpawnCam()
    destroySpawnCam()
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    spawnCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', -812.23, 182.54, 250.0, -85.0, 0.0, 0.0, 70.0, false, 0)
    SetCamActive(spawnCam, true)
    RenderScriptCams(true, true, 1200, true, true)
end

local function moveCam(coords)
    if not spawnCam or not coords then return end

    previewGen = previewGen + 1
    local gen = previewGen
    beginStream(coords, gen)

    local current = GetCamCoord(spawnCam)
    local rot = GetCamRot(spawnCam, 2)
    local fov = GetCamFov(spawnCam)
    local flyZ = 250.0

    if current.z < flyZ - 20.0 then
        SetCamParams(spawnCam, current.x, current.y, flyZ, -85.0, rot.y, rot.z, 70.0, 800, 0, 0, 2)
        Wait(800)
        if gen ~= previewGen or not spawnCam then return end
        current = GetCamCoord(spawnCam)
        rot = GetCamRot(spawnCam, 2)
        fov = GetCamFov(spawnCam)
    end

    SetCamParams(spawnCam, coords.x, coords.y, flyZ, rot.x, rot.y, rot.z, fov, 900, 0, 0, 2)
    Wait(900)
    if gen ~= previewGen or not spawnCam then return end
    SetCamParams(spawnCam, coords.x, coords.y, coords.z + 18.0, -35.0, rot.y, rot.z, 50.0, 1100, 0, 0, 2)
end

local function collectSpawns(isNew, apartments)
    local locations = {}

    if isNew and apartments then
        for key, value in pairs(apartments) do
            locations[#locations + 1] = {
                location = key,
                key = key,
                coords = value.coords and value.coords.enter or value.coords,
                label = value.label,
                description = value.description or 'Starting apartment',
                type = 'apartment',
                image = value.image or 'images/spawn-legion.png',
            }
        end
        apartmentLocations = apartments
        return locations
    end

    for key, spawn in pairs(Config.Spawns) do
        locations[#locations + 1] = {
            location = spawn.location or key,
            key = spawn.location or key,
            coords = spawn.coords,
            label = spawn.label,
            description = spawn.description,
            type = spawn.type or 'normal',
            image = spawn.image,
        }
    end

    local jobName = Bridge.GetJobName()
    if jobName and Config.JobSpawns then
        for _, spawn in pairs(Config.JobSpawns) do
            if spawn.job == jobName then
                locations[#locations + 1] = {
                    location = spawn.location,
                    key = spawn.location,
                    coords = spawn.coords,
                    label = spawn.label,
                    description = spawn.description,
                    type = 'job',
                    image = spawn.image,
                }
            end
        end
    end

    return locations
end

local function openSpawnSelector(cData, isNew, apartments)
    currentCharacter = cData
    spawnLocations = collectSpawns(isNew, apartments)

    DoScreenFadeOut(200)
    Wait(400)
    openSpawnCam()
    DoScreenFadeIn(400)

    SendNUIMessage({
        action = 'setupSpawns',
        data = {
            locations = spawnLocations,
            isNew = isNew and true or false,
            serverName = Config.ServerName,
            theme = Config.Theme,
        },
    })
    setSpawnUi(true)
end

RegisterNetEvent('awleks_multichar:client:openSpawnUI', function()
    Bridge.EnableWeather()
    Bridge.WaitForPlayerData()
    openSpawnSelector(currentCharacter, spawnIsNew, spawnIsNew and apartmentLocations or nil)
end)

RegisterNetEvent('awleks_multichar:client:setupSpawns', function(cData, new, apps)
    currentCharacter = cData
    spawnIsNew = new and true or false
    spawnLocations = collectSpawns(new, apps)
    SendNUIMessage({
        action = 'setupSpawns',
        data = {
            locations = spawnLocations,
            isNew = new and true or false,
            serverName = Config.ServerName,
            theme = Config.Theme,
        },
    })
end)

RegisterNetEvent('qb-houses:client:setHouseConfig', function()
    -- kept for qb-houses compatibility
end)

local function preSpawn()
    setSpawnUi(false)
    DoScreenFadeOut(400)
    Wait(400)
end

local function postSpawn()
    local ped = PlayerPedId()
    destroySpawnCam()
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    Wait(400)
    DoScreenFadeIn(600)
end

local function spawnAtCoords(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w or 0.0)
end

RegisterNUICallback('previewSpawn', function(data, cb)
    local location = data.location
    if not location then
        cb('ok')
        return
    end

    if location.type == 'last' then
        local coords = Bridge.GetLastPosition()
        if coords then
            moveCam(coords)
        end
    else
        local coords = location.coords
        if coords then
            moveCam(coords)
        end
    end
    cb('ok')
end)

RegisterNUICallback('confirmSpawn', function(data, cb)
    local location = data.location
    local spawnType = location and location.type or 'last'

    preSpawn()

    if spawnType == 'last' then
        spawnAtCoords(Bridge.GetLastPosition() or Config.DefaultSpawn)
        Bridge.EnterLastInterior()
    elseif spawnType == 'job' then
        local dest = Config.JobSpawns[location.key] or location
        spawnAtCoords(dest.ped or dest.coords)
        Bridge.SetOutsideMeta()
    elseif spawnType == 'apartment' then
        Bridge.CreateApartment(location)
    else
        local dest = Config.Spawns[location.key] or location
        spawnAtCoords(dest.ped or dest.coords)
        Bridge.SetOutsideMeta()
    end

    Bridge.NotifyPlayerLoaded()
    Wait(300)
    postSpawn()
    cb('ok')
end)

RegisterNUICallback('spawnBack', function(_, cb)
    setSpawnUi(false)
    destroySpawnCam()
    TriggerEvent('awleks_multichar:client:chooseChar')
    cb('ok')
end)

CreateThread(function()
    while true do
        if choosingSpawn then
            DisableAllControlActions(0)
            Wait(0)
        else
            Wait(500)
        end
    end
end)
