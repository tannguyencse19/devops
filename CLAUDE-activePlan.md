# Coolify Environment Variables Automation Plan

## Goal
Create an automated system to sync environment variables from `vps/ci-cd/secrets/demo-develop-app-with-tdd.env` to Coolify application "demo-develop-app-with-tdd" via API and update the GitHub repository Dockerfile to use these variables during build.

## Target Application Details
- **Coolify Application Name**: `demo-develop-app-with-tdd`
- **GitHub Repository**: `https://github.com/tannguyencse19/demo-develop-app-with-tdd`
- **Required Environment Variable**: `VITE_SUPABASE_URL`

## File Structure (Following Colocation Principle)

```
vps/ci-cd/
├── secrets/
│   ├── COOLIFY-ENV-SYNC.sh           # Main automation script (colocated with secrets)
│   └── demo-develop-app-with-tdd.env  # Input secrets file (user created)
└── coolify/
    └── .env                           # Coolify API token source
```

## Implementation Components

### 1. Single Script Architecture
**File**: `vps/ci-cd/secrets/COOLIFY-ENV-SYNC.sh`
**Usage**: `./COOLIFY-ENV-SYNC.sh <APP_NAME>`
**Example**: `./COOLIFY-ENV-SYNC.sh demo-develop-app-with-tdd`

**Script Scope**: Coolify API operations only - no GitHub repository modifications

### 2. Script Logic Flow
1. Takes `<APP_NAME>` as argument
2. Automatically finds corresponding secrets file: `vps/ci-cd/secrets/<APP_NAME>.env`
3. Sources Coolify API token from `../coolify/.env`
4. Discovers Coolify application via API using `<APP_NAME>`
5. Syncs all environment variables from secrets file to Coolify application

### 3. Input System
**Primary Input**: `vps/ci-cd/secrets/demo-develop-app-with-tdd.env` (user-created file)
**API Token Source**: `vps/ci-cd/coolify/.env` (for Coolify authentication only)

### 4. Coolify API Integration
- **Base URL**: `https://coolify.timothynguyen.work`
- **Authentication**: Bearer token from `../coolify/.env`
- **Discovery Flow**:
  1. `GET /api/v1/applications` find application with name "demo-develop-app-with-tdd"
  2. Extract application UUID/ID for environment variable operations
- **Variable Sync**:
  - `VITE_*` prefixed keys set `is_build_time=true`
  - All keys set `is_secret=true`
  - Use appropriate Coolify API endpoint to upsert environment variables

### 5. Script Behavior
**Single Command Operation**:
```bash
cd vps/ci-cd/secrets
./COOLIFY-ENV-SYNC.sh demo-develop-app-with-tdd
```

**Automatic Process**:
1. Validate prerequisites (curl, jq available)
2. Source Coolify API token from `../coolify/.env`
3. Read and validate secrets from `demo-develop-app-with-tdd.env`
4. Find Coolify application "demo-develop-app-with-tdd" via API
5. Sync all environment variables to Coolify with proper flags
6. Report success/failure status

## Security Features
- **Never expose secret values** in logs or outputs
- **Key-only references** in all documentation
- **Safe .env file parsing** with validation
- **Required variable validation** (ensures `VITE_SUPABASE_URL` exists)

## Expected Workflow
1. User creates `vps/ci-cd/secrets/demo-develop-app-with-tdd.env` with required variables
2. User runs: `cd vps/ci-cd/secrets && ./COOLIFY-ENV-SYNC.sh demo-develop-app-with-tdd`
3. Script automatically:
   - Finds the application in Coolify
   - Syncs all secrets from the file to Coolify
   - Reports completion status

## Phase 1: Environment Variable Sync (COMPLETED ✅)
- **File**: `vps/ci-cd/secrets/COOLIFY-ENV-SYNC.sh`
- **Status**: Successfully implemented and tested
- **Functionality**: Syncs environment variables from local `.env` files to Coolify via API

## Phase 2: Dockerfile Update (CURRENT PHASE)
- **Goal**: Update Dockerfile in GitHub repository to use environment variables during build
- **Target File**: `Dockerfile` in `https://github.com/tannguyencse19/demo-develop-app-with-tdd`
- **Key Requirements**:
  - Add `ARG` declarations for `VITE_*` build-time variables
  - Use multi-stage build with Node.js builder stage
  - Expose `VITE_*` variables as `ENV` during build stage
  - Copy built assets to minimal runtime image (e.g., nginx:alpine)
  - Never hardcode secrets in Dockerfile
  - Use GitHub API to make changes (no local cloning)

## Phase 2 Implementation Steps
1. **Discovery**: Analyze current Dockerfile via GitHub API
2. **Environment Analysis**: Read `VITE_*` variables from `demo-develop-app-with-tdd.env`
3. **Dockerfile Update**: Create multi-stage build with proper `ARG`/`ENV` handling
4. **PR Creation**: Submit changes via GitHub API with detailed description
5. **Validation**: Ensure build process works with Coolify build args

## Benefits
- **End-to-end automation** - from local secrets to working deployment
- **Security-first** - never exposes secrets in build artifacts
- **Multi-stage builds** - minimal runtime images
- **GitHub API integration** - no local repository cloning needed
- **File convention** - uses APP_NAME.env pattern for easy management