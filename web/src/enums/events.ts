export enum Receive {
    visible = 'setVisible',
    setupCharacters = 'setupCharacters',
    setupSpawns = 'setupSpawns',
}

export enum Send {
    close = 'disconnect',
    previewCharacter = 'previewCharacter',
    playCharacter = 'playCharacter',
    createCharacter = 'createCharacter',
    deleteCharacter = 'deleteCharacter',
    previewSpawn = 'previewSpawn',
    confirmSpawn = 'confirmSpawn',
    spawnBack = 'spawnBack',
}
