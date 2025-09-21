# Development Principles

- Always run `npm run lint` at the end of any Frontend task and fix all reported errors before considering the task complete.
- When testing, only test the component that is being worked on. Because testing the whole app is too slow.

# Testing Setup

- **Framework**: Vitest with React Testing Library
- **Commands**:
  - `npx vitest run src/components/auth` - Test specific directory
  - `npm run test:dev-watch` - Watch mode for TDD
  - `npm run test:whole-app` - Test the whole app
- **Environment Setup**: Mock environment variables in `vitest-setup-file.ts` for integration tests

# UI Components

# Export Conventions

**CRITICAL**: Use named exports only, NOT default exports.

- **Named exports only**: Always use `export { ComponentName }` syntax
- **No default exports**: Avoid `export default ComponentName` because it disables IntelliSense
- **No re-export files**: Don't create index.js or barrel files for re-exporting components
- **Direct imports**: Import components directly from their source files

# Integrations Directory

- **Location**: Place all third‑party service integrations under `src/integrations/<service>/`.
- **Public API**: Components, hooks, and contexts must import only from the integration folder (no direct SDK usage in components).
- **Supabase client**: Define the client in `src/integrations/supabase/index.ts` and use named exports only.
- **Named exports**: Maintain named exports throughout integrations; avoid default exports.
- **COLOCATION**: Co‑locate integration‑specific hooks, contexts, providers, and tests with the integration in the same folder.
- **Barrels guidance**: The "no barrel files" rule applies to UI components. For integrations, a single `index.ts` as the public entry point is required and acceptable.
- **Folder Structure Restriction**: Do NOT automatically create nested folders like `hooks/`, `components/`, etc. Leave folder structure decisions to the user.
- **Library Usage**: ALWAYS use existing libraries from npm instead of self-implementing functionality. Check npm registry first before building custom solutions.
- **No Convenience Re-exports**: Do NOT create convenience re-exports like `export const auth = supabase.auth`. Always import the full client and use its properties directly.
