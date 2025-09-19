# Active Plan: Deploy Metabase to Coolify using Docker Compose APPLICATION

## Task Overview
Deploy Metabase from the self-host-template to Coolify as a Docker Compose APPLICATION in the vps/ci-cd/metabase working directory.

## Research Summary
- Coolify supports "Docker Compose Empty" application type for deploying multi-service applications
- Coolify extends standard Docker Compose with special features like SERVICE_FQDN, SERVICE_PASSWORD, etc.
- Source material: Complete Metabase setup in /root/CODE/TIMOTHY/devops/self-host-template/metabase/
- Target deployment: Coolify APPLICATION using docker-compose configuration
- Coolify API available at https://coolify.timothynguyen.work with token authentication

## Implementation Plan

### Part 1: Prepare Coolify-Compatible Docker Compose
- Copy and adapt docker-compose.yml from self-host-template/metabase to vps/ci-cd/metabase
- Modify for Coolify deployment patterns:
  * Remove host port mappings (Coolify handles routing via SERVICE_FQDN)
  * Add Coolify magic environment variables (SERVICE_FQDN_METABASE)
  * Configure environment variables using Coolify syntax
  * Add required variable validation syntax
- Create .example.env with Coolify-specific placeholders
- Remove external port exposure since Coolify handles proxying

### Part 2: Create Management Scripts
- INSTALL.sh - Deploy to Coolify via API calls or provide manual setup instructions
- UNINSTALL.sh - Remove application from Coolify and cleanup
- VERIFY.sh - Check deployment status via Coolify API
- Include proper environment variable sourcing from coolify/.env

### Part 3: Documentation and Testing
- README.md with Coolify-specific deployment instructions
- Document APPLICATION creation process in Coolify UI
- Test deployment verification using Coolify API endpoints

## Key Differences from Self-Host Template
1. Remove port mappings - Coolify handles via SERVICE_FQDN
2. Use Coolify magic variables for passwords and URLs
3. Add APPLICATION-specific configuration
4. API-based management instead of direct docker compose commands

## Success Criteria
- Complete docker-compose.yml adapted for Coolify APPLICATION deployment
- Working management scripts that integrate with Coolify API
- Clear documentation for APPLICATION setup in Coolify UI
- Verified deployment through Coolify API status checks

## File Structure Plan
```
vps/ci-cd/metabase/
  docker-compose.yml          # Coolify-adapted compose file
  .example.env               # Environment template with Coolify variables
  INSTALL.sh                 # Deploy to Coolify
  UNINSTALL.sh              # Remove from Coolify  
  VERIFY.sh                 # Check deployment status
```