import { Receive } from '@enums/events';
import type { DebugEventCallback } from '@typings/events';
import { ReceiveEvent } from './eventsHandlers';

const AlwaysListened: DebugEventCallback[] = [
    {
        action: Receive.visible,
        handler: () => {},
    },
];

export default AlwaysListened;

export function InitialiseListen() {
    for (const debug of AlwaysListened) {
        ReceiveEvent(debug.action, debug.handler);
    }
}
