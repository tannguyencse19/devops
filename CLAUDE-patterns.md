# Code Patterns and Conventions

## Development Philosophy

### Simplicity First
- **Keep all logic in a single file** when first implementing anything
- **Do simple things instead of complicated design** - user will review work anyway
- Avoid over-engineering or premature optimization
- Start minimal, then iterate based on feedback

### Install/Uninstall Pattern
- **ALWAYS create both INSTALL and UNINSTALL versions** for any deployment/setup script
- If all hell breaks loose, we can UNINSTALL everything to get fresh environment
- Then INSTALL again cleanly
- This provides reliable recovery path and clean slate capability

## Script Structure Guidelines

### Single File Approach
```bash
# Example structure for setup scripts
#!/bin/bash
set -euo pipefail

# All functions in same file
install_component() {
    # Installation logic
}

uninstall_component() {
    # Complete cleanup logic
}

# Simple main execution
case "${1:-install}" in
    install)   install_component ;;
    uninstall) uninstall_component ;;
    *)         echo "Usage: $0 {install|uninstall}" ;;
esac
```

### Recovery-First Design
- Every INSTALL action should have corresponding UNINSTALL action
- Document what gets created/modified for complete cleanup
- Test UNINSTALL � INSTALL cycle to ensure reliability
- Prefer stateless installations that can be completely removed

## Implementation Priority
1. **Single file with all logic**
2. **Simple, direct implementation**
3. **Both install and uninstall paths**
4. **Test the recovery cycle**
5. **Iterate based on user review**

## **COLOCATION PRINCIPLE** 🏆

**CRITICAL PATTERN**: Always follow the colocation principle

### Definition
Place related files as close as possible to where they're used:
- Documentation next to the code it describes
- Configuration files with the components they configure
- Scripts near the functionality they support

### Examples Applied
✅ **Correct**: `.github/COOLIFY_SETUP.md` near `.github/workflows/build-and-deploy.yml`
❌ **Wrong**: `docs/COOLIFY_SETUP.md` far from GitHub Actions workflow

### Benefits
- Easier to find related files
- Better maintainability
- Clear relationships between components
- Reduced cognitive load

### Implementation Rules
1. Documentation lives with the code it documents
2. Config files stay with components they configure
3. Helper scripts colocate with main functionality
4. Tests alongside source code when possible

**ALWAYS REMEMBER**: When creating or organizing files, ask "What is this most closely related to?" and place it there.

## Examples Applied
- Coolify INSTALL.sh � should have UNINSTALL.sh counterpart
- Docker setup � include Docker removal/cleanup
- Database setup � include data/container cleanup
- Configuration files � track and remove all created files

## GitHub Actions Pattern

### GitHub Action Trigger Condition

Trigger on push commit to `main` branch

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

### GitHub Action Environment Variable Naming
**CRITICAL**: In GitHub Actions workflows, define environment variables to match secret names exactly
- ✅ **Correct**: `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}`
- ❌ **Wrong**: `COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}` (creates unnecessary alias)

### GitHub Action Secret Naming Convention
**ALL GitHub repository secrets MUST have prefix: `GITHUBB_TIMOTHYNGUYEN_`**
- Format: `GITHUBB_TIMOTHYNGUYEN_[PURPOSE]`
- Examples:
  - `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL`
  - `GITHUBB_TIMOTHYNGUYEN_DOCKER_REGISTRY_TOKEN`

### GitHub Action Secret Actual Value

The actual value can be found at `vps/ci-cd/coolify/.env` (or `vps/ci-cd/coolify/.env.example`)

## Coolify Access Pattern

### Coolify API Access
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

### GitHub Action Testing Process

- Trigger GitHub Action workflow by create an empty commit to `main` branch
- WAIT for the GitHub Action workflow to FINISH (NOT QUEUE).
- Repeat the process until the GitHub Action workflow run success. Debug if the workflow run failed. 
- STOP the testing process if detect that the workflow run failed not because of the GitHub Action related code (GitHub Action code, Dockerfile, docker-compose).
- NEVER update the GitHub Action for print better error. Just debug on the original error GitHub Action throw.
- NEVER DELETE ANY BRANCH during the testing process.