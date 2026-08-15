local previewCam = nil
local choosingCharacter = false
local transitioning = false
local dofThreadRunning = false
local previewPeds = {}
local previewProps = {}

local randomModels = { 'mp_m_freemode_01', 'mp_f_freemode_01' }

local function getScene()
    return Config.Locations[Config.SelectedLocation] or Config.Locations[1]
end

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) then return false end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
    return hash
end

local function requestAnimDict(animDict, timeout)
    if not animDict or type(animDict) ~= 'string' then return false end
    if HasAnimDictLoaded(animDict) then return true end
    if not DoesAnimDictExist(animDict) then return false end

    RequestAnimDict(animDict)
    local start = GetGameTimer()
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
        if timeout and (GetGameTimer() - start) >= timeout then
            return false
        end
    end
    return true
end

local function startDof(cam)
    local scene = getScene()
    SetCamNearDof(cam, scene.dofNear or 0.1)
    SetCamFarDof(cam, scene.dofFar or 5.0)
    SetCamDofStrength(cam, scene.dofStrength or 0.6)
    SetCamUseShallowDofMode(cam, true)

    if dofThreadRunning then return end
    dofThreadRunning = true

    CreateThread(function()
        while dofThreadRunning do
            if not transitioning then
                SetUseHiDof()
            end
            if not DoesCamExist(cam) then
                dofThreadRunning = false
                ClearFocus()
                return
            end
            Wait(0)
        end
    end)
end

local function moveCamera(coords, duration)
    if not coords then return end
    duration = duration or 2400

    if not previewCam or not DoesCamExist(previewCam) then
        previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', coords.x, coords.y, coords.z, -7.5, 0.0, coords.w, 60.0, false, 0)
        SetCamActive(previewCam, true)
        RenderScriptCams(true, true, 1000, true, true)
        startDof(previewCam)
        SetFocusArea(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
        return
    end

    RenderScriptCams(true, false, duration, true, false)
    transitioning = true
    SetCamParams(previewCam, coords.x, coords.y, coords.z + 0.5, -7.50235, 0.059666, coords.w, 60.0557, duration, 0, 0, 2)
    SetTimeout(duration, function()
        transitioning = false
    end)
    SetFocusArea(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
    startDof(previewCam)

    local interior = GetInteriorAtCoords(coords.x, coords.y, coords.z)
    if interior and interior ~= 0 then
        LoadInterior(interior)
    end
end

local function focusSlot(cid)
    local scene = getScene()
    local slot = scene.Ped and scene.Ped[tonumber(cid) or 1]
    if not slot then return end
    moveCamera(slot.camcoords, 2400)
end

local function destroyPreviewActors()
    for i = 1, #previewPeds do
        if DoesEntityExist(previewPeds[i]) then
            DeleteEntity(previewPeds[i])
        end
    end
    for i = 1, #previewProps do
        if DoesEntityExist(previewProps[i]) then
            DeleteEntity(previewProps[i])
        end
    end
    previewPeds = {}
    previewProps = {}
end

local function destroyCamera()
    dofThreadRunning = false
    transitioning = false
    if previewCam then
        RenderScriptCams(false, true, 800, true, true)
        SetCamActive(previewCam, false)
        DestroyCam(previewCam, true)
        previewCam = nil
    end
    ClearFocus()
end

local function setNui(visible)
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        action = 'setVisible',
        data = visible,
    })
end

local function applyAppearance(ped, skin)
    Bridge.ApplyAppearance(ped, skin)
end

local function playSlotAnim(ped, slot)
    if slot.scenario then
        TaskStartScenarioInPlace(ped, slot.scenario, 0, true)
        return
    end

    local dict = slot.animdict
    if dict and dict:find('WORLD_HUMAN') then
        TaskStartScenarioInPlace(ped, dict, 0, true)
        return
    end

    if requestAnimDict(dict, 2500) and slot.anim then
        Wait(50)
        TaskPlayAnim(ped, dict, slot.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
    end
end

local function attachSlotProp(ped, slot)
    local prop = slot.prop
    if not prop or not prop.model then return end

    local hash = loadModel(prop.model)
    if not hash then return end

    local object = CreateObject(hash, 0.0, 0.0, 0.0, false, false, false)
    AttachEntityToEntity(
        object,
        ped,
        GetPedBoneIndex(ped, prop.bone),
        prop.coords.X,
        prop.coords.Y,
        prop.coords.Z,
        prop.coords.XRot,
        prop.coords.YRot,
        prop.coords.ZRot,
        false,
        false,
        false,
        false,
        2,
        true
    )
    previewProps[#previewProps + 1] = object
    SetModelAsNoLongerNeeded(hash)
end

local function spawnSlotPed(cid, skin)
    local scene = getScene()
    local slot = scene.Ped and scene.Ped[cid]
    if not slot then return end

    local model = randomModels[math.random(#randomModels)]
    if skin then
        if type(skin) == 'table' and skin.model then
            model = skin.model
        elseif type(skin) == 'string' then
            local decoded = json.decode(skin)
            if decoded and decoded.model then
                model = decoded.model
                skin = decoded
            end
        end
    end

    local hash = loadModel(model)
    if not hash then return end

    local coords = slot.pedCoords
    local ped = CreatePed(2, hash, coords.x, coords.y, coords.z - 0.98, coords.w, false, true)
    SetPedComponentVariation(ped, 0, 0, 0, 2)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityCanBeDamaged(ped, false)
    SetPedCanRagdoll(ped, false)
    SetEntityCollision(ped, false, false)

    if skin then
        applyAppearance(ped, skin)
    else
        SetEntityAlpha(ped, 100, false)
    end

    attachSlotProp(ped, slot)
    playSlotAnim(ped, slot)
    SetModelAsNoLongerNeeded(hash)
    previewPeds[#previewPeds + 1] = ped
end

local function spawnAllPeds(slots)
    destroyPreviewActors()

    for _, character in ipairs(slots) do
        local cid = tonumber(character.cid) or 1
        local skin = nil
        if character.citizenid and not character.empty then
            skin = lib.callback.await('awleks_multichar:server:getSkin', false, character.citizenid)
        end
        spawnSlotPed(cid, skin)
    end
end

local function initStartCamera()
    destroyCamera()
    local scene = getScene()
    local startCoords = scene.StartCamCoords

    previewCam = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        startCoords.x,
        startCoords.y,
        startCoords.z,
        -3.0,
        0.0,
        startCoords.w,
        70.0,
        false,
        0
    )
    SetCamActive(previewCam, true)
    RenderScriptCams(true, false, 1, true, true)
    SetFocusPosAndVel(startCoords.x, startCoords.y, startCoords.z, 0.0, 0.0, 0.0)
end

local function closeMultichar(keepHidden)
    choosingCharacter = false
    setNui(false)
    destroyPreviewActors()
    destroyCamera()
    ClearTimecycleModifier()
    FreezeEntityPosition(PlayerPedId(), false)
    DisplayRadar(true)
    Bridge.EnableWeather()

    if not keepHidden then
        SetEntityVisible(PlayerPedId(), true, false)
        SetEntityInvincible(PlayerPedId(), false)
    end
end

local function buildCharacterSlots(characters, maxChars)
    local byCid = {}
    for _, character in pairs(characters or {}) do
        local cid = tonumber(character.cid) or 1
        character.cid = cid
        if character.charinfo and type(character.charinfo.gender) == 'number' then
            character.charinfo.gender = character.charinfo.gender == 0 and 'male' or 'female'
        end
        byCid[cid] = character
    end

    local slots = {}
    for i = 1, maxChars do
        if byCid[i] then
            slots[#slots + 1] = byCid[i]
        else
            slots[#slots + 1] = { cid = i, empty = true }
        end
    end
    return slots
end

local function openCharacterMenu()
    if choosingCharacter then return end
    choosingCharacter = true

    local scene = getScene()
    local hidden = scene.HiddenCoords

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeOut(10)
    DisplayRadar(false)
    Bridge.DisableWeather()

    Wait(500)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), hidden.x, hidden.y, hidden.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), hidden.w)
    SetEntityVisible(PlayerPedId(), false, false)
    SetEntityInvincible(PlayerPedId(), true)

    if scene.LoadInterior then
        local interior = GetInteriorAtCoords(scene.LoadInterior.x, scene.LoadInterior.y, scene.LoadInterior.z)
        if interior and interior ~= 0 then
            LoadInterior(interior)
            while not IsInteriorReady(interior) do
                Wait(10)
            end
        end
    end

    initStartCamera()
    DoScreenFadeIn(800)

    local payload = lib.callback.await('awleks_multichar:server:GetCharacters', false)
    local slots = buildCharacterSlots(payload.characters, payload.maxChars)
    spawnAllPeds(slots)

    local selectedCid = nil
    for _, character in ipairs(slots) do
        if not character.empty and character.citizenid then
            selectedCid = character.cid
            break
        end
    end
    selectedCid = selectedCid or (slots[1] and slots[1].cid) or 1

    SendNUIMessage({
        action = 'setupCharacters',
        data = {
            characters = slots,
            maxChars = payload.maxChars,
            serverName = Config.ServerName,
            enableDelete = Config.EnableDeleteButton,
            identity = Config.Identity,
            nationalities = Nationalities,
            defaultNationality = Config.DefaultNationality,
            theme = Config.Theme,
        },
    })
    setNui(true)

    moveCamera(scene.RotateInto, 2400)
    Wait(2400)
    if choosingCharacter then
        focusSlot(selectedCid)
    end
end

CreateThread(function()
    if GetResourceState('qb-multicharacter') == 'started' then
        print('^1[awleks_multichar]^7 Stop qb-multicharacter — this resource replaces it.')
    end
    if GetResourceState('qb-spawn') == 'started' then
        print('^1[awleks_multichar]^7 Stop qb-spawn — spawn selection is built in.')
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            Wait(500)
            TriggerEvent('awleks_multichar:client:chooseChar')
            return
        end
    end
end)

CreateThread(function()
    while true do
        if choosingCharacter then
            DisableAllControlActions(0)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('awleks_multichar:client:chooseChar', function()
    openCharacterMenu()
end)

RegisterNetEvent('awleks_multichar:client:closeNUI', function()
    closeMultichar(true)
end)

RegisterNetEvent('awleks_multichar:client:closeForQboxApartments', function()
    closeMultichar(false)
    DoScreenFadeOut(500)
    Wait(500)
    Bridge.NotifyPlayerLoaded()
end)

AddEventHandler('qb-clothes:client:CreateFirstCharacter', function()
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)
    ResetEntityAlpha(ped)
end)

RegisterNetEvent('awleks_multichar:client:closeNUIdefault', function()
    closeMultichar(false)
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), Config.DefaultSpawn.w)
    Bridge.SetOutsideMeta()
    Wait(500)
    SetEntityVisible(PlayerPedId(), true, false)
    Wait(500)
    DoScreenFadeIn(250)
    Bridge.EnableWeather()
    FreezeEntityPosition(PlayerPedId(), false)

    local function finishSpawn()
        Bridge.NotifyPlayerLoaded()
    end

    if Bridge.Framework == 'esx' then
        Bridge.WaitForPlayerData()
        Bridge.OpenAppearanceCreator(finishSpawn)
    else
        finishSpawn()
        Bridge.OpenAppearanceCreator()
    end
end)

RegisterNetEvent('awleks_multichar:client:spawnLastLocation', function(coords, cData)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w or 0.0)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)

    Bridge.EnterLastInterior()
    Bridge.NotifyPlayerLoaded()
    Wait(500)
    DoScreenFadeIn(250)
end)

RegisterNUICallback('previewCharacter', function(data, cb)
    focusSlot(data.cid)
    cb('ok')
end)

RegisterNUICallback('playCharacter', function(data, cb)
    local cData = data.character
    if not cData or not cData.citizenid then
        cb('error')
        return
    end

    closeMultichar(true)
    DoScreenFadeOut(250)
    TriggerServerEvent('awleks_multichar:server:loadUserData', cData)
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    local character = data.character
    if not character then
        cb('error')
        return
    end

    character.nationality = character.nationality or Config.DefaultNationality
    closeMultichar(true)
    DoScreenFadeOut(250)
    TriggerServerEvent('awleks_multichar:server:createCharacter', character)
    cb('ok')
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    if not data.citizenid or data.citizenid == '' then
        cb('error')
        return
    end

    local success = lib.callback.await('awleks_multichar:server:deleteCharacter', false, data.citizenid)
    if success then
        choosingCharacter = false
        destroyPreviewActors()
        destroyCamera()
        TriggerEvent('awleks_multichar:client:chooseChar')
    end
    cb(success and 'ok' or 'error')
end)

RegisterNUICallback('disconnect', function(_, cb)
    TriggerServerEvent('awleks_multichar:server:disconnect')
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeMultichar(false)
end)
