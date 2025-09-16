# Metabase on Coolify as Application

This directory contains scripts and configurations for deploying Metabase to Coolify as an Application with proper domain management and external PostgreSQL database.

## 📋 What's Included

- **docker-compose.yml** - Original service-based configuration (legacy)
- **docker-compose.app.yml** - Application-optimized configuration  
- **Dockerfile** - Custom Metabase image for applications
- **.example.env** - Environment variables template
- **DEPLOY_APP_TO_COOLIFY.sh** - Application deployment script
- **MANAGE_METABASE_COOLIFY.sh** - Comprehensive management script
- **SETUP_AS_APPLICATION.md** - Manual setup guide
- **UPDATE_PASSWORD.sh** - Password management script

## 🚀 Quick Start (Application Deployment)

### 1. Deploy PostgreSQL Database

```bash
cd vps/ci-cd/metabase
./DEPLOY_APP_TO_COOLIFY.sh
```

This will:
- Create PostgreSQL service for Metabase
- Set up default environment variables
- Provide setup instructions for the application

### 2. Create Metabase Application (Manual)

Since Coolify Applications require dashboard access:

```bash
./MANAGE_METABASE_COOLIFY.sh setup-manual
```

This provides step-by-step instructions to:
- Create Metabase application in Coolify dashboard
- Configure proper domain management
- Set up port mappings (5700:3000)
- Connect to PostgreSQL database

### 3. Check Status

```bash
./MANAGE_METABASE_COOLIFY.sh full-status
```

This shows:
- PostgreSQL service status
- Port availability
- Configuration summary

### 4. Access Metabase

Once deployed via dashboard, Metabase will be accessible through:
- Auto-generated Coolify domain (recommended)
- Direct access: `http://SERVER_IP:5700`

**Complete setup guide**: See `SETUP_AS_APPLICATION.md`

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
- **Metabase** (port 5700): Business intelligence dashboard (maps to internal 3000)
- **PostgreSQL** (port 5710): Database backend for Metabase (maps to internal 5432)

### Network
- Internal Docker network for service communication
- Coolify proxy handles external access on port 5700
- PostgreSQL available for external connections on port 5710

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