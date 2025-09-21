/// <reference types="vite/client" />
// Fix `error TS2339: Property 'env' does not exist on type 'ImportMeta'.`

import "@testing-library/jest-dom"

// Mock environment variables for testing
import.meta.env.VITE_SUPABASE_URL = 'https://test.supabase.co'
import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY = 'test-key'