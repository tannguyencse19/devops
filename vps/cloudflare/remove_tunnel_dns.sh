#!/usr/bin/env bash
set -euo pipefail

ROOT="/root/devops/cloudflare"
CONFIG_YML="${ROOT}/config.yml"

if [ ! -f "$CONFIG_YML" ]; then
  echo "Missing ${CONFIG_YML}. Run install_tunnel.sh first." >&2
  exit 1
fi

# Read tunnel ID from config.yml
TUNNEL_ID="$(awk '/^tunnel:/ {print $2; exit}' "$CONFIG_YML")"
: "${TUNNEL_ID:?Unable to read tunnel ID from config.yml}"

# Derive tunnel name from list (maps ID -> NAME)
TUNNEL_NAME="$(cloudflared tunnel list 2>/dev/null | awk -v id="$TUNNEL_ID" 'NR>1 && $1==id {print $2; exit}')"
: "${TUNNEL_NAME:?Unable to resolve tunnel name from ID ${TUNNEL_ID}}"

# Show current hostnames
echo "Current routed hostnames:"
awk '/^ingress:/{in_ingress=1; next} in_ingress && /^  - hostname:/ {print "  " $3}' "$CONFIG_YML"
echo

read -rp "Hostname to remove (e.g. app.example.com): " APP_HOSTNAME
: "${APP_HOSTNAME:?required}"

# Check if hostname exists in config
if ! grep -q "hostname: ${APP_HOSTNAME}" "$CONFIG_YML"; then
  echo "Hostname '${APP_HOSTNAME}' not found in config." >&2
  exit 1
fi

TMP="$(mktemp)"

# Remove the hostname and its service line from config
awk -v host="$APP_HOSTNAME" '
  BEGIN { in_ingress=0; skip_next=0; }
  /^ingress:/ { in_ingress=1 }
  {
    # Skip the service line after a matching hostname
    if (skip_next == 1) {
      skip_next = 0
      next
    }
    # Skip hostname line and mark to skip next service line
    if (in_ingress == 1 && $1 == "-" && $2 == "hostname:" && $3 == host) {
      skip_next = 1
      next
    }
    print $0
  }
' "$CONFIG_YML" > "$TMP"

mv "$TMP" "$CONFIG_YML"

echo "==> Removing DNS route ${APP_HOSTNAME}"
# Note: Cloudflare doesn't have a direct "remove route" command
# The DNS record needs to be deleted via Cloudflare dashboard or API
echo "Warning: DNS record for ${APP_HOSTNAME} should be manually deleted from Cloudflare dashboard"
echo "or use: cloudflare-cli dns delete ${APP_HOSTNAME}"

echo
echo "Route removed from config:"
echo "- Hostname: ${APP_HOSTNAME}"
echo

# Check if tunnel is already running and stop it
TUNNEL_PID="$(pgrep -f "cloudflared.*tunnel run" || true)"
if [ -n "$TUNNEL_PID" ]; then
  echo "==> Stopping existing tunnel (PID: $TUNNEL_PID)..."
  kill "$TUNNEL_PID" 2>/dev/null || true
  sleep 2
fi

# Only restart tunnel if there are still hostnames configured
HOSTNAME_COUNT="$(awk '/^ingress:/{in_ingress=1; next} in_ingress && /^  - hostname:/ {count++} END {print count+0}' "$CONFIG_YML")"
if [ "$HOSTNAME_COUNT" -gt 0 ]; then
  echo "==> Restarting tunnel with updated config..."
  nohup cloudflared --config "${CONFIG_YML}" --no-autoupdate tunnel run > "${ROOT}/tunnel.log" 2>&1 &
  TUNNEL_PID=$!
  echo "==> Tunnel restarted (PID: $TUNNEL_PID)"
  echo "==> Log: ${ROOT}/tunnel.log"
else
  echo "==> No hostnames remaining, tunnel stopped"
fi
