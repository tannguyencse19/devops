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

# Connect GitHub Repo with Coolify GitHub Action CI/CD Proces

## GitHub Actions Secret Configuration

**ALL GitHub repository secrets MUST have prefix: `GITHUBB_TIMOTHYNGUYEN_`**
- Format: `GITHUBB_TIMOTHYNGUYEN_[PURPOSE]`
- Examples: `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL`

**Environment Variable Naming in Workflows**:
- ✅ **Correct**: `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}`
- ❌ **Wrong**: `COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}` (creates unnecessary alias)

**Secret values can be found in**: `/vps/ci-cd/coolify/.env`

# Limitation

- Currently can't push to GitHub packages even use Deploy Keys or GitHub Apps