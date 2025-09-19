#!/bin/bash

# Metabase Self-Host Start Script
# This script starts the Metabase services

set -e

echo "🚀 Starting Metabase Services..."

# Set the working directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Working directory: $SCRIPT_DIR"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "   Please run ./INSTALL.sh first to set up the environment."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "🔧 Starting Docker Compose services..."
docker compose up -d

echo "⏳ Waiting for services to start..."

# Wait for PostgreSQL to be ready
echo "🗄️  Checking PostgreSQL status..."
timeout=120
counter=0
while ! docker exec metabase_postgres pg_isready -U metabase -d metabase &> /dev/null; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for PostgreSQL to be ready"
        echo "📋 PostgreSQL logs:"
        docker compose logs --tail=20 postgres
        exit 1
    fi
    echo "   ... PostgreSQL starting ($counter/$timeout seconds)"
    sleep 3
    counter=$((counter + 3))
done

echo "✅ PostgreSQL is ready!"

# Wait for Metabase to be ready
echo "📊 Checking Metabase status..."
timeout=300
counter=0
while ! curl -f http://localhost:5700/api/health &> /dev/null; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for Metabase to be ready"
        echo "📋 Metabase logs:"
        docker compose logs --tail=20 metabase
        exit 1
    fi
    echo "   ... Metabase starting ($counter/$timeout seconds)"
    sleep 5
    counter=$((counter + 5))
done

echo "✅ Metabase is ready!"

echo ""
echo "🎉 All services are running successfully!"
echo ""
echo "📋 Access Information:"
echo "   🌐 Metabase Web UI: http://localhost:5700"
echo "   🗄️  PostgreSQL Database: localhost:5710"
echo ""
echo "📊 Service Status:"
docker compose ps
echo ""