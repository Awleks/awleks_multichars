<script lang="ts">
    import Icon from '@components/Icon.svelte';
    import type { Nationality } from '@typings/characters';
    import { onMount } from 'svelte';

    let {
        options,
        value = $bindable(''),
        invalid = false,
        onchange,
    }: {
        options: Nationality[];
        value?: string;
        invalid?: boolean;
        onchange?: () => void;
    } = $props();

    let open = $state(false);
    let query = $state('');
    let root: HTMLDivElement | null = $state(null);

    const selected = $derived(options.find((option) => option.name === value) ?? null);
    const filtered = $derived(
        options.filter((option) => option.name.toLowerCase().includes(query.trim().toLowerCase())),
    );

    function choose(option: Nationality) {
        value = option.name;
        query = '';
        open = false;
        onchange?.();
    }

    function toggle() {
        open = !open;
        if (open) query = '';
    }

    onMount(() => {
        const onPointer = (event: PointerEvent) => {
            if (!root?.contains(event.target as Node)) {
                open = false;
                query = '';
            }
        };
        window.addEventListener('pointerdown', onPointer);
        return () => window.removeEventListener('pointerdown', onPointer);
    });
</script>

<div class="relative" bind:this={root}>
    <button
        type="button"
        class="flex h-[4.4vh] w-full cursor-pointer items-center gap-[0.55vw] rounded-md border bg-surface px-[0.9vw] text-left text-[0.78vw] text-white outline-none {invalid ? 'border-danger' : open ? 'border-white/25' : 'border-transparent'} {open ? 'rounded-b-none' : ''}"
        onclick={toggle}
    >
        {#if selected}
            <span class="min-w-0 flex-1 truncate">{selected.name}</span>
        {:else}
            <span class="min-w-0 flex-1 truncate text-white/50">Select nationality</span>
        {/if}
        <Icon name="CaretLeft" class="h-[0.7vw] w-[0.7vw] shrink-0 transition-transform duration-200 ease-out {open ? 'rotate-90' : '-rotate-90'}" />
    </button>

    {#if open}
        <div class="menu-enter absolute left-0 right-0 top-full z-30 overflow-hidden rounded-b-md border border-t-0 border-white/15 bg-surface">
            <div class="border-b border-white/10 px-[0.7vw] py-[0.7vh]">
                <input
                    class="h-[3.3vh] w-full rounded border-0 bg-black px-[0.65vw] text-[0.7vw] text-white outline-none placeholder:text-white/45"
                    placeholder="Search..."
                    bind:value={query}
                    onclick={(e) => e.stopPropagation()}
                />
            </div>
            <div class="max-h-[22vh] overflow-y-auto py-[0.35vh] [&::-webkit-scrollbar]:w-[3px] [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-white/80">
                {#each filtered as option (option.name)}
                    <button
                        type="button"
                        class="flex h-[3.8vh] w-full cursor-pointer items-center border-0 px-[0.85vw] text-left text-[0.74vw] transition-colors duration-150 {option.name === value ? 'bg-accent text-white' : 'bg-transparent text-white/90 hover:bg-white/10'}"
                        onclick={() => choose(option)}
                    >
                        <span class="truncate">{option.name}</span>
                    </button>
                {:else}
                    <p class="px-[0.85vw] py-[1vh] text-[0.7vw] text-white/50">No matches</p>
                {/each}
            </div>
        </div>
    {/if}
</div>
