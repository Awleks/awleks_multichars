<script lang="ts">
    import { InitialiseDebugSenders } from '@utils/debug/init';
    import { InitialiseDebugReceivers } from '@utils/debug/receivers';
    import SendDebuggers from '@utils/debug/senders';
    import { onMount } from 'svelte';

    onMount(() => {
        InitialiseDebugSenders();
        InitialiseDebugReceivers();
    });

    let menuOpen = $state(false);
</script>

<div class="fixed bottom-[18px] right-[18px] z-[9999999] flex flex-col-reverse items-end gap-2">
    <button
        class="cursor-pointer rounded border-0 bg-accent px-3 py-2 text-left text-xs text-white"
        onclick={() => (menuOpen = !menuOpen)}
    >
        Debug
    </button>

    {#if menuOpen}
        <ol class="flex min-w-[180px] list-none flex-col gap-2.5 rounded-md bg-black/90 p-2.5">
            {#each SendDebuggers as group}
                <li>
                    <span class="mb-1.5 block text-xs text-white">{group.label}</span>
                    {#each group.actions as action}
                        <button
                            class="mt-1 w-full cursor-pointer rounded border-0 bg-[#1f1f1f] px-3 py-2 text-left text-xs text-white"
                            onclick={() => action.action()}
                        >
                            {action.label}
                        </button>
                    {/each}
                </li>
            {/each}
        </ol>
    {/if}
</div>
