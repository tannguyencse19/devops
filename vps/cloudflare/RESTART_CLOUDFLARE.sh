#!/bin/bash

# Restart Cloudflare service script
# This script restarts the cloudflared daemon service

set -e

echo "Restarting Cloudflare service..."

# Stop the cloudflared service
sudo systemctl stop cloudflared

# Start the cloudflared service
sudo systemctl start cloudflared

# Check the service status
echo "Checking service status..."
sudo systemctl status cloudflared --no-pager

echo "Cloudflare service restart completed."