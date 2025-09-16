#!/bin/bash

# Metabase Self-Host Stop Script
# This script stops the Metabase services while preserving data

set -e

echo "🛑 Stopping Metabase Services..."

# Set the working directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Working directory: $SCRIPT_DIR"

# Check if services are running
if ! docker compose ps -q &> /dev/null; then
    echo "ℹ️  No services appear to be running."
    exit 0
fi

echo "📊 Current service status:"
docker compose ps || true

echo ""
echo "⏳ Stopping services gracefully..."
docker compose stop

echo "✅ Services stopped successfully!"
echo ""
echo "📝 Notes:"
echo "   ✅ All data is preserved in Docker volumes"
echo "   ✅ Services can be restarted with ./START.sh"
echo "   🗑️  For complete cleanup, use ./UNINSTALL.sh"
echo ""