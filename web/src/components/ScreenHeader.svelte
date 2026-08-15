<script lang="ts">
    let {
        serverName,
        action,
        title = '',
        subtitle = '',
    }: {
        serverName: string;
        action: string;
        title?: string;
        subtitle?: string;
    } = $props();
</script>

<header class="mb-[3.2vh] shrink-0">
    <p class="mb-[2.6vh] flex items-center whitespace-nowrap text-[0.74vw] tracking-[0.01em]">
        <span class="font-light text-white/70">{serverName}</span>
        <span class="px-[0.42em] font-light text-white/70">//</span>
        <span class="font-bold text-white">{action}</span>
    </p>
    {#if title}
        <h1 class="text-[2.7vw] font-bold leading-[0.95] tracking-[-0.04em] text-white">{title}</h1>
    {/if}
    {#if subtitle}
        <p class="mt-[0.55vh] text-[1.05vw] font-light tracking-[-0.01em] text-white/90">{subtitle}</p>
    {/if}
</header>
