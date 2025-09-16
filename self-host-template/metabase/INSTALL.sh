#!/bin/bash

# Metabase Self-Host Installation Script
# This script sets up Metabase with PostgreSQL using Docker Compose

set -e

echo "🚀 Starting Metabase Self-Host Installation..."

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker with compose plugin is not installed. Please install Docker first."
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose plugin is not available. Please install Docker Compose plugin first."
    exit 1
fi

# Set the working directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Working directory: $SCRIPT_DIR"

# Check if .env file exists, if not copy from template
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    if [ -f .example.env ]; then
        cp .example.env .env
        echo "✅ Created .env file from .example.env"
        echo "⚠️  Please edit .env file and update the POSTGRES_PASSWORD before continuing."
        echo "⚠️  Current password is set to placeholder: <STRONG_PASSWORD_HERE>"
        echo ""
        read -p "Press Enter after you have updated the .env file..."
    else
        echo "❌ .example.env file not found!"
        exit 1
    fi
else
    echo "✅ .env file already exists"
fi

# Check if password is still placeholder
if grep -q "<STRONG_PASSWORD_HERE>" .env; then
    echo "❌ Please update the POSTGRES_PASSWORD in .env file. It's still set to placeholder."
    exit 1
fi

echo "🔍 Checking current Docker setup..."

# Stop and remove existing containers if they exist
if docker ps -a --format "table {{.Names}}" | grep -E "metabase|metabase_postgres" &> /dev/null; then
    echo "🛑 Stopping and removing existing Metabase containers..."
    docker compose down --remove-orphans || true
fi

echo "📥 Pulling Docker images..."
docker compose pull

echo "🔧 Creating and starting services..."
docker compose up -d

echo "⏳ Waiting for services to be healthy..."

# Wait for PostgreSQL to be ready
echo "🗄️  Waiting for PostgreSQL to be ready..."
timeout=300
counter=0
while ! docker exec metabase_postgres pg_isready -U metabase -d metabase &> /dev/null; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for PostgreSQL to be ready"
        docker compose logs postgres
        exit 1
    fi
    echo "   ... still waiting for PostgreSQL ($counter/$timeout seconds)"
    sleep 5
    counter=$((counter + 5))
done

echo "✅ PostgreSQL is ready!"

# Wait for Metabase to be ready
echo "📊 Waiting for Metabase to be ready..."
timeout=600
counter=0
while ! curl -f http://localhost:5700/api/health &> /dev/null; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for Metabase to be ready"
        docker compose logs metabase
        exit 1
    fi
    echo "   ... still waiting for Metabase ($counter/$timeout seconds)"
    sleep 10
    counter=$((counter + 10))
done

echo "✅ Metabase is ready!"

echo ""
echo "🎉 Metabase Self-Host Installation Complete!"
echo ""
echo "📋 Access Information:"
echo "   🌐 Metabase Web UI: http://localhost:5700"
echo "   🗄️  PostgreSQL Database: localhost:5710"
echo "   👤 Database User: metabase"
echo "   🔗 Database Name: metabase"
echo ""
echo "📖 Management Commands:"
echo "   ./START.sh    - Start services"
echo "   ./STOP.sh     - Stop services"
echo "   ./UNINSTALL.sh - Complete cleanup"
echo ""
echo "🔐 First-time Setup:"
echo "   1. Open http://localhost:5700 in your browser"
echo "   2. Complete the Metabase initial setup wizard"
echo "   3. The database connection is already configured"
echo ""