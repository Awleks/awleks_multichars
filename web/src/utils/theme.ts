import type { Theme } from '@typings/characters';

export const DEFAULT_THEME: Theme = {
    accent: '#2563EB',
    surface: '#0E0E10',
    fade: '#111111',
    fadeOpacity: 0.8,
    danger: '#F87171',
    textMuted: '#9CA3AF',
};

function hexToChannels(hex: string, fallback: string): string {
    let value = hex.replace('#', '').trim();
    if (value.length === 3) {
        value = value
            .split('')
            .map((char) => char + char)
            .join('');
    }
    if (value.length !== 6) return fallback;
    const number = Number.parseInt(value, 16);
    if (Number.isNaN(number)) return fallback;
    return `${(number >> 16) & 255} ${(number >> 8) & 255} ${number & 255}`;
}

export function applyTheme(theme?: Partial<Theme> | null) {
    const next = { ...DEFAULT_THEME, ...theme };
    const root = document.documentElement;
    root.style.setProperty('--accent', hexToChannels(next.accent, '37 99 235'));
    root.style.setProperty('--surface', hexToChannels(next.surface, '14 14 16'));
    root.style.setProperty('--fade', hexToChannels(next.fade, '17 17 17'));
    root.style.setProperty('--danger', hexToChannels(next.danger, '248 113 113'));
    root.style.setProperty('--txt-muted', hexToChannels(next.textMuted, '156 163 175'));
    root.style.setProperty('--fade-opacity', String(next.fadeOpacity ?? DEFAULT_THEME.fadeOpacity));
}
