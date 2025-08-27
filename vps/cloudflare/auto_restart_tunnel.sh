#!/usr/bin/env bash
set -euo pipefail

ROOT="/root/devops/cloudflare"
CONFIG_YML="${ROOT}/config.yml"
SERVICE_NAME="cloudflare-tunnel-auto-restart"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Check if config exists
if [ ! -f "$CONFIG_YML" ]; then
    echo "ERROR: Missing ${CONFIG_YML}. Run install_tunnel.sh first." >&2
    exit 1
fi

# Function to start/restart tunnel (used by systemd)
if [ "${1:-}" = "run" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting tunnel..."
    
    # Kill any existing tunnel processes
    existing_pid="$(pgrep -f "cloudflared.*tunnel run" || true)"
    if [ -n "$existing_pid" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stopping existing tunnel (PID: $existing_pid)"
        kill "$existing_pid" 2>/dev/null || true
        sleep 2
    fi
    
    # Start new tunnel
    exec cloudflared --config "$CONFIG_YML" --no-autoupdate tunnel run
fi

# Main execution - setup auto-restart service
echo "==> Setting up auto-restart service..."

# Create the systemd service file
sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=Cloudflare Tunnel Auto-Restart
Documentation=https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=${ROOT}/auto_restart_tunnel.sh run
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=cloudflare-tunnel

# Environment
Environment=PATH=/usr/local/bin:/usr/bin:/bin
WorkingDirectory=${ROOT}

[Install]
WantedBy=multi-user.target
EOF

# Make this script executable
chmod +x "${ROOT}/auto_restart_tunnel.sh"

# Stop any existing service
sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true

# Reload systemd and enable the service
echo "==> Enabling and starting systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "==> Service status:"
sudo systemctl status "$SERVICE_NAME" --no-pager

echo
echo "✅ Auto-restart setup complete!"
echo "Your tunnel is now running and will automatically restart if it crashes!"
echo
echo "Useful commands:"
echo "- View logs: sudo journalctl -u $SERVICE_NAME -f"
echo "- Stop service: sudo systemctl stop $SERVICE_NAME"
echo "- Start service: sudo systemctl start $SERVICE_NAME"