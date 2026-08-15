import type { Character, IdentityConfig, Nationality, SpawnLocation, View } from '@typings/characters';
import { NATIONALITIES } from '@data/nationalities';

export const CONFIG = $state<any>({
    fallbackResourceName: 'awleks_multichar',
    allowEscapeKey: false,
});

export const RESOURCE_NAME: string = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'awleks_multichar';

export const IS_BROWSER: boolean = !(window as any).invokeNative;

class VisibleState {
    value = $state<boolean>(false);
}
export const VISIBLE = new VisibleState();

class AppStore {
    view = $state<View>('selection');
    serverName = $state('Server Name');
    enableDelete = $state(true);
    characters = $state<Character[]>([]);
    selectedCid = $state<number | null>(null);
    creatingCid = $state(1);
    identity = $state<IdentityConfig>({
        minHeight: 60,
        maxHeight: 80,
        defaultHeight: 72,
        minAge: 18,
    });
    locations = $state<SpawnLocation[]>([]);
    selectedSpawn = $state<string | null>(null);
    isNew = $state(false);
    nationalities = $state<Nationality[]>(NATIONALITIES);
    defaultNationality = $state('United States');
}

export const APP = new AppStore();
