# Coolify Self-Hosting Installation

## 📋 What's Included

- **INSTALL.sh** - Automated installation script
- **UNINSTALL.sh** - Automated uninstallation script
- **docker-compose.yml** - Coolify stack definition
- **.env.example** - Environment configuration template

## 📁 Directory Structure

After installation:

```
/data/coolify/
├── source/                 # Docker compose files
│   ├── docker-compose.yml
│   └── .env
├── applications/           # Deployed apps
├── databases/              # Database data
├── backups/                # Daily backups
├── proxy/                  # Proxy config
└── ssh/                    # SSH keys
```

## 📚 Additional Resources

- **Coolify Docs**: https://coolify.io/docs
- **Docker Compose Reference**: https://docs.docker.com/compose/
- **GitHub Issues**: https://github.com/coollabsio/coolify/issues

# 🔌 API Integration and GitHub Actions

## Coolify API Access Pattern

**CRITICAL**: Always access Coolify using the Bearer token from the `.env` file

**Standard API call pattern**:
```bash
curl -s -H "Authorization: Bearer 4|CsDjmJL0MGWOMyNb9eNUDOtH3VMhdfCEfiL6q7M7b5337df0" \
     -H "Accept: application/json" \
     "https://coolify.timothynguyen.work/api/v1/[endpoint]"
```

**Available endpoints for investigation**:
- `/api/v1/applications` - List all applications
- `/api/v1/projects` - List all projects  
- `/api/v1/servers` - List all servers
- `/api/v1/services` - List all services
- `/api/v1/deployments` - List deployment history
- `/api/v1/resources` - List all resources

**Authentication details**:
- Base URL: `https://coolify.timothynguyen.work`
- API Token: `4|CsDjmJL0MGWOMyNb9eNUDOtH3VMhdfCEfiL6q7M7b5337df0`
- Admin credentials: `admin` / `j9WsQMk8CBoIt6O`

**Usage notes**:
- Always use Bearer token authentication for API calls
- Check multiple endpoints to understand the current state
- Applications must be created in Coolify before deployment will work

## GitHub Actions Secret Configuration

**ALL GitHub repository secrets MUST have prefix: `GITHUBB_TIMOTHYNGUYEN_`**
- Format: `GITHUBB_TIMOTHYNGUYEN_[PURPOSE]`
- Examples:
  - `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL`
  - `GITHUBB_TIMOTHYNGUYEN_DOCKER_REGISTRY_TOKEN`

**Environment Variable Naming in Workflows**:
- ✅ **Correct**: `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}`
- ❌ **Wrong**: `COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}` (creates unnecessary alias)

**Secret values can be found in**: `vps/ci-cd/coolify/.env`

## Coolify Resource Selection for CI/CD

### Docker Image Application (Recommended)

**CRITICAL**: For GitHub Actions CI/CD pipelines, always use **Docker Image Application** resource type

**API Endpoint**: `POST /applications/dockerimage`

**Why Docker Image Application gives maximum programmatic control**:
- ✅ **Full API Creation**: Can be created entirely via single API call with no manual dashboard setup
- ✅ **Pre-built Image Support**: Works with existing container registry images (ghcr.io, docker.io, etc.)
- ✅ **Comprehensive Configuration**: All deployment parameters configurable via API:
  - Port mappings and exposure
  - Custom domain configuration  
  - Environment variables
  - Resource limits (CPU/memory)
  - Health check settings
  - Custom labels and Docker run options
- ✅ **Webhook Integration**: Provides webhook endpoint for automated deployments once created
- ✅ **No Redundant Build**: Skips build process since image is pre-built in CI/CD pipeline

### Alternative Resource Types (When NOT to use)

**Docker Compose Application** (`POST /applications/dockercompose`):
- Use only for multi-container applications with complex service dependencies
- Requires docker-compose.yml management

**Dockerfile Application** (`POST /applications/dockerfile`):
- Avoid when already building images in CI/CD
- Creates redundant build process
- Requires more manual webhook setup

**Git-based Applications**:
- Least API control
- Requires manual dashboard configuration
- Not suitable for automated provisioning

### Implementation Pattern for GitHub Actions

1. **Build image in GitHub Actions** (existing pattern)
2. **Create Docker Image Application via API** (programmatic)
3. **Use webhook endpoint for deployments** (automated)
4. **No manual Coolify dashboard interaction required**

**Root Cause Pattern**: 404 deployment errors typically indicate missing application resource in Coolify, not incorrect API endpoints.

## GitHub Actions Integration Example

**Standard workflow trigger pattern**:
```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build_deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

**Testing Process**:
- Trigger GitHub Action workflow by creating an empty commit to `main` branch
- WAIT for the GitHub Action workflow to FINISH (NOT QUEUE). You can use `sleep 60` command instead of immediately checking.
- Repeat the process until the GitHub Action workflow runs successfully. Debug if the workflow run failed
- STOP the testing process if detected that the workflow run failed not because of the GitHub Action related code (GitHub Action code, Dockerfile, docker-compose)
- NEVER update the GitHub Action for better error printing. Just debug on the original error GitHub Action throws
- NEVER DELETE ANY BRANCH during the testing process
