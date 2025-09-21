import { defineConfig, loadEnv } from 'vite'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {

  // https://vitejs.dev/config/#using-environment-variables-in-config
  const processEnv = loadEnv(mode, process.cwd(), '')

  return {
    server: {
      host: true, // Allow external connections (0.0.0.0)
      allowedHosts: processEnv.VITE_ALLOWED_DOMAIN ? processEnv.VITE_ALLOWED_DOMAIN.split(',') : ['localhost']
    },
    preview: {
      host: true, // Allow external connections (0.0.0.0) 
      port: 4173,
      allowedHosts: processEnv.VITE_ALLOWED_DOMAIN ? processEnv.VITE_ALLOWED_DOMAIN.split(',') : ['localhost']
    }
  }
})