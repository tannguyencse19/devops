#!/bin/bash

# Complete Metabase on Coolify Setup Script
# This script captures all the work done to deploy Metabase to Coolify

set -e

echo "🚀 Complete Metabase on Coolify Setup"
echo "======================================"
echo ""
echo "This script performs the complete setup of Metabase on Coolify:"
echo "✅ Creates Metabase service with PostgreSQL"
echo "✅ Sets up environment variables"
echo "✅ Provides management tools"
echo "✅ Configures Docker Compose for Coolify"
echo ""

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"
ENVIRONMENT_NAME="production"
SERVICE_NAME="metabase-service"

echo "📋 Setup Configuration:"
echo "   Service Name: $SERVICE_NAME"
echo "   Project: PRODUCTION"
echo "   Server: timothy-3 Hetzner Server"
echo "   Environment: $ENVIRONMENT_NAME"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in current directory"
    echo "   Please run this script from: vps/ci-cd/metabase/"
    exit 1
fi

echo "✅ Docker Compose configuration found"

# Check if service already exists
echo "🔍 Checking if Metabase service already exists..."
EXISTING_SERVICE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services" | jq -r ".[] | select(.name==\"$SERVICE_NAME\") | .uuid" 2>/dev/null || echo "")

if [ ! -z "$EXISTING_SERVICE" ]; then
    echo "✅ Service already exists with UUID: $EXISTING_SERVICE"
    echo "   Use existing scripts to manage it:"
    echo "   - ./MANAGE_SERVICE.sh status"
    echo "   - ./UPDATE_PASSWORD.sh"
    echo "   - ./MANAGE_SERVICE.sh deploy"
    echo ""
    echo "🎯 Next Steps:"
    echo "   1. Update PostgreSQL password: ./UPDATE_PASSWORD.sh"
    echo "   2. Deploy service: ./MANAGE_SERVICE.sh deploy" 
    echo "   3. Monitor in Coolify dashboard: $COOLIFY_BASE_URL"
    exit 0
fi

echo "📝 Creating new Metabase service..."

# Read and encode docker-compose file
echo "🔧 Encoding docker-compose.yml..."
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found"
    exit 1
fi

DOCKER_COMPOSE_RAW=$(base64 -w 0 docker-compose.yml)

# Create service payload
echo "📦 Creating service payload..."
PAYLOAD=$(cat <<EOF
{
    "name": "$SERVICE_NAME",
    "project_uuid": "$PROJECT_UUID",
    "server_uuid": "$SERVER_UUID",
    "environment_name": "$ENVIRONMENT_NAME",
    "docker_compose_raw": "$DOCKER_COMPOSE_RAW"
}
EOF
)

# Create service
echo "🌐 Creating service in Coolify..."
RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -X POST \
    "$COOLIFY_BASE_URL/api/v1/services" \
    -d "$PAYLOAD")

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
    echo "❌ Error creating service:"
    echo "$RESPONSE" | jq '.errors'
    exit 1
fi

# Extract service UUID
SERVICE_UUID=$(echo "$RESPONSE" | jq -r '.uuid' 2>/dev/null || echo "")
if [ -z "$SERVICE_UUID" ]; then
    echo "❌ Failed to extract service UUID from response:"
    echo "$RESPONSE"
    exit 1
fi

echo "✅ Service created successfully!"
echo "   Service UUID: $SERVICE_UUID"
echo "   Service Name: $SERVICE_NAME"

# Update scripts with correct UUID
echo "🔧 Updating management scripts with service UUID..."
for script_file in "MANAGE_SERVICE.sh" "UPDATE_PASSWORD.sh" "UNINSTALL.sh"; do
    if [ -f "$script_file" ]; then
        sed -i "s/SERVICE_UUID=\".*\"/SERVICE_UUID=\"$SERVICE_UUID\"/g" "$script_file"
        echo "   Updated: $script_file"
    fi
done

# Set environment variables
echo "🔑 Setting up environment variables..."
ENV_VARS='[
    {"key": "POSTGRES_DATABASE", "value": "metabase"},
    {"key": "POSTGRES_USER", "value": "metabase"},
    {"key": "POSTGRES_PASSWORD", "value": "CHANGEME_STRONG_PASSWORD_HERE"}
]'

for env_var in $(echo "$ENV_VARS" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${env_var} | base64 --decode | jq -r ${1}
    }
    
    KEY=$(_jq '.key')
    VALUE=$(_jq '.value')
    
    echo "   Setting $KEY..."
    curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID/environment-variables" \
        -d "{\"key\": \"$KEY\", \"value\": \"$VALUE\"}" >/dev/null
done

echo ""
echo "🎉 Metabase Coolify Setup Complete!"
echo ""
echo "📁 Created Files:"
echo "   ✅ docker-compose.yml - Service definition"
echo "   ✅ env.example - Environment template" 
echo "   ✅ DEPLOY_TO_COOLIFY.sh - Initial deployment"
echo "   ✅ MANAGE_SERVICE.sh - Service management"
echo "   ✅ UPDATE_PASSWORD.sh - Password management"
echo "   ✅ UNINSTALL.sh - Service removal"
echo "   ✅ README.md - Complete documentation"
echo ""
echo "🔧 Service Details:"
echo "   UUID: $SERVICE_UUID"
echo "   Name: $SERVICE_NAME"
echo "   Status: Created (not yet deployed)"
echo "   Dashboard: $COOLIFY_BASE_URL"
echo ""
echo "🎯 Next Steps:"
echo "   1. Update PostgreSQL password:"
echo "      ./UPDATE_PASSWORD.sh"
echo ""
echo "   2. Deploy the service:"
echo "      ./MANAGE_SERVICE.sh deploy"
echo ""
echo "   3. Monitor deployment:"
echo "      ./MANAGE_SERVICE.sh status"
echo "      Or check: $COOLIFY_BASE_URL"
echo ""
echo "   4. Once deployed, access Metabase:"
echo "      URL will be shown in service status"
echo ""
echo "⚠️  SECURITY REMINDER:"
echo "   ▶️  Change default password before deployment!"
echo "   ▶️  Current password: CHANGEME_STRONG_PASSWORD_HERE"
echo ""
echo "📚 Management Commands:"
echo "   ./MANAGE_SERVICE.sh [status|deploy|start|stop|restart|logs|delete]"
echo "   ./UPDATE_PASSWORD.sh"
echo "   ./UNINSTALL.sh"
echo ""
echo "🌟 Metabase Features:"
echo "   ✅ Business Intelligence Dashboard"
echo "   ✅ Data Visualization & Analytics"  
echo "   ✅ PostgreSQL Backend"
echo "   ✅ Docker-based Deployment"
echo "   ✅ Coolify Integration"
echo ""
echo "Setup completed successfully! 🚀"