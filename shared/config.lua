Config = Config or {}

-- 'auto' | 'qbcore' | 'qbox' | 'esx' | 'custom'
Config.Framework = 'qbox'

Config.ServerName = 'Server Name'
Config.EnableDeleteButton = true
Config.DefaultNumberOfCharacters = 6
Config.SkipSelection = false -- uses last spawn if true
Config.DefaultNationality = 'United States'

Config.PlayersNumberOfCharacters = {
    -- { license = 'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', numberOfChars = 5 },
}

Config.Identity = {
    minHeight = 60,
    maxHeight = 80,
    defaultHeight = 72,
    minAge = 18,
}
