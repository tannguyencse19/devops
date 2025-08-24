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

read -rp "Public hostname to route (e.g. app.example.com): " APP_HOSTNAME
: "${APP_HOSTNAME:?required}"

read -rp "Local service URL (e.g. http://localhost:3000): " LOCAL_SERVICE_URL
: "${LOCAL_SERVICE_URL:?required}"

TMP="$(mktemp)"
UPDATED=0

awk -v host="$APP_HOSTNAME" -v svc="$LOCAL_SERVICE_URL" '
  BEGIN { in_ingress=0; replace_next_service=0; updated=0; }
  /^ingress:/ { in_ingress=1 }
  {
    # If we previously matched hostname block, replace its service line
    if (replace_next_service == 1 && in_ingress == 1 && $1 ~ /^service:/) {
      print "    service: " svc
      replace_next_service = 0
      updated = 1
      next
    }
    # Match existing hostname entry
    if (in_ingress == 1 && $1 == "-" && $2 == "hostname:" && $3 == host) {
      print "  - hostname: " host
      replace_next_service = 1
      next
    }
    # Before the final catch-all, insert new mapping if not yet updated
    if (in_ingress == 1 && $1 == "-" && $2 == "service:" && $3 == "http_status:404" && updated == 0) {
      print "  - hostname: " host
      print "    service: " svc
      updated = 1
    }
    print $0
  }
  END {
    if (updated == 0) {
      # No catch-all found; append ingress if missing
      print "ingress:"
      print "  - hostname: " host
      print "    service: " svc
      print "  - service: http_status:404"
    }
  }
' "$CONFIG_YML" > "$TMP"

mv "$TMP" "$CONFIG_YML"

echo "==> Creating DNS route ${APP_HOSTNAME} -> ${TUNNEL_NAME}"
set +e
DNS_OUTPUT="$(cloudflared tunnel route dns "${TUNNEL_NAME}" "${APP_HOSTNAME}" 2>&1)"
DNS_RET=$?
set -e

if [ $DNS_RET -ne 0 ]; then
  if echo "$DNS_OUTPUT" | grep -q "record.*already exists"; then
    echo "WARNING: DNS record already exists for ${APP_HOSTNAME}"
    echo "You may need to:"
    echo "1. Delete the existing DNS record from Cloudflare dashboard, OR"
    echo "2. Use 'cloudflared tunnel route dns --overwrite-dns ${TUNNEL_NAME} ${APP_HOSTNAME}'"
    echo
    read -rp "Try to overwrite existing DNS record? [y/N]: " OVERWRITE
    if [[ "${OVERWRITE:-N}" =~ ^[Yy]$ ]]; then
      echo "==> Overwriting existing DNS record..."
      cloudflared tunnel route dns --overwrite-dns "${TUNNEL_NAME}" "${APP_HOSTNAME}" || echo "Failed to overwrite DNS record"
    else
      echo "==> Skipping DNS record creation (tunnel will still work if record points to Cloudflare)"
    fi
  else
    echo "DNS route creation failed: $DNS_OUTPUT"
  fi
else
  echo "DNS route created successfully"
fi

echo
echo "Route added/updated:"
echo "- Hostname: ${APP_HOSTNAME}"
echo "- Service:  ${LOCAL_SERVICE_URL}"
echo

# Check if tunnel is already running and stop it
TUNNEL_PID="$(pgrep -f "cloudflared.*tunnel run" || true)"
if [ -n "$TUNNEL_PID" ]; then
  echo "==> Stopping existing tunnel (PID: $TUNNEL_PID)..."
  kill "$TUNNEL_PID" 2>/dev/null || true
  sleep 2
fi

echo "==> Starting tunnel in background..."
nohup cloudflared --config "${CONFIG_YML}" --no-autoupdate tunnel run > "${ROOT}/tunnel.log" 2>&1 &
TUNNEL_PID=$!
echo "==> Tunnel started (PID: $TUNNEL_PID)"
echo "==> Log: ${ROOT}/tunnel.log"
echo "==> Test your hostname: https://${APP_HOSTNAME}"
