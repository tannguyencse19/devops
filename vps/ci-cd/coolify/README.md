# Coolify Self-Hosting Installation

This directory contains an automated installation script for self-hosting Coolify on localhost, an open-source alternative to Heroku, Netlify, and Vercel.

## Quick Start

```bash
# Run the installation script
sudo ./INSTALL.sh
# You will be prompted to enter your admin email address
```

## Prerequisites

### System Requirements
- **OS**: Ubuntu 22.04 LTS or 24.04 LTS (64-bit)
- **RAM**: Minimum 4GB (8GB+ recommended)
- **Disk**: Minimum 20GB available space
- **Network**: Internet connection for downloading packages

### Before Running the Script
1. **Root Access**: The script must be run with sudo or as root user
2. **Internet Connection**: Required for downloading Docker and Coolify components

## What the Script Does

### Phase 1: System Validation & Setup
- ✅ Validates system requirements (RAM, disk, OS)
- ✅ Updates system packages
- ✅ Installs required dependencies
- ✅ Configures firewall (UFW)
- ✅ Installs Docker

### Phase 2: Security Hardening
- 🔒 Configures SSH security (key-based auth only)
- 🔒 Sets up fail2ban for intrusion detection
- 🔒 Generates secure passwords and secrets
- 🔒 Hardens system settings

### Phase 3: Coolify Installation
- 🚀 Downloads and installs Coolify
- 🚀 Configures environment variables
- 🚀 Sets up localhost access on port 8000
- 🚀 Creates admin user account

### Phase 4: Monitoring & Maintenance
- 📊 Sets up system monitoring (every 5 minutes)
- 💾 Configures daily automated backups
- 🛠️ Creates maintenance scripts
- 📋 Generates detailed installation report

## Usage

Simply run the script as root:

```bash
sudo ./INSTALL.sh
```

The script will prompt you for:
- Admin email address (validated for proper format)

No command-line arguments needed!

## Post-Installation

After successful installation, you'll receive:

1. **Installation Report** (`/root/coolify-installation-report.txt`)
   - Access credentials
   - Important file locations
   - Maintenance commands

2. **Access Information**
   - Dashboard URL: `http://localhost:8000`
   - Admin username: `admin`
   - Generated secure password

3. **Maintenance Tools**
   - Monitor script: `/usr/local/bin/coolify-monitor.sh`
   - Backup script: `/usr/local/bin/coolify-backup.sh`
   - Maintenance menu: `/usr/local/bin/coolify-maintain.sh`

## File Structure After Installation

```
/data/coolify/
├── source/              # Coolify source files
├── ssh/                 # SSH keys and configs
├── applications/        # Deployed applications
├── databases/           # Database data
├── backups/             # Automated backups
├── services/            # Service configurations
├── proxy/               # Proxy configurations
└── webhooks-during-maintenance/

/var/log/
├── coolify-install.log  # Installation logs
└── coolify-monitor.log  # Monitoring logs

/usr/local/bin/
├── coolify-monitor.sh   # Monitoring script
├── coolify-backup.sh    # Backup script
└── coolify-maintain.sh  # Maintenance menu
```

## Common Operations

### Update Coolify
```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

### View Logs
```bash
# Coolify application logs
docker logs coolify

# Installation logs
cat /var/log/coolify-install.log

# Monitoring logs
cat /var/log/coolify-monitor.log
```

### Restart Coolify
```bash
cd /data/coolify/source
docker compose restart
```

### Manual Backup
```bash
/usr/local/bin/coolify-backup.sh
```

### Maintenance Menu
```bash
/usr/local/bin/coolify-maintain.sh
```

## Security Features

- 🔐 **SSH Hardening**: Key-based authentication only
- 🛡️ **Firewall**: UFW configured for essential ports only
- 🚨 **Intrusion Detection**: fail2ban monitoring
- 🔑 **Strong Passwords**: Auto-generated secure credentials
- 🔒 **SSL/TLS**: Automatic Let's Encrypt certificates

## Monitoring & Backup

### Automated Monitoring
- Runs every 5 minutes via systemd timer
- Checks Docker service health
- Monitors disk and memory usage
- Auto-cleanup when disk usage >80%

### Automated Backups
- Daily backups at 2:00 AM
- Includes all Coolify data and databases
- Retention: 7 days
- Location: `/data/coolify/backups/`

## Troubleshooting

### Installation Issues

1. **Port conflicts**
   ```bash
   # Check what's using ports 80/443/8000
   netstat -tulpn | grep -E ':80|:443|:8000'
   ```

3. **Docker issues**
   ```bash
   # Check Docker status
   systemctl status docker
   docker --version
   ```

### Access Issues

1. **Can't access dashboard**
   - Verify firewall allows ports 80/443/8000
   - Check if Coolify containers are running
   - Try accessing `http://localhost:8000` directly

2. **Forgot admin password**
   - Check installation report: `/root/coolify-installation-report.txt`
   - Reset via Coolify interface or database

### Log Locations

- Installation: `/var/log/coolify-install.log`
- Monitoring: `/var/log/coolify-monitor.log`
- Coolify App: `docker logs coolify`
- System: `/var/log/syslog`

## Support & Documentation

- 📖 **Official Docs**: https://coolify.io/docs
- 💬 **Discord**: https://discord.gg/xhBcc7YnpU
- 🐛 **GitHub Issues**: https://github.com/coollabsio/coolify/issues
- 🌟 **GitHub Repo**: https://github.com/coollabsio/coolify

## License

This installation script is provided as-is for educational and deployment purposes. Coolify itself is licensed under the Apache License 2.0.