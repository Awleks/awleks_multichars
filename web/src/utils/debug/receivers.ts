import { Send } from '@enums/events';
import { DebugEventCallback } from '@typings/events';
import { DebugEventReceive } from '@utils/eventsHandlers';

const ReceiveDebuggers: DebugEventCallback[] = [
    {
        action: Send.close,
        handler: () => console.log('[debug] disconnect'),
    },
    {
        action: Send.previewCharacter,
        handler: (data) => console.log('[debug] preview character', data),
    },
    {
        action: Send.playCharacter,
        handler: (data) => console.log('[debug] play character', data),
    },
    {
        action: Send.createCharacter,
        handler: (data) => console.log('[debug] create character', data),
    },
    {
        action: Send.deleteCharacter,
        handler: (data) => console.log('[debug] delete character', data),
    },
    {
        action: Send.previewSpawn,
        handler: (data) => console.log('[debug] preview spawn', data),
    },
    {
        action: Send.confirmSpawn,
        handler: (data) => console.log('[debug] confirm spawn', data),
    },
    {
        action: Send.spawnBack,
        handler: () => console.log('[debug] spawn back'),
    },
];

export default ReceiveDebuggers;

export function InitialiseDebugReceivers(): void {
    for (const debug of ReceiveDebuggers) {
        DebugEventReceive(debug.action, debug.handler);
    }
}
