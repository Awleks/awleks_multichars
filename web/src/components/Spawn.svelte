<script lang="ts">
    import { APP } from '@stores/stores.svelte';
    import { Send } from '@enums/events';
    import { SendEvent } from '@utils/eventsHandlers';
    import ScreenHeader from '@components/ScreenHeader.svelte';
    import type { SpawnLocation } from '@typings/characters';

    const lastLocation: SpawnLocation = {
        key: 'last',
        location: 'last',
        label: 'Last Location',
        description: 'Return to where you left off',
        type: 'last',
    };

    const selected = $derived(
        APP.selectedSpawn === 'last'
            ? lastLocation
            : (APP.locations.find((location) => location.key === APP.selectedSpawn) ?? null),
    );

    function select(location: SpawnLocation) {
        APP.selectedSpawn = location.key;
        SendEvent(Send.previewSpawn, { location });
    }

    async function spawn() {
        if (!selected) return;
        await SendEvent(Send.confirmSpawn, { location: selected });
    }

    async function back() {
        await SendEvent(Send.spawnBack);
        APP.view = 'selection';
        APP.selectedSpawn = null;
    }
</script>

<button class="overlay-enter absolute right-[2.4vw] top-[3.4vh] z-5 h-[3.4vh] min-w-[5.2vw] cursor-pointer rounded-md border-0 bg-surface px-[1.1vw] text-[0.78vw] font-medium text-white" onclick={back}>
    Back
</button>

<section class="screen-enter flex h-full w-[22vw] min-w-[340px] max-w-[430px] flex-col py-[4.4vh]">
    <ScreenHeader
        serverName={APP.serverName}
        action="Select Your Location"
        title="Spawn Selection"
        subtitle="Select a Location"
    />

    {#if !APP.isNew}
        <button
            class="mb-[1.5vh] h-[4.3vh] w-full shrink-0 cursor-pointer rounded-md border-0 bg-surface text-[0.84vw] font-medium text-white outline outline-1 {APP.selectedSpawn === 'last' ? 'outline-white/35' : 'outline-transparent'}"
            onclick={() => select(lastLocation)}
        >
            Last Location
        </button>
    {/if}

    <div class="flex min-h-0 w-[calc(100%+0.45vw)] flex-1 flex-col gap-[1.5vh] overflow-y-auto pr-[0.45vw] [&::-webkit-scrollbar]:w-[3px] [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-white/80">
        {#each APP.locations as location (location.key)}
            <article class="relative shrink-0 overflow-hidden rounded-md bg-surface">
                <span class="select-bar absolute right-0 top-[12%] h-[76%] w-0.5 rounded-sm bg-white {APP.selectedSpawn === location.key ? 'opacity-100' : 'opacity-0'}"></span>
                <div class="h-[12.2vh] w-full bg-surface bg-cover bg-center" style={`background-image: url('${location.image ?? ''}')`}></div>
                <div class="px-[0.9vw] pb-[1.25vh] pt-[1.15vh]">
                    <h3 class="m-0 text-[0.95vw] font-bold tracking-[-0.02em] text-white">{location.label}</h3>
                    <p class="mb-[1.05vh] mt-[0.4vh] line-clamp-2 text-[0.62vw] leading-[1.45] text-white/70">{location.description}</p>
                    <button class="h-[3.4vh] w-full cursor-pointer rounded-[5px] border-0 bg-surface text-[0.74vw] font-medium text-white outline outline-1 outline-white/10" onclick={() => select(location)}>
                        Select
                    </button>
                </div>
            </article>
        {/each}
    </div>

    <button class="mt-[1.8vh] h-[4.6vh] w-full shrink-0 cursor-pointer rounded-md border-0 bg-accent text-[0.95vw] font-bold text-white disabled:cursor-default disabled:opacity-55" onclick={spawn} disabled={!selected}>
        Spawn
    </button>
    <p class="mt-[1.1vh] shrink-0 text-center text-[0.62vw] text-white/80">Click a location to begin your journey</p>
</section>
