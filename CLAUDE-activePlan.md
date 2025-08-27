Connect GitHub Repo with Coolify CI/CD

Phase 1: Preparation & Verification

1. Verify Coolify Status
- Confirm Coolify is accessible at https://coolify.timothynguyen.work
- Verify /vps/ci-cd/coolify/.env contains required values
- Test API access using existing curl pattern
2. Repository Analysis
- Analyze tannguyencse19/nuel-inc repository structure
- Identify application type and requirements
- Determine base directory and port configuration

Phase 2: GitHub App Integration Setup

1. Install Coolify GitHub App (User Action Required)
- Navigate to Coolify Dashboard → Sources → + Add → GitHub → GitHub App
- Install GitHub App in your GitHub account
- Grant access ONLY to tannguyencse19/nuel-inc
- Verify connection in Coolify Sources
2. Create Application in Coolify (User Action Required)
- Applications → + New Application
- Select GitHub App source
- Choose nuel-inc repository
- Configure branch: main
- Set build pack (auto-detect Dockerfile)
- Configure port and base directory
3. Create Dockerfile in the targeted GitHub Repository
- Understand current state of tannguyencse19/nuel-inc using GitHub MCP Server
- Create appropriate Dockerfile so Coolify can build the image for deployment

Phase 3: Testing & Validation

1. Initial Deployment Test
- Make small commit to main branch
- Verify webhook triggers deployment
- Check application accessibility
2. Deployment Pipeline Verification
- Push to main branch → Triggers new deployment
- GitHub App webhook → Notifies Coolify of changes
- Deployment pipeline → Build → Deploy → Health check

🔒 Security Compliance

- All secret names documented, values referenced from .env
- No secret values in any documentation
- GitHub secrets follow GITHUBB_TIMOTHYNGUYEN_ prefix pattern