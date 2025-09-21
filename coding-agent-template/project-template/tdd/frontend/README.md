# Development Principles

- Always run `npm run lint` at the end of any Frontend task and fix all reported errors before considering the task complete.
- When testing, only test the component that is being worked on. Because testing the whole app is too slow.

# Testing Setup

- **Framework**: Vitest with React Testing Library
- **Commands**:
  - `npx vitest run src/components/auth` - Test specific directory
  - `npm run test:whole-app` - Test the whole app
- **Environment Setup**: Mock environment variables in `vitest-setup-file.ts` for integration tests

# UI Components

# Integrations Directory

- **Location**: Place all third‑party service integrations under `src/integrations/<service>/`.
- **Folder Structure Restriction**: Do NOT automatically create nested folders like `hooks/`, `components/`, etc. Leave folder structure decisions to the user.