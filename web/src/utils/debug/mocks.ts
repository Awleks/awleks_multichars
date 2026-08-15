import type { SetupCharactersPayload, SetupSpawnsPayload } from '@typings/characters';
import { NATIONALITIES } from '@data/nationalities';
import { DEFAULT_THEME } from '@utils/theme';

export const mockCharacters: SetupCharactersPayload = {
    serverName: 'Server Name',
    enableDelete: true,
    maxChars: 4,
    defaultNationality: 'United States',
    nationalities: NATIONALITIES,
    theme: DEFAULT_THEME,
    identity: {
        minHeight: 60,
        maxHeight: 80,
        defaultHeight: 72,
        minAge: 18,
    },
    characters: [
        {
            cid: 1,
            citizenid: 'CRN12345',
            charinfo: {
                firstname: 'Awleks',
                lastname: 'Devs',
                birthdate: '03/14/1998',
                gender: 'male',
                nationality: 'United States',
            },
            money: { cash: 1250, bank: 18400 },
            job: { label: 'Unemployed', grade: { name: 'Civilian' } },
        },
        {
            cid: 2,
            empty: true,
        },
        {
            cid: 3,
            empty: true,
        },
        {
            cid: 4,
            empty: true,
        },
    ],
};

export const mockSpawns: SetupSpawnsPayload = {
    serverName: 'Server Name',
    isNew: false,
    theme: DEFAULT_THEME,
    locations: [
        {
            key: 'legion',
            location: 'legion',
            label: 'Legion Square',
            description:
                'The heart of downtown Los Santos. Street performers, late-night crowds, and the city waking up around you.',
            type: 'normal',
            image: 'images/spawn-legion.png',
        },
        {
            key: 'jewelry',
            location: 'jewelry',
            label: 'Rockford Hills',
            description:
                'High-end storefronts, quiet money, and a polished stretch of Rockford where the city puts on its best face.',
            type: 'normal',
            image: 'images/spawn-jewelry.png',
        },
        {
            key: 'beach',
            location: 'beach',
            label: 'Vespucci Beach',
            description:
                'Salt air, neon, and the boardwalk after dark. Start by the water and work your way back into the city.',
            type: 'normal',
            image: 'images/spawn-beach.png',
        },
    ],
};
