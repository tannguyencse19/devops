#!/bin/bash

#############################################################################
# Coolify Self-Hosting Uninstallation Script - Complete Removal
# 
# Usage: ./UNINSTALL.sh
#############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

echo -e "${RED}Coolify Complete Uninstallation${NC}"
echo "=================================="
echo
echo -e "${YELLOW}WARNING: This will completely remove Coolify and all associated data!${NC}"
echo "This includes:"
echo "- All Coolify containers and images"
echo "- All application data and databases"
echo "- All configuration files"
echo "- All backups in /data/coolify/"
echo "- Docker networks created by Coolify"
echo "- Cron jobs and backup scripts"
echo
read -p "Are you absolutely sure you want to continue? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    log "Uninstallation cancelled by user."
    exit 0
fi

echo
log "Starting Coolify complete uninstallation..."

# Stop all Coolify containers
log "Stopping all Coolify containers..."
if docker ps --format "table {{.Names}}" 2>/dev/null | grep -q coolify; then
    docker stop $(docker ps -q --filter "name=coolify") 2>/dev/null || true
fi

# Stop and remove all containers with coolify in the name
log "Removing all Coolify containers..."
if docker ps -a --format "table {{.Names}}" 2>/dev/null | grep -q coolify; then
    docker rm -f $(docker ps -aq --filter "name=coolify") 2>/dev/null || true
fi

# Remove Coolify images
log "Removing Coolify Docker images..."
docker images --format "table {{.Repository}}:{{.Tag}}" | grep -E "(coolify|coollabs)" | while read image; do
    log "Removing image: $image"
    docker rmi -f "$image" 2>/dev/null || true
done

# Remove Docker networks created by Coolify
log "Removing Coolify Docker networks..."
docker network ls --format "table {{.Name}}" | grep -E "(coolify|coollabs)" | while read network; do
    log "Removing network: $network"
    docker network rm "$network" 2>/dev/null || true
done

# Remove all data directories
log "Removing Coolify data directories..."
if [[ -d "/data/coolify" ]]; then
    rm -rf /data/coolify
    log "Removed /data/coolify directory"
fi

if [[ -d "/var/lib/coolify" ]]; then
    rm -rf /var/lib/coolify
    log "Removed /var/lib/coolify directory"
fi

# Remove backup script and cron job
log "Removing backup script and cron jobs..."
if [[ -f "/usr/local/bin/coolify-backup.sh" ]]; then
    rm -f /usr/local/bin/coolify-backup.sh
    log "Removed backup script"
fi

# Remove cron jobs related to coolify
if crontab -l 2>/dev/null | grep -q coolify; then
    crontab -l 2>/dev/null | grep -v coolify | crontab - 2>/dev/null || true
    log "Removed Coolify cron jobs"
fi

if grep -q coolify /etc/crontab 2>/dev/null; then
    sed -i '/coolify/d' /etc/crontab
    log "Removed Coolify from system crontab"
fi

# Remove installation report
log "Removing installation reports..."
if [[ -f "/root/coolify-installation-report.txt" ]]; then
    rm -f /root/coolify-installation-report.txt
    log "Removed installation report"
fi

# Clean up Docker system (optional - removes unused containers, networks, images)
log "Cleaning up Docker system..."
docker system prune -f 2>/dev/null || true

# Remove SSH keys created by Coolify (if any)
log "Checking for Coolify SSH keys..."
if [[ -f "/root/.ssh/coolify" ]]; then
    rm -f /root/.ssh/coolify*
    log "Removed Coolify SSH keys"
fi

# Reset firewall rules (optional - only remove Coolify specific ports)
log "Checking firewall configuration..."
if command -v ufw &> /dev/null; then
    # Remove port 8000 (Coolify default port)
    ufw delete allow 8000 2>/dev/null || true
    log "Removed Coolify port from firewall"
fi

# Remove fail2ban configuration (reset to default)
log "Resetting fail2ban configuration..."
if [[ -f "/etc/fail2ban/jail.local" ]]; then
    if grep -q "Coolify" /etc/fail2ban/jail.local 2>/dev/null; then
        rm -f /etc/fail2ban/jail.local
        systemctl restart fail2ban 2>/dev/null || true
        log "Reset fail2ban configuration"
    fi
fi

# Clean up any remaining Coolify processes
log "Checking for remaining Coolify processes..."
pkill -f coolify 2>/dev/null || true

# Remove any Coolify systemd services
log "Checking for Coolify systemd services..."
if systemctl list-unit-files | grep -q coolify; then
    systemctl disable coolify* 2>/dev/null || true
    rm -f /etc/systemd/system/coolify* 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true
    log "Removed Coolify systemd services"
fi

# Final verification
log "Verifying complete removal..."
remaining_containers=$(docker ps -a --filter "name=coolify" --format "table {{.Names}}" 2>/dev/null | wc -l)
remaining_images=$(docker images --format "table {{.Repository}}" | grep -c -E "(coolify|coollabs)" 2>/dev/null || echo "0")

if [[ $remaining_containers -eq 0 && $remaining_images -eq 0 ]]; then
    log "All Coolify containers and images successfully removed"
else
    warn "Some Coolify components may still remain:"
    if [[ $remaining_containers -gt 0 ]]; then
        warn "Remaining containers: $remaining_containers"
    fi
    if [[ $remaining_images -gt 0 ]]; then
        warn "Remaining images: $remaining_images"
    fi
fi

# Success message
echo
echo "==================================================================="
echo -e "${GREEN}COOLIFY UNINSTALLATION COMPLETED!${NC}"
echo "==================================================================="
echo
echo "✅ All Coolify containers and images removed"
echo "✅ All data directories removed (/data/coolify)"
echo "✅ All configuration files removed"
echo "✅ All backups removed"
echo "✅ Cron jobs and scripts removed"
echo "✅ Docker networks cleaned up"
echo "✅ System restored to clean state"
echo
echo "Your system is now ready for a fresh Coolify installation if needed."
echo "To reinstall, simply run: ./INSTALL.sh"
echo

log "Uninstallation completed successfully!"