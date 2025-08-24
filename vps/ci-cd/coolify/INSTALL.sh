#!/bin/bash

#############################################################################
# Coolify Self-Hosting Installation Script - Localhost Only
# 
# Usage: ./INSTALL.sh
#############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REQUIRED_PORTS=(22 80 443 8000)

# Logging
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $*"
}

error_exit() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Check if running as root
[[ $EUID -ne 0 ]] && error_exit "This script must be run as root. Use 'sudo $0'"

# Prompt for admin email
echo -e "${GREEN}Coolify Installation - Localhost Setup${NC}"
echo "==========================================="
echo
read -p "Enter admin email address: " ADMIN_EMAIL

# Validate email format
if [[ ! "$ADMIN_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    error_exit "Invalid email format"
fi

log "Starting Coolify installation for localhost..."
log "Admin Email: $ADMIN_EMAIL"

# System validation
log "Validating system..."
if [[ $(free -g | awk '/^Mem:/{print $2}') -lt 4 ]]; then
    warn "RAM is less than 4GB - Coolify may run slowly"
fi

if [[ $(df -BG / | awk 'NR==2{gsub("G","",$4); print $4}') -lt 20 ]]; then
    warn "Less than 20GB disk space available"
fi

# Fix repository issues and update system
log "Fixing repository issues and updating system packages..."

# Fix the Hashicorp repository issue
if ls /etc/apt/sources.list.d/ | grep -q hashicorp; then
    log "Fixing Hashicorp repository configuration..."
    rm -f /etc/apt/sources.list.d/*hashicorp* 2>/dev/null || true
fi

# Remove invalid nginx.lis file
if [ -f "/etc/apt/sources.list.d/nginx.lis" ]; then
    log "Removing invalid nginx repository file..."
    rm -f /etc/apt/sources.list.d/nginx.lis
fi

# Update with error handling
if ! apt update -y 2>/dev/null; then
    warn "Some repository errors encountered, trying to fix..."
    apt update -y --allow-releaseinfo-change 2>/dev/null || true
fi

apt install -y curl wget ufw fail2ban

# Configure firewall
if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
    log "UFW firewall already active, updating rules..."
    for port in "${REQUIRED_PORTS[@]}"; do
        ufw allow "$port" 2>/dev/null || true
    done
else
    log "Configuring firewall..."
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    for port in "${REQUIRED_PORTS[@]}"; do
        ufw allow "$port"
    done
    ufw --force enable
fi

# Install Docker
if command -v docker &> /dev/null; then
    log "Docker already installed, skipping installation..."
    # Ensure Docker is running
    if ! systemctl is-active --quiet docker; then
        log "Starting Docker service..."
        systemctl start docker
        systemctl enable docker
    fi
else
    log "Installing Docker..."
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# Function to install Coolify using docker-compose
install_coolify_docker_compose() {
    # Create Coolify directories
    log "Creating Coolify directories..."
    mkdir -p /data/coolify/{source,ssh,applications,databases,backups,services,proxy,webhooks-during-maintenance}
    mkdir -p /data/coolify/ssh/{keys,mux}
    mkdir -p /data/coolify/proxy/dynamic

    # Copy docker-compose files
    log "Setting up Coolify configuration..."
    cp "$SCRIPT_DIR/docker-compose.yml" /data/coolify/source/
    cp "$SCRIPT_DIR/.env.example" /data/coolify/source/.env

    # Generate and update environment variables
    log "Configuring environment variables..."
    sed -i "s|APP_ID=|APP_ID=$(openssl rand -hex 16)|g" /data/coolify/source/.env
    sed -i "s|APP_KEY=|APP_KEY=base64:$(openssl rand -base64 32)|g" /data/coolify/source/.env
    sed -i "s|DB_PASSWORD=|DB_PASSWORD=$ADMIN_PASSWORD|g" /data/coolify/source/.env
    sed -i "s|REDIS_PASSWORD=|REDIS_PASSWORD=$(openssl rand -base64 32)|g" /data/coolify/source/.env
    sed -i "s|PUSHER_APP_ID=|PUSHER_APP_ID=$(openssl rand -hex 32)|g" /data/coolify/source/.env
    sed -i "s|PUSHER_APP_KEY=|PUSHER_APP_KEY=$(openssl rand -hex 32)|g" /data/coolify/source/.env
    sed -i "s|PUSHER_APP_SECRET=|PUSHER_APP_SECRET=$(openssl rand -hex 32)|g" /data/coolify/source/.env
    sed -i "s|ROOT_USER_EMAIL=|ROOT_USER_EMAIL=$ADMIN_EMAIL|g" /data/coolify/source/.env
    sed -i "s|ROOT_USER_PASSWORD=|ROOT_USER_PASSWORD=$ADMIN_PASSWORD|g" /data/coolify/source/.env
    
    # Set proper permissions
    chown -R 9999:root /data/coolify
    chmod -R 700 /data/coolify

    # Start Coolify
    log "Starting Coolify services..."
    cd /data/coolify/source
    docker compose up -d --pull always

    # Wait for services to initialize
    log "Waiting for services to initialize..."
    sleep 45
    
    # Create initial admin user if containers started successfully
    if docker ps | grep -q coolify; then
        log "Creating admin user..."
        sleep 10  # Wait a bit more for Laravel to be ready
        docker exec coolify php artisan make:user --email="$ADMIN_EMAIL" --password="$ADMIN_PASSWORD" || {
            log "Could not create user automatically, will be done through web interface"
        }
    fi
}

# Generate secure admin password
log "Generating secure credentials..."
ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-16)

# Install Coolify
if docker ps -a --format "table {{.Names}}" 2>/dev/null | grep -q coolify; then
    log "Coolify containers found, checking status..."
    if docker ps --format "table {{.Names}}" 2>/dev/null | grep -q coolify; then
        log "Coolify is already running, skipping installation..."
    else
        log "Starting existing Coolify containers..."
        cd /data/coolify/source 2>/dev/null && docker compose start || {
            log "Coolify containers exist but can't start, reinstalling..."
            docker rm -f $(docker ps -aq --filter "name=coolify") 2>/dev/null || true
            install_coolify_docker_compose
        }
    fi
else
    log "Installing Coolify using docker-compose..."
    install_coolify_docker_compose
fi

# Wait for startup
log "Waiting for Coolify to be ready..."
sleep 30

# Verify installation
if docker ps | grep -q coolify; then
    log "Coolify is running successfully!"
else
    error_exit "Coolify installation failed"
fi

# Configure fail2ban
log "Configuring security..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl restart fail2ban

# Create simple backup script
log "Setting up backup..."
cat > /usr/local/bin/coolify-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/data/coolify/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/coolify_backup_$TIMESTAMP.tar.gz" --exclude="$BACKUP_DIR" /data/coolify/
find "$BACKUP_DIR" -name "coolify_backup_*" -mtime +7 -delete
echo "Backup completed: coolify_backup_$TIMESTAMP.tar.gz"
EOF

chmod +x /usr/local/bin/coolify-backup.sh
echo "0 2 * * * root /usr/local/bin/coolify-backup.sh" >> /etc/crontab

# Generate report
REPORT_FILE="/root/coolify-installation-report.txt"
cat > "$REPORT_FILE" << EOF
=================================================================
COOLIFY INSTALLATION REPORT
=================================================================
Installation Date: $(date)
Admin Email: $ADMIN_EMAIL
Admin Password: $ADMIN_PASSWORD

=================================================================
ACCESS INFORMATION
=================================================================
Coolify Dashboard: http://localhost:8000
Admin Username: admin
Admin Email: $ADMIN_EMAIL
Admin Password: $ADMIN_PASSWORD

=================================================================
IMPORTANT FILES
=================================================================
Configuration: /data/coolify/source/.env
Backups: /data/coolify/backups/
Backup Script: /usr/local/bin/coolify-backup.sh

=================================================================
MAINTENANCE COMMANDS
=================================================================
- Update Coolify: curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
- View logs: docker logs coolify
- Restart: cd /data/coolify/source && docker compose restart
- Backup: /usr/local/bin/coolify-backup.sh

=================================================================
EOF

chmod 600 "$REPORT_FILE"

# Success message
echo
echo "==================================================================="
echo -e "${GREEN}COOLIFY INSTALLATION COMPLETED SUCCESSFULLY!${NC}"
echo "==================================================================="
echo
echo "📋 Installation report: $REPORT_FILE"
echo "🌐 Access dashboard: http://localhost:8000"
echo "👤 Username: admin"
echo "📧 Email: $ADMIN_EMAIL"
echo "🔐 Password: $ADMIN_PASSWORD"
echo
echo "⚠️  IMPORTANT: Save the admin password securely!"
echo

log "Installation completed successfully!"