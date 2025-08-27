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
curl -s -H "Authorization: Bearer <GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN>" \
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
- API Token: `<COOLIFY_API_TOKEN>` (get actual value from `/vps/ci-cd/coolify/.env`)
- Admin credentials: `<ADMIN_USERNAME>` / `<ADMIN_PASSWORD>` (get actual values from `/vps/ci-cd/coolify/.env`)

**Usage notes**:
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

**Secret values can be found in**: `/vps/ci-cd/coolify/.env`

## Coolify Resource Selection for CI/CD

### Private Repository with Deploy Key (Recommended)

**CRITICAL**: For GitHub Actions CI/CD pipelines, use **Private Repository with Deploy Key** resource type

**API Endpoint**: `POST /applications/private-deploy-key`

**Why Private Repository with Deploy Key provides maximum control and decoupling**:
- ✅ **Full API Creation**: Can be created entirely via single API call with no manual dashboard setup
- ✅ **Source Control Integration**: Direct integration with private GitHub repositories
- ✅ **Flexible Build Control**: Coolify handles build process using specified build pack (Nixpacks, Dockerfile, Docker Compose)
- ✅ **Easy Decoupling**: Simple SSH key revocation to completely disconnect from Coolify
- ✅ **Comprehensive Configuration**: All deployment parameters configurable via API:
  - Port mappings and exposure
  - Custom domain configuration
  - Environment variables
  - Resource limits (CPU/memory)
  - Health check settings
  - Build commands (install, build, start)
  - Pre/post deployment commands
  - Custom labels and Docker run options
- ✅ **Webhook Integration**: Automatic deployment triggers via GitHub webhooks
- ✅ **Build Pack Flexibility**: Supports Nixpacks, Dockerfile, Docker Compose, or Static builds
- ✅ **No Registry Dependencies**: Eliminates need for external Docker registry authentication

**SSH Key Management**:
- Generate deploy key: `ssh-keygen -t rsa -b 4096 -C "coolify-deploy-key"`
- Add public key to GitHub repository (Settings > Deploy keys)
- Store private key UUID in Coolify for API calls
- Revoke by removing from GitHub repository (instant decoupling)

### Alternative Resource Types (When NOT to use)

**Docker Image Application** (`POST /applications/dockerimage`):
- Requires Docker registry authentication and maintenance
- Additional complexity for registry credential management
- Less flexible than source-based deployments

**GitHub App Integration** (`POST /applications/private-github-app`):
- Heavy integration that's complex to decouple
- Requires GitHub App creation and management
- Not suitable when delegation is primary requirement

**Docker Compose Application** (`POST /applications/dockercompose`):
- Use only for multi-container applications with complex service dependencies
- Requires docker-compose.yml management

### Implementation Pattern for GitHub Actions

1. **Generate SSH Deploy Key** (one-time setup)
2. **Create Private Repository Application via API** (programmatic)
3. **Configure automatic webhooks** (source-triggered deployments)
4. **GitHub Actions only handles CI/testing** (build handled by Coolify)

**Key Advantages**:
- **Clean Delegation**: Others can deploy without GitHub access using API
- **Maximum Decoupling**: SSH key revocation instantly disconnects Coolify
- **Build Flexibility**: Coolify handles complex build scenarios automatically
- **No Registry Maintenance**: Eliminates Docker registry authentication issues

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

# Limitation

- Currently can't push to GitHub packages even use Deploy Keys or GitHub Apps