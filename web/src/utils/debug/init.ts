import { DebugAction } from '@typings/events';
import { toggleVisible } from './visibility';
import { DebugEventSend } from '@utils/eventsHandlers';
import { Receive } from '@enums/events';
import { mockCharacters, mockSpawns } from './mocks';

const InitDebug: DebugAction[] = [
    {
        label: 'Visible',
        action: () => {
            toggleVisible(true);
            DebugEventSend(Receive.setupCharacters, mockCharacters);
        },
        delay: 200,
    },
];

export default InitDebug;

export function InitialiseDebugSenders(): void {
    for (const debug of InitDebug) {
        setTimeout(() => {
            debug.action();
        }, debug.delay || 0);
    }
}
