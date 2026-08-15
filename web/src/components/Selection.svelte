<script lang="ts">
    import { APP } from '@stores/stores.svelte';
    import { Send } from '@enums/events';
    import { SendEvent } from '@utils/eventsHandlers';
    import ScreenHeader from '@components/ScreenHeader.svelte';
    import Icon from '@components/Icon.svelte';
    import type { Character } from '@typings/characters';
    import { onMount } from 'svelte';

    let deleting = $state(false);
    let confirmDelete = $state(false);

    const selected = $derived(APP.characters.find((c) => c.cid === APP.selectedCid) ?? APP.characters[0] ?? null);
    const filled = $derived(!!selected && !selected.empty && !!selected.citizenid);
    const slotLabel = $derived(String(selected?.cid ?? 1).padStart(2, '0'));

    function money(value?: number) {
        return `$${(value ?? 0).toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
        })}`;
    }

    function fullName(character: Character | null) {
        if (!character?.charinfo) return 'Empty Slot';
        return `${character.charinfo.firstname} ${character.charinfo.lastname}`;
    }

    function isFemale(character: Character | null) {
        const gender = character?.charinfo?.gender;
        return gender === 'female' || gender === 1;
    }

    function jobLabel(character: Character | null) {
        if (!character?.job?.label) return 'Unemployed';
        const grade = character.job.grade?.name;
        return grade && grade !== 'Freelancer' && grade !== 'Civilian'
            ? `${character.job.label} · ${grade}`
            : character.job.label;
    }

    function select(character: Character) {
        APP.selectedCid = character.cid;
        confirmDelete = false;
        SendEvent(Send.previewCharacter, {
            citizenid: character.citizenid,
            empty: character.empty || !character.citizenid,
            cid: character.cid,
        });
    }

    function cycle(dir: number) {
        if (!APP.characters.length) return;
        const index = Math.max(0, APP.characters.findIndex((c) => c.cid === APP.selectedCid));
        const next = APP.characters[(index + dir + APP.characters.length) % APP.characters.length];
        select(next);
    }

    function create() {
        if (!selected || filled) return;
        APP.creatingCid = selected.cid;
        APP.view = 'identity';
    }

    async function play() {
        if (!filled || !selected) return;
        await SendEvent(Send.playCharacter, { character: selected });
    }

    async function remove() {
        if (!selected?.citizenid || deleting) return;
        deleting = true;
        await SendEvent(Send.deleteCharacter, { citizenid: selected.citizenid });
        deleting = false;
        confirmDelete = false;
    }

    onMount(() => {
        const onKey = (e: KeyboardEvent) => {
            if (e.key === 'ArrowLeft' || e.key === 'a' || e.key === 'A') cycle(-1);
            if (e.key === 'ArrowRight' || e.key === 'd' || e.key === 'D') cycle(1);
            if (e.key === 'Enter') {
                if (filled) play();
                else create();
            }
        };
        window.addEventListener('keydown', onKey);
        return () => window.removeEventListener('keydown', onKey);
    });
</script>

