Config = Config or {}

-- Used after first-character creation when apartments are disabled
Config.DefaultSpawn = vector4(-421.4744, 1174.5350, 325.8398, 336.6800)

Config.Spawns = {
    legion = {
        location = 'legion',
        coords = vector4(195.17, -933.77, 30.69, 144.5),
        ped = vector4(195.17, -933.77, 30.69, 144.5),
        label = 'Legion Square',
        description = 'The heart of downtown Los Santos. Street performers, late-night crowds, and the city waking up around you.',
        type = 'normal',
        image = 'images/spawn-legion.png',
    },
    jewelry = {
        location = 'jewelry',
        coords = vector4(-630.5, -236.86, 38.06, 212.64),
        ped = vector4(-630.5, -236.86, 38.06, 212.64),
        label = 'Rockford Hills',
        description = 'High-end storefronts, quiet money, and a polished stretch of Rockford where the city puts on its best face.',
        type = 'normal',
        image = 'images/spawn-jewelry.png',
    },
    beach = {
        location = 'beach',
        coords = vector4(-1483.53, -1014.91, 6.27, 317.5),
        ped = vector4(-1483.53, -1014.91, 6.27, 317.5),
        label = 'Vespucci Beach',
        description = 'Salt air, neon, and the boardwalk after dark. Start by the water and work your way back into the city.',
        type = 'normal',
        image = 'images/spawn-beach.png',
    },
}

Config.JobSpawns = {
    police = {
        location = 'police',
        coords = vector4(428.23, -984.28, 30.71, 3.5),
        ped = vector4(428.23, -984.28, 30.71, 3.5),
        label = 'Mission Row PD',
        description = 'Report in at Mission Row. The city does not police itself.',
        type = 'job',
        image = 'images/spawn-police.png',
        job = 'police',
    },
    ambulance = {
        location = 'ambulance',
        coords = vector4(298.29, -584.36, 43.26, 70.5),
        ped = vector4(298.29, -584.36, 43.26, 70.5),
        label = 'Pillbox Hospital',
        description = 'Clock in at Pillbox. Someone always needs a medic.',
        type = 'job',
        image = 'images/spawn-hospital.png',
        job = 'ambulance',
    },
}
