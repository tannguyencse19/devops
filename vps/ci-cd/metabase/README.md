# Metabase on Coolify

This directory contains scripts and configurations for deploying Metabase to Coolify using Docker Compose.

## 📋 What's Included

- **docker-compose.yml** - Metabase + PostgreSQL service definition for Coolify
- **env.example** - Environment variables template
- **DEPLOY_TO_COOLIFY.sh** - Initial deployment script
- **UPDATE_PASSWORD.sh** - Password management script
- **MANAGE_SERVICE.sh** - Service management script

## 🚀 Quick Start

### 1. Deploy to Coolify

```bash
cd vps/ci-cd/metabase
./DEPLOY_TO_COOLIFY.sh
```

This will:
- Create a new Metabase service in Coolify
- Set up default environment variables
- Display the service UUID for management

### 2. Update PostgreSQL Password

**CRITICAL:** Change the default password before first deployment:

```bash
./UPDATE_PASSWORD.sh
```

This will:
- Prompt for a strong password
- Update the POSTGRES_PASSWORD environment variable
- Provide next steps for deployment

### 3. Deploy the Service

```bash
./MANAGE_SERVICE.sh deploy
```

Or use the Coolify dashboard:
1. Go to https://coolify.timothynguyen.work
2. Navigate to PRODUCTION project > Services > metabase-service
3. Click Deploy

### 4. Access Metabase

Once deployed, Metabase will be accessible through the automatically generated Coolify domain. Check the service status to get the URL:

```bash
./MANAGE_SERVICE.sh status
```

## 🔧 Service Management

### Check Status
```bash
./MANAGE_SERVICE.sh status
```

### Deploy/Redeploy
```bash
./MANAGE_SERVICE.sh deploy
```

### Start/Stop/Restart
```bash
./MANAGE_SERVICE.sh start
./MANAGE_SERVICE.sh stop
./MANAGE_SERVICE.sh restart
```

### View Logs
```bash
./MANAGE_SERVICE.sh logs
```

### Delete Service
```bash
./MANAGE_SERVICE.sh delete
```

## 🌐 Architecture

### Services
- **Metabase** (port 3000): Business intelligence dashboard
- **PostgreSQL** (port 5432): Database backend for Metabase

### Network
- Internal Docker network for service communication
- Coolify proxy handles external access
- No external ports needed (all through Coolify proxy)

### Data Persistence
- PostgreSQL data: Docker volume `postgres-data`
- Metabase plugins: Docker volume `metabase-data`

### Health Checks
- Metabase: HTTP health check on `/api/health`
- PostgreSQL: `pg_isready` command
- 5-minute startup period for Metabase initialization

## ⚙️ Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| POSTGRES_DATABASE | metabase | PostgreSQL database name |
| POSTGRES_USER | metabase | PostgreSQL username |
| POSTGRES_PASSWORD | *Required* | PostgreSQL password (set via script) |

## 🔑 Security Configuration

### Secret Key Names
- `POSTGRES_PASSWORD` - Database password for Metabase PostgreSQL

### Password Requirements
- Minimum 12 characters
- Include uppercase, lowercase, numbers, and special characters
- Use the `UPDATE_PASSWORD.sh` script to set securely

## 📊 Service Information

### Current Deployment
- **Service UUID**: `x0sw44kkggswgw80kgooo804`
- **Service Name**: `metabase-service`
- **Project**: PRODUCTION
- **Server**: timothy-3 Hetzner Server

### Coolify Details
- **Dashboard**: https://coolify.timothynguyen.work
- **API Token**: Stored in deployment scripts
- **Environment**: production

## 🔄 Domain and Access

Coolify automatically generates domains for services. The Metabase interface will be available at the assigned domain once deployed.

To get the current access URL:
```bash
./MANAGE_SERVICE.sh status
```

## 🎯 First-Time Setup

1. **Deploy service**: `./DEPLOY_TO_COOLIFY.sh`
2. **Set password**: `./UPDATE_PASSWORD.sh`
3. **Deploy**: `./MANAGE_SERVICE.sh deploy`
4. **Wait for deployment**: Monitor in Coolify dashboard
5. **Access Metabase**: Use URL from status command
6. **Complete setup**: Follow Metabase initial setup wizard

## 🔍 Troubleshooting

### Service won't start
- Check Coolify dashboard logs
- Verify PostgreSQL password is set
- Ensure sufficient server resources

### Database connection issues
- Verify environment variables match
- Check PostgreSQL container health
- Review network connectivity

### Access issues
- Confirm deployment completed successfully
- Check Coolify proxy configuration
- Verify domain generation

## 📚 Additional Resources

- [Metabase Documentation](https://www.metabase.com/docs/)
- [Coolify Documentation](https://coolify.io/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Service UUID**: `x0sw44kkggswgw80kgooo804`  
**Created**: 2025-09-16  
**Status**: Ready for deployment