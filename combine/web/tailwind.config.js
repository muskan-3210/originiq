/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        base: '#0D0B1A',
        surface: '#17142B',
        surfaceRaised: '#201C3B',
        gold: '#FFC857',
        danger: '#E24B4A',
        teal: '#1D9E75',
        amber: '#EF9F27',
        textPrimary: '#F5F3FF',
        textSecondary: '#A9A3C9',
        textMuted: '#6E698F',
        borderDefault: '#2A2650',
        borderStrong: '#3D386B',
      },
      borderRadius: {
        card: '12px',
        button: '8px',
        pill: '999px',
      },
      fontFamily: {
        display: ['"Space Grotesk"', 'sans-serif'],
        body: ['Inter', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
      },
      boxShadow: {
        // The design system uses raised surfaces + hairline borders instead of drop shadows.
        none: 'none',
      },
    },
  },
  plugins: [],
}
