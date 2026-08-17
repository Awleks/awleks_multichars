local ResourceName = 'awleks_multichars'
local VersionCheckUrl = 'https://raw.githubusercontent.com/Awleks/version-check/refs/heads/main/multichar'
local DownloadUrl = 'https://github.com/Awleks/awleks_multichars'

local Changelog = {
    ['1.0.1'] = {
        'Fixed the appearance creator event not being registered as a net event, which caused "not safe for net" warnings and blocked character creation',
        'Fixed ESX characters not spawning at their last position because the client had no live position data',
    },
}

local function printChangelog(version)
    local notes = Changelog[version]
    if not notes then return end

    print(('^3[%s]^7 Changelog for v%s:'):format(ResourceName, version))
    for _, note in ipairs(notes) do
        print(('^3[%s]^7   - %s'):format(ResourceName, note))
    end
end

local function annoyingPrint()
    CreateThread(function()
        while true do
            Wait(5000)
            print(('^1Please rename %s back to its original name (%s) in order for it to function properly'):format(GetCurrentResourceName(), ResourceName))
        end
    end)
end

local function checkVersion(_, responseText)
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    local latestVersion = responseText and responseText:gsub('%s+', '')
    currentVersion = currentVersion and currentVersion:gsub('%s+', '')

    if not latestVersion or latestVersion == '' then
        print(('^1[%s]^7 Could not reach the version check server.'):format(ResourceName))
    elseif latestVersion ~= currentVersion then
        print(('^1[%s]^7 is outdated.\n^7Latest Version: ^2%s^7\n^7Current Version: ^1%s^7\n^7Download the new version at ^5%s'):format(ResourceName, latestVersion, currentVersion, DownloadUrl))
    else
        print(('^2[%s]^7 is up to date, have fun!'):format(ResourceName))
    end

    printChangelog(currentVersion)
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if GetCurrentResourceName() ~= ResourceName then
        annoyingPrint()
        return
    end

    Wait(5000)
    PerformHttpRequest(VersionCheckUrl, checkVersion, 'GET')
end)
