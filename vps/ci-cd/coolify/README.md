# Coolify Self-Hosting Installation - Docker Compose

This directory contains a simplified automated installation script for self-hosting Coolify using Docker Compose. This approach provides better control and transparency compared to the official curl-based installer.

## 🚀 Quick Start

```bash
# Simple localhost installation
sudo ./INSTALL.sh

# The script will prompt for admin email interactively
```

## 📋 What's Included

- **INSTALL.sh** - Automated installation script
- **docker-compose.yml** - Coolify stack definition
- **.env.example** - Environment configuration template

## 🔧 Features

### **System Management**
- Prerequisites validation (RAM, disk, OS)
- Docker installation and configuration
- Firewall setup (UFW) with proper port management
- Repository issue fixes (Hashicorp, nginx.lis, etc.)

### **Docker Compose Setup**
- Custom docker-compose configuration
- PostgreSQL database with persistent storage
- Redis for caching and sessions
- Soketi for real-time features
- Automatic secret generation

### **Security & Maintenance**
- fail2ban intrusion detection
- Automated daily backups
- Secure password generation
- Proper file permissions

## 🏗️ Architecture

The installation creates the following services:

```yaml
services:
  coolify:        # Main application (port 8000)
  postgres:       # Database
  redis:          # Cache & sessions  
  soketi:         # Real-time features (port 6001)
  proxy:          # Traefik proxy (optional)
```

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

## 🔍 System Requirements

- **OS**: Ubuntu 22.04+ or similar Linux distribution
- **RAM**: 4GB minimum (8GB+ recommended)
- **Disk**: 20GB+ available space
- **Ports**: 22, 80, 443, 8000 (automatically configured)

## 🛠️ Manual Configuration

If you need to customize the installation:

### Environment Variables

Edit `/data/coolify/source/.env`:

```bash
nano /data/coolify/source/.env
```

### Docker Compose

Modify the services in `/data/coolify/source/docker-compose.yml`

### Restart Services

```bash
cd /data/coolify/source
docker compose restart
```

## 📊 Post-Installation

After successful installation:

### Access Information
- **Dashboard**: http://localhost:8000
- **Admin Email**: As entered during installation
- **Admin Password**: Auto-generated (saved in report)

### Important Files
- **Installation Report**: `/root/coolify-installation-report.txt`
- **Configuration**: `/data/coolify/source/.env`
- **Logs**: `docker logs coolify`

### Maintenance Commands

```bash
# View logs
docker logs coolify

# Restart services
cd /data/coolify/source && docker compose restart

# Update Coolify (re-run installer)
sudo ./INSTALL.sh

# Manual backup
/usr/local/bin/coolify-backup.sh

# Check status
docker ps | grep coolify
```

## 🔧 Troubleshooting

### Common Issues

**Services won't start:**
```bash
# Check logs
docker compose logs

# Check system resources
docker system df
free -h
```

**Database connection issues:**
```bash
# Check database
docker exec coolify-db psql -U coolify -d coolify -c "\\l"

# Reset database
docker compose down
docker volume rm coolify_postgres_data
docker compose up -d
```

**Permission issues:**
```bash
# Fix permissions
sudo chown -R 9999:root /data/coolify
sudo chmod -R 700 /data/coolify
```

### Port Conflicts

If port 8000 is in use:

1. Stop conflicting service
2. Or modify `docker-compose.yml` ports section
3. Restart: `docker compose up -d`

### Backup & Recovery

**Manual Backup:**
```bash
# Create backup
/usr/local/bin/coolify-backup.sh

# List backups
ls -la /data/coolify/backups/
```

**Recovery:**
```bash
# Stop services
docker compose down

# Restore data (example)
tar -xzf /data/coolify/backups/coolify_backup_YYYYMMDD_HHMMSS.tar.gz -C /

# Start services
docker compose up -d
```

## 🆚 Advantages over Official Installer

### **Transparency**
- Clear docker-compose configuration
- Visible environment variables
- No hidden installation steps

### **Control**
- Easy to modify services
- Predictable file locations
- Standard Docker workflows

### **Maintenance**
- Simple updates via docker compose
- Easy backup/restore
- Clear troubleshooting paths

### **Development**
- Easy to customize for development
- Clear service dependencies
- Standard containerized approach

## 📚 Additional Resources

- **Coolify Docs**: https://coolify.io/docs
- **Docker Compose Reference**: https://docs.docker.com/compose/
- **GitHub Issues**: https://github.com/coollabsio/coolify/issues

## 🔒 Security Notes

- Admin password is auto-generated and secure
- fail2ban monitors for intrusion attempts  
- Firewall configured for essential ports only
- Regular security updates via package management
- Database and Redis are password-protected

## 📝 License

This installation script is provided as-is. Coolify itself is licensed under Apache License 2.0.