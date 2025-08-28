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

# Coolify API Access Pattern

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

# Connect GitHub Repo with Coolify CI/CD Process

This section documents how to connect a GitHub repository to Coolify using the **Private Repository (with GitHub App)** method and achieve automatic CI/CD deployment. **NOTES**: This method doesn't require to setup GitHub Action in the GitHub repository.

**Setup Process**

## 1. Install Coolify GitHub App

**NOTES**: When you need to do this section, instead of you doing, instruct the user how to do it AND WAIT FOR THEM TO FINISH.

**In Coolify Dashboard:**
1. Navigate to **Sources** section
2. Click **+ Add** → **GitHub** → **GitHub App**
3. Click **Install GitHub App**

**In GitHub (Redirected):**
1. Choose **Install** on the Coolify GitHub App page
2. Select repository access:
   - **Recommended**: "Only select repositories"
   - Choose your target repository
3. Click **Install & Authorize**
4. You'll be redirected back to Coolify

**Back in Coolify:**
1. Verify the GitHub App source appears in your Sources list
2. Source should show connected status with repository access

## 2. Create Application from Connected Repository

**NOTES**: When you need to do this section, instead of you doing, instruct the user how to do it AND WAIT FOR THEM TO FINISH.

**Application Creation:**
1. Navigate to **Applications** → **+ New Application**
2. **Source**: Select your installed GitHub App
3. **Repository**: Choose your want to deploy repository
4. **Branch**: Accept default `main`
5. **Build Pack**: Accept auto-detected `Dockerfile`
6. **Port mapping**
   - Port Mapping format: <YOUR_WANTING_PORT>:<DOCKER_FILE_EXPOSE_PORT>
   - Port Expose: <YOUR_WANTING_PORT>

**Configuration Settings (Accept Defaults):**
- **Base Directory**: Choose your code directory
- **Port**: Choose your port

## 3. Create `Dockerfile` in the targeted GitHub Repository
1. Understand the current state of the targeted GitHub Repository using `github` MCP Server
2. After understanded, create `Dockerfile` so that Coolify can use that to build the image for the deployment 

**NOTES**: 

- AVOID using `nginx` because when creating `Dockerfile` because it might complex thing
- Specify notes for when working with specify system

a) Working with Vite app
  * The expose syntax in `Dockerfile` must be like this

```
EXPOSE 4173
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4173"]
```

  * To fix the error of Vite "Blocked request. This host ("<DOMAIN>") is not allowed"
   + Specify this in `Dockerfile`

```Dockerfile
# Placeholder, will override when build image in Coolify
# Leverage Coolify default environment: https://coolify.io/docs/knowledge-base/environment-variables
# Use `COOLIFY_FQDN` instead of `COOLIFY_URL` because `COOLIFY_URL` contain the https, which Vite don't accept 
ARG COOLIFY_FQDN
ENV VITE_ALLOWED_DOMAIN=${COOLIFY_FQDN}
```

   + Update this in `vite.config.ts`

```ts
import { defineConfig, loadEnv } from 'vite'

...

export default defineConfig(({ mode }) => {
   const env = loadEnv(mode, process.cwd(), '')

   ...

   return {
      ...,
      preview: {
         ...(env.VITE_ALLOWED_DOMAIN ? { allowedHosts: [env.VITE_ALLOWED_DOMAIN] } : {}),
      },
      server: {
         ...(env.VITE_ALLOWED_DOMAIN ? { allowedHosts: [env.VITE_ALLOWED_DOMAIN] } : {}),
      },
   }
})
```


### 🔄 CI/CD Workflow

- **Push to main branch** → Triggers new deployment
- **GitHub App webhook** → Notifies Coolify of changes
- **Deployment pipeline** → Build → Deploy → Health check

# GitHub Actions Secret Configuration

**ALL GitHub repository secrets MUST have prefix: `GITHUBB_TIMOTHYNGUYEN_`**
- Format: `GITHUBB_TIMOTHYNGUYEN_[PURPOSE]`
- Examples: `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL`

**Environment Variable Naming in Workflows**:
- ✅ **Correct**: `GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}`
- ❌ **Wrong**: `COOLIFY_URL: ${{ secrets.GITHUBB_TIMOTHYNGUYEN_COOLIFY_URL }}` (creates unnecessary alias)

**Secret values can be found in**: `/vps/ci-cd/coolify/.env`

# Cloudflare Tunnel Integration with Coolify

This section documents how to set up Cloudflare Tunnels with Coolify to expose applications through custom domains without opening server ports. 

**NOTES**: This whole process is done totally BY USER. Wait for them to finish, then you perform Coolify API check to verify if they have done the step correct.

## 1. Create Cloudflare Tunnel

**In Cloudflare Dashboard:**
1. Navigate to **Cloudflare Zero Trust** → **Networks** → **Tunnels**
2. Click **"Add a tunnel"**
3. Select **"Cloudflared"** as tunnel type
4. **Name**: Give tunnel a name (e.g., "coolify-tunnel")
5. **Save the tunnel token** from the install command (long token starting with `eyJh...`)
6. Configure **Public Hostname**
7. Click **"Save Tunnel"**

## 2. Deploy Cloudflared App on Coolify

**In Coolify Dashboard (`https://coolify.timothynguyen.work`):**
0. Go to a **Projects**
1. Create new resource
2. **Search**: "Cloudflared" and select it
3. Navigate to **"Environment Variables"** section
4. **Add environment variable**:
   - **Name**: `TUNNEL_TOKEN`
   - **Value**: `<YOUR_TUNNEL_TOKEN_FROM_STEP_1>`
5. **Deploy** the Cloudflared application

## 3. Configure DNS Records Manually

**CRITICAL**: Coolify cannot auto-create DNS records. You must create them manually.

**Go to Tunnels dashboard**
1. Go to the tunnel you just created
2. Go to **Public hostnames** --> Click on **Add a public hostname** button

## 4. Update Application Domains in Coolify

**For each application (e.g., demo-develop-app-with-tdd):**
1. Go to application's settings  
2. Update the application domain
3. **Save and redeploy**

# Limitation

- Currently can't push to GitHub packages even use Deploy Keys or GitHub Apps