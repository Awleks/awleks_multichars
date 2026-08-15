# Awleks Multicharacter

Character selection, identity creation, and spawn selection in one resource.

Works with **ESX**, **QBCore**, and **Qbox**.

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)

Uncomment the matching framework import in `fxmanifest.lua`.

## Config

### `shared/config.lua`

Framework, server name, character slots, identity limits.

```lua
Config.Framework = 'auto' -- auto | qbcore | qbox | esx | custom
Config.DefaultNumberOfCharacters = 6
Config.SkipSelection = false -- skip spawn UI, use last location
```

### `shared/theme.lua`

UI colors.

```lua
Config.Theme = {
    accent = '#2563EB',
    surface = '#0E0E10',
    fade = '#111111',
    fadeOpacity = 0.80,
    danger = '#F87171',
    textMuted = '#9CA3AF',
}
```

### `shared/locations.lua`

Character selection scenes. Change `Config.SelectedLocation` (1–5) or add your own cameras/peds.

### `shared/spawns.lua`

Public spawn points and job-only spawns.

```lua
Config.Spawns = { ... }
Config.JobSpawns = { ... } -- shown only if the character has that job
```

### `shared/integrations.lua`

Apartments, housing, appearance, weather, starter items.

### `shared/nationalities.lua`

Nationality list used on the identity screen.
