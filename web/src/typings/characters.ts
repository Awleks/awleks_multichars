export type View = 'selection' | 'identity' | 'spawn';

export interface CharInfo {
    firstname: string;
    lastname: string;
    birthdate: string;
    gender: 'male' | 'female' | number;
    nationality?: string;
    height?: number;
    phone?: string;
    account?: string;
}

export interface Character {
    cid: number;
    citizenid?: string;
    empty?: boolean;
    charinfo?: CharInfo;
    money?: {
        cash: number;
        bank: number;
    };
    job?: {
        name?: string;
        label?: string;
        grade?: {
            name?: string;
            level?: number;
        };
    };
}

export interface Theme {
    accent: string;
    surface: string;
    fade: string;
    fadeOpacity: number;
    danger: string;
    textMuted: string;
}

export interface IdentityConfig {
    minHeight: number;
    maxHeight: number;
    defaultHeight: number;
    minAge: number;
}

export interface Nationality {
    name: string;
    code: string;
}

export interface SpawnLocation {
    key: string;
    location: string;
    label: string;
    description: string;
    type: 'normal' | 'job' | 'last' | 'apartment';
    image?: string;
    coords?: {
        x: number;
        y: number;
        z: number;
        w?: number;
    };
}

export interface SetupCharactersPayload {
    characters: Character[];
    maxChars: number;
    serverName: string;
    enableDelete: boolean;
    identity: IdentityConfig;
    nationalities?: Nationality[];
    defaultNationality?: string;
    theme?: Theme;
}

export interface SetupSpawnsPayload {
    locations: SpawnLocation[];
    isNew: boolean;
    serverName: string;
    theme?: Theme;
}

export interface CreateCharacterPayload {
    cid: number;
    firstname: string;
    lastname: string;
    gender: 'male' | 'female';
    birthdate: string;
    height: number;
    nationality?: string;
}
