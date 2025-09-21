import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  server: {
    host: true, // Allow external connections (0.0.0.0)
    allowedHosts: process.env.VITE_ALLOWED_DOMAIN ? process.env.VITE_ALLOWED_DOMAIN.split(',') : ['localhost']
  },
  preview: {
    host: true, // Allow external connections (0.0.0.0) 
    port: 4173,
    allowedHosts: process.env.VITE_ALLOWED_DOMAIN ? process.env.VITE_ALLOWED_DOMAIN.split(',') : ['localhost']
  }
})