#!/bin/bash

# Metabase Self-Host Uninstallation Script
# This script completely removes Metabase and all associated data

set -e

echo "🗑️  Starting Metabase Self-Host Uninstallation..."

# Set the working directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Working directory: $SCRIPT_DIR"

# Warning about data loss
echo ""
echo "⚠️  WARNING: This will completely remove Metabase and ALL DATA!"
echo "   - All Metabase configurations will be lost"
echo "   - All dashboards and questions will be deleted"
echo "   - Database data will be permanently removed"
echo "   - Docker images will be removed"
echo ""

read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation
if [ "$confirmation" != "yes" ]; then
    echo "❌ Uninstallation cancelled."
    exit 1
fi

echo "🛑 Stopping Metabase services..."
if docker compose ps -q &> /dev/null; then
    docker compose down --remove-orphans || true
else
    echo "   No running services found"
fi

echo "🧹 Removing Docker containers..."
# Remove containers if they exist
if docker ps -aq --filter "name=metabase" | grep -q .; then
    docker rm -f $(docker ps -aq --filter "name=metabase") || true
fi

if docker ps -aq --filter "name=metabase_postgres" | grep -q .; then
    docker rm -f $(docker ps -aq --filter "name=metabase_postgres") || true
fi

echo "💾 Removing Docker volumes..."
# Remove named volumes
docker volume rm metabase-data 2>/dev/null || true
docker volume rm metabase_metabase-data 2>/dev/null || true
docker volume rm postgres-data 2>/dev/null || true
docker volume rm metabase_postgres-data 2>/dev/null || true

# Remove any dangling volumes
docker volume ls -q --filter "dangling=true" | grep -E "(metabase|postgres)" | xargs -r docker volume rm || true

echo "🌐 Removing Docker network..."
docker network rm metabase-network 2>/dev/null || true
docker network rm metabase_metabase-network 2>/dev/null || true

echo "🖼️  Removing Docker images..."
docker rmi metabase/metabase:latest 2>/dev/null || true
docker rmi postgres:15-alpine 2>/dev/null || true

# Keep the template and scripts, only remove generated files
echo "   ✅ Preserved template files and management scripts"

echo "🧽 Running Docker system cleanup..."
docker system prune -f || true

echo ""
echo "✅ Metabase Self-Host Uninstallation Complete!"
echo ""
echo "🔄 To reinstall:"
echo "   ./INSTALL.sh"
echo ""
echo "📝 What was removed:"
echo "   ✅ All Docker containers"
echo "   ✅ All Docker volumes and data"
echo "   ✅ Docker network"
echo "   ✅ Docker images"
echo ""
echo "📝 What was preserved:"
echo "   ✅ Management scripts (INSTALL.sh, START.sh, STOP.sh)"
echo "   ✅ Docker Compose configuration"
echo "   ✅ Environment template (.example.env)"
echo ""