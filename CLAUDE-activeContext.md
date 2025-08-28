# Active Context: Coolify Environment Variables Automation

## Current Status: PHASE 2 - DOCKERFILE UPDATE

**Phase 1 (Environment Sync)**: COMPLETED
**Phase 2 (Dockerfile Update)**: IN PROGRESS

The **COOLIFY-ENV-SYNC.sh** script has been successfully implemented and tested. Now working on Phase 2: updating the Dockerfile in the GitHub repository to use the environment variables during build.

## Current Phase: Dockerfile Update

**Target Repository**: `https://github.com/tannguyencse19/demo-develop-app-with-tdd`
**Goal**: Update Dockerfile to use `VITE_*` build-time variables synced by Phase 1
**Approach**: Use GitHub API to analyze and update Dockerfile, then create PR

## Phase 1 Accomplishments (COMPLETED)

1. **Script Implementation**: Created complete automation script with all required features:
   - Takes `<APP_NAME>` as argument
   - Automatically finds secrets file: `<APP_NAME>.env`  
   - Sources Coolify API token from `../coolify/.env`
   - Discovers Coolify application via API
   - Syncs environment variables with proper flags

2. **API Integration**: Successfully integrated with Coolify API:
   - **Endpoint**: `POST /api/v1/applications/{uuid}/envs`
   - **Authentication**: Bearer token (`GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN`)
   - **Payload Format**: `{key, value, is_build_time, is_preview, is_literal}`
   - **Create/Update Logic**: Handles both new variables (POST) and existing variables (PATCH via 409 handling)

3. **Variable Processing**: Correctly processes environment variables:
   -  `VITE_*` prefixed keys set `is_build_time=true`
   -  All other keys set `is_build_time=false`
   -  Validates required `VITE_SUPABASE_URL` exists

4. **Testing Results**: Successfully tested with `demo-develop-app-with-tdd` application:
   -  Application found: UUID `vos0o4ks08044sgokcgosgsw`
   -  Variable created/updated: `VITE_SUPABASE_URL=https://dieaqijwqrtchfffhrvs.supabase.co`
   -  Proper build-time flag set (`is_build_time=true`)

## Phase 2 Next Steps

1. **Analyze Current Dockerfile**: Use GitHub API to fetch current Dockerfile
2. **Read Environment Variables**: Parse `VITE_*` variables from local `.env` file
3. **Update Dockerfile**: Create multi-stage build with proper `ARG`/`ENV` declarations
4. **Create Pull Request**: Submit changes via GitHub API
5. **Validate Integration**: Ensure Coolify can use build args properly

## Key Requirements for Phase 2

- **Security**: Never hardcode secret values in Dockerfile
- **Multi-stage Build**: Use Node.js builder stage + minimal runtime image
- **Build Args**: Expose `VITE_*` variables as build arguments
- **GitHub API**: Make all changes via API (no local cloning)
- **Documentation**: Clear PR description linking to Phase 1 automation