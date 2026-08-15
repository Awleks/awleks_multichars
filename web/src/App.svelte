<script lang="ts">
    import { CONFIG, IS_BROWSER, VISIBLE, APP } from '@stores/stores.svelte';
    import { InitialiseListen } from '@utils/listeners';
    import { ReceiveEvent } from '@utils/eventsHandlers';
    import { Receive } from '@enums/events';
    import Visibility from '@providers/Visibility.svelte';
    import Identity from '@components/Identity.svelte';
    import Selection from '@components/Selection.svelte';
    import Spawn from '@components/Spawn.svelte';
    import type { SetupCharactersPayload, SetupSpawnsPayload } from '@typings/characters';
    import { applyTheme } from '@utils/theme';

    CONFIG.fallbackResourceName = 'awleks_multichar';
    CONFIG.allowEscapeKey = false;

    InitialiseListen();

    ReceiveEvent(Receive.setupCharacters, (payload: SetupCharactersPayload) => {
        APP.characters = payload.characters ?? [];
        APP.serverName = payload.serverName || 'Server Name';
        APP.enableDelete = payload.enableDelete !== false;
        APP.identity = payload.identity ?? APP.identity;
        APP.nationalities = payload.nationalities ?? APP.nationalities;
        APP.defaultNationality = payload.defaultNationality || APP.defaultNationality;
        applyTheme(payload.theme);
        APP.selectedCid = APP.characters.find((character) => !character.empty && character.citizenid)?.cid ?? null;
        APP.view = 'selection';
        VISIBLE.value = true;
    });

    ReceiveEvent(Receive.setupSpawns, (payload: SetupSpawnsPayload) => {
        APP.locations = Object.values(payload.locations ?? {});
        APP.isNew = !!payload.isNew;
        APP.serverName = payload.serverName || APP.serverName;
        APP.selectedSpawn = APP.isNew ? APP.locations[0]?.key ?? null : 'last';
        applyTheme(payload.theme);
        APP.view = 'spawn';
        VISIBLE.value = true;
    });
</script>

<Visibility>
    <div class="relative h-screen w-screen overflow-hidden">
        <div class="fade"></div>
        <div class="relative z-10 h-full pl-[4.3vw]">
            {#if APP.view === 'identity'}
                <Identity />
            {:else if APP.view === 'spawn'}
                <Spawn />
            {:else}
                <Selection />
            {/if}
        </div>
    </div>
</Visibility>

{#if import.meta.env.DEV}
    {#if IS_BROWSER}
        {#await import('./providers/Debug.svelte') then { default: Debug }}
            <Debug />
        {/await}
    {/if}
{/if}
