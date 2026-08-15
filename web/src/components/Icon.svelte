<script lang="ts">
    let {
        name,
        class: className = 'h-[0.95vw] w-[0.95vw]',
    }: {
        name: string;
        class?: string;
    } = $props();
</script>

<img src={`icons/${name}.svg`} alt="" class={className} />
