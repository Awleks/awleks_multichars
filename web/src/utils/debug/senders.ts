import { DebugItem } from '@typings/events';
import { toggleVisible } from './visibility';
import { Receive } from '@enums/events';
import { DebugEventSend } from '@utils/eventsHandlers';
import { APP } from '@stores/stores.svelte';
import { mockCharacters, mockSpawns } from './mocks';

const SendDebuggers: DebugItem[] = [
    {
        label: 'Visibility',
        actions: [
            {
                label: 'Show',
                action: () => toggleVisible(true),
            },
            {
                label: 'Hide',
                action: () => toggleVisible(false),
            },
        ],
    },
    {
        label: 'Screens',
        actions: [
            {
                label: 'Character Selection',
                action: () => {
                    toggleVisible(true);
                    DebugEventSend(Receive.setupCharacters, mockCharacters);
                },
            },
            {
                label: 'New Character',
                action: () => {
                    toggleVisible(true);
                    DebugEventSend(Receive.setupCharacters, mockCharacters);
                    APP.view = 'identity';
                },
            },
            {
                label: 'Spawn Selection',
                action: () => {
                    toggleVisible(true);
                    DebugEventSend(Receive.setupSpawns, mockSpawns);
                },
            },
        ],
    },
];

export default SendDebuggers;
