// vite + tailwind css plugin connect
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// add tailwindcss plugin
export default defineConfig({
  plugins: [react(), tailwindcss()],
})
