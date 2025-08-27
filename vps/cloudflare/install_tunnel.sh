#!/usr/bin/env bash
set -euo pipefail

ROOT="/root/devops/cloudflare"
mkdir -p "$ROOT"
cd "$ROOT"

echo "==> Checking cloudflared..."
if ! command -v cloudflared >/dev/null 2>&1; then
  echo "==> Installing cloudflared..."
  sudo apt-get update -y
  sudo apt-get install -y curl gnupg
  
  # Add cloudflare gpg key
  sudo mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  
  # Add this repo to your apt repositories
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared noble main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
  
  # install cloudflared
  sudo apt-get update && sudo apt-get install cloudflared
else
  echo "==> cloudflared present: $(cloudflared --version)"
fi

if [ ! -f "${HOME}/.cloudflared/cert.pem" ]; then
  echo "==> Authenticating to Cloudflare (this opens a browser / prints a one-time URL)..."
  cloudflared tunnel login
else
  echo "==> Already authenticated."
fi

read -rp "Tunnel name (e.g. my-tunnel): " TUNNEL_NAME
: "${TUNNEL_NAME:?required}"

echo "==> Creating tunnel '${TUNNEL_NAME}' (or reusing if exists)..."
set +e
OUT="$(cloudflared tunnel create "${TUNNEL_NAME}" 2>&1)"
RET=$?
set -e
echo "$OUT"
if [ $RET -ne 0 ]; then
  echo "==> Create may have failed if tunnel exists; discovering ID..."
fi

TUNNEL_ID="$(grep -oE '[0-9a-f-]{36}' <<<"$OUT" | head -n1 || true)"
if [ -z "${TUNNEL_ID}" ]; then
  TUNNEL_ID="$(cloudflared tunnel list 2>/dev/null | awk -v n="$TUNNEL_NAME" 'NR>1 && $2==n {print $1; exit}')"
fi
if [ -z "${TUNNEL_ID}" ]; then
  echo "ERROR: Could not determine tunnel ID." >&2
  exit 1
fi
echo "==> TUNNEL_ID=${TUNNEL_ID}"

SRC_JSON="${HOME}/.cloudflared/${TUNNEL_ID}.json"
DST_JSON="${ROOT}/${TUNNEL_ID}.json"
if [ -f "$SRC_JSON" ]; then
  echo "==> Storing credentials at ${DST_JSON}"
  mv -f "$SRC_JSON" "$DST_JSON"
  chmod 600 "$DST_JSON"
else
  if [ ! -f "$DST_JSON" ]; then
    echo "WARNING: Credentials file not found at ${SRC_JSON} and not already in ${DST_JSON}." >&2
  fi
fi

CONFIG_YML="${ROOT}/config.yml"
echo "==> Writing ${CONFIG_YML}"
cat > "$CONFIG_YML" <<EOF
tunnel: ${TUNNEL_ID}
credentials-file: ${DST_JSON}

ingress:
  - service: http_status:404
EOF

echo
echo "One-time tunnel install complete."
echo "- Config: ${CONFIG_YML}"
echo "- Creds:  ${DST_JSON}"
echo
echo "Next: add hostnames via add_tunnel_dns.sh (tunnel will start automatically)"