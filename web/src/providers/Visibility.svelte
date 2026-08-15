<script lang="ts">
    import { Receive, Send } from '@enums/events';
    import { VISIBLE, CONFIG } from '@stores/stores.svelte';
    import { ReceiveEvent, SendEvent } from '@utils/eventsHandlers';
    import { onMount } from 'svelte';
    import type { Snippet } from 'svelte';

    let { children }: { children?: Snippet } = $props();

    ReceiveEvent(Receive.visible, (visible: boolean): void => {
        VISIBLE.value = visible;
    });

    onMount(() => {
        if (!CONFIG.allowEscapeKey) return;

        const keyHandler = (e: KeyboardEvent) => {
            if (VISIBLE.value && ['Escape'].includes(e.code)) {
                SendEvent(Send.close);
            }
        };
        window.addEventListener('keydown', keyHandler);
        return () => window.removeEventListener('keydown', keyHandler);
    });
</script>

{#if VISIBLE.value}
    <main class="overlay-enter absolute left-0 top-0 z-[100] m-0 box-border h-screen w-screen bg-transparent p-0 select-none">
        {@render children?.()}
    </main>
{/if}
