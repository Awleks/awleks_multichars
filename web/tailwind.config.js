/** @type {import('tailwindcss').Config} */

export default {
    content: [
        "./index.html",
        "./src/**/*.{svelte,js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                accent: 'rgb(var(--accent) / <alpha-value>)',
                surface: 'rgb(var(--surface) / <alpha-value>)',
                danger: 'rgb(var(--danger) / <alpha-value>)',
                'txt-muted': 'rgb(var(--txt-muted) / <alpha-value>)',
                primary: '#111111',
                secondary: '#2a2a2a',
                'txt-primary': '#ffffff',
                'txt-secondary': '#a8a8a8',
            },
            fontFamily: {
                sans: ['"Tactic Round"', 'sans-serif'],
            },
        },
    },
    plugins: [],
}