<section class="screen-enter flex h-full w-[22vw] min-w-[340px] max-w-[420px] flex-col pb-[12vh] pt-[5vh]">
    <ScreenHeader serverName={APP.serverName} action="Select Your Character" />

    <div class="mb-[3.6vh]">
        <div class="mb-[1vh] flex items-center gap-[0.5vw]">
            <p class="m-0 text-[0.78vw] font-normal text-white">Character</p>
            <span class="inline-flex h-[2vh] min-w-[1.85vw] items-center justify-center rounded bg-accent px-[0.4vw] text-[0.64vw] font-bold tracking-[0.04em] text-white">
                {slotLabel}
            </span>
        </div>

        <h2 class="m-0 flex items-center gap-[0.5vw] text-[2.2vw] font-bold leading-none tracking-[-0.04em] text-white">
            {fullName(selected)}
            {#if filled}
                <Icon name={isFemale(selected) ? 'GenderFemale' : 'GenderMale'} class="h-[1.2vw] w-[1.2vw]" />
            {/if}
        </h2>
    </div>

    {#if filled}
    <div class="details-enter">
        <div class="mb-[0.9vh] flex items-center justify-between pr-[0.2vw]">
            <p class="m-0 text-[0.82vw] font-bold text-white">Details</p>
            {#if APP.enableDelete}
                <button class="grid h-[1.35vw] w-[1.35vw] cursor-pointer place-items-center border-0 bg-transparent p-0 opacity-70 hover:opacity-100" onclick={() => (confirmDelete = !confirmDelete)} aria-label="Delete character">
                    <Icon name="Trash" class="h-[0.95vw] w-[0.95vw]" />
                </button>
            {/if}
        </div>
        <div class="mb-[2vh] h-px w-full bg-white/30"></div>

        {#if confirmDelete}
            <div class="details-enter pb-[1vh] pt-[0.2vh]">
                <p class="mb-[1vh] text-[0.72vw] text-white/90">Delete this character? This cannot be undone.</p>
                <div class="grid grid-cols-2 gap-[0.5vw]">
                    <button class="h-[3.4vh] cursor-pointer rounded-[5px] border-0 bg-white/10 text-[0.72vw] text-white" onclick={() => (confirmDelete = false)}>Cancel</button>
                    <button class="h-[3.4vh] cursor-pointer rounded-[5px] border-0 bg-[#b42318] text-[0.72vw] text-white" onclick={remove} disabled={deleting}>Delete</button>
                </div>
            </div>
        {:else}
            <div class="mb-[1.45vh] flex items-center gap-[0.7vw]">
                <div class="grid h-[2.15vw] min-h-[34px] w-[2.15vw] min-w-[34px] place-items-center rounded-[5px] bg-black/55">
                    <Icon name="MoneyWavy" />
                </div>
                <div>
                    <p class="m-0 text-[0.58vw] font-normal text-txt-muted">Cash</p>
                    <p class="mt-[0.12vh] text-[0.92vw] font-bold tracking-[-0.02em] text-white">{money(selected?.money?.cash)}</p>
                </div>
            </div>

            <div class="mb-[1.45vh] flex items-center gap-[0.7vw]">
                <div class="grid h-[2.15vw] min-h-[34px] w-[2.15vw] min-w-[34px] place-items-center rounded-[5px] bg-black/55">
                    <Icon name="Bank" />
                </div>
                <div>
                    <p class="m-0 text-[0.58vw] font-normal text-txt-muted">Bank</p>
                    <p class="mt-[0.12vh] text-[0.92vw] font-bold tracking-[-0.02em] text-white">{money(selected?.money?.bank)}</p>
                </div>
            </div>

            <div class="mb-[1.45vh] flex items-center gap-[0.7vw]">
                <div class="grid h-[2.15vw] min-h-[34px] w-[2.15vw] min-w-[34px] place-items-center rounded-[5px] bg-black/55">
                    <Icon name="CalendarBlank" />
                </div>
                <div>
                    <p class="m-0 text-[0.58vw] font-normal text-txt-muted">Date of Birth</p>
                    <p class="mt-[0.12vh] text-[0.92vw] font-bold tracking-[-0.02em] text-white">{selected?.charinfo?.birthdate || '—'}</p>
                </div>
            </div>

            <div class="mb-[1.45vh] flex items-center gap-[0.7vw]">
                <div class="grid h-[2.15vw] min-h-[34px] w-[2.15vw] min-w-[34px] place-items-center rounded-[5px] bg-black/55">
                    <Icon name="Briefcase" />
                </div>
                <div>
                    <p class="m-0 text-[0.58vw] font-normal text-txt-muted">Job</p>
                    <p class="mt-[0.12vh] text-[0.92vw] font-bold tracking-[-0.02em] text-white">{jobLabel(selected)}</p>
                </div>
            </div>

            <div class="mb-[1.45vh] flex items-center gap-[0.7vw]">
                <div class="grid h-[2.15vw] min-h-[34px] w-[2.15vw] min-w-[34px] place-items-center rounded-[5px] bg-black/55">
                    <Icon name="Flag" />
                </div>
                <div>
                    <p class="m-0 text-[0.58vw] font-normal text-txt-muted">Nationality</p>
                    <p class="mt-[0.12vh] text-[0.92vw] font-bold tracking-[-0.02em] text-white">{selected?.charinfo?.nationality || '—'}</p>
                </div>
            </div>
        {/if}
    </div>
    {/if}
</section>

<div class="fixed bottom-[3.6vh] left-1/2 z-20 -translate-x-1/2">
    <div class="dock-enter flex items-center gap-[0.55vw]">
    <button class="grid h-[4.5vh] w-[3.4vw] min-w-[48px] cursor-pointer place-items-center rounded border-0 bg-[#161616]/80 p-0" onclick={() => cycle(-1)} aria-label="Previous character">
        <Icon name="CaretLeft" class="h-[1.15vw] w-[1.15vw]" />
    </button>
    {#if filled}
        <button class="flex h-[4.5vh] min-w-[11vw] cursor-pointer items-center justify-center gap-[0.45vw] rounded border-0 bg-accent px-[1.6vw] text-[0.92vw] font-bold text-white" onclick={play}>
            <Icon name="Play" class="h-[0.9vw] w-[0.9vw]" />
            Play
        </button>
    {:else}
        <button class="flex h-[4.5vh] min-w-[11vw] cursor-pointer items-center justify-center rounded border-0 bg-accent px-[1.6vw] text-[0.92vw] font-bold text-white" onclick={create}>
            New Character
        </button>
    {/if}
    <button class="grid h-[4.5vh] w-[3.4vw] min-w-[48px] cursor-pointer place-items-center rounded border-0 bg-[#161616]/80 p-0" onclick={() => cycle(1)} aria-label="Next character">
        <Icon name="CaretRight" class="h-[1.15vw] w-[1.15vw]" />
    </button>
    </div>
</div>
