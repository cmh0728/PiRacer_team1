/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',   // ⬅️ TSX 포함!
  ],
  theme: { extend: {} },
  darkMode: 'media',                // 필요시 'class'
  plugins: [],
}
