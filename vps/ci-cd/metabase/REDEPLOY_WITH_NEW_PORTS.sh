#!/bin/bash

# Redeploy Metabase Service with Updated Ports
# This script removes the existing service and recreates it with ports 5700/5710

set -e

echo "🔄 Redeploying Metabase with Updated Ports (5700/5710)"
echo "======================================================"
echo ""

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"
ENVIRONMENT_NAME="production"
SERVICE_NAME="metabase-service"
EXISTING_UUID="x0sw44kkggswgw80kgooo804"

echo "⚠️  This will remove the existing service and recreate it with correct ports:"
echo "   Old: Metabase port 3000, PostgreSQL port 5432"
echo "   New: Metabase port 5700, PostgreSQL port 5710"
echo ""

# Check if existing service exists
echo "🔍 Checking existing service..."
SERVICE_CHECK=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services/$EXISTING_UUID" | jq -r '.name' 2>/dev/null || echo "")

if [ "$SERVICE_CHECK" == "$SERVICE_NAME" ]; then
    echo "✅ Found existing service: $SERVICE_NAME"
    echo "🗑️  Removing existing service..."
    
    # Stop service first
    curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$EXISTING_UUID/stop" >/dev/null
    
    sleep 5
    
    # Delete service
    RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X DELETE \
        "$COOLIFY_BASE_URL/api/v1/services/$EXISTING_UUID")
    
    if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
        echo "❌ Error deleting service:"
        echo "$RESPONSE" | jq '.errors'
        exit 1
    fi
    
    echo "✅ Existing service removed"
    sleep 3
else
    echo "ℹ️  No existing service found, creating new one"
fi

# Read and encode updated docker-compose file
echo "📝 Encoding updated docker-compose.yml with ports 5700/5710..."
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found"
    exit 1
fi

DOCKER_COMPOSE_RAW=$(base64 -w 0 docker-compose.yml)

# Create service payload
echo "📦 Creating new service payload..."
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
echo "🌐 Creating new service in Coolify..."
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
NEW_SERVICE_UUID=$(echo "$RESPONSE" | jq -r '.uuid' 2>/dev/null || echo "")
if [ -z "$NEW_SERVICE_UUID" ]; then
    echo "❌ Failed to extract service UUID from response:"
    echo "$RESPONSE"
    exit 1
fi

echo "✅ New service created successfully!"
echo "   Service UUID: $NEW_SERVICE_UUID"
echo "   Service Name: $SERVICE_NAME"

# Update management scripts with new UUID
echo "🔧 Updating management scripts with new service UUID..."
for script_file in "MANAGE_SERVICE.sh" "UPDATE_PASSWORD.sh" "UNINSTALL.sh" "COMPLETE_METABASE_COOLIFY_SETUP.sh"; do
    if [ -f "$script_file" ]; then
        sed -i "s/SERVICE_UUID=\".*\"/SERVICE_UUID=\"$NEW_SERVICE_UUID\"/g" "$script_file"
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
        "$COOLIFY_BASE_URL/api/v1/services/$NEW_SERVICE_UUID/environment-variables" \
        -d "{\"key\": \"$KEY\", \"value\": \"$VALUE\"}" >/dev/null
done

echo ""
echo "🎉 Metabase Service Redeployment Complete!"
echo ""
echo "🔧 Updated Configuration:"
echo "   Service UUID: $NEW_SERVICE_UUID"
echo "   Metabase Port: 5700 (external) → 3000 (internal)"
echo "   PostgreSQL Port: 5710 (external) → 5432 (internal)"
echo "   Coolify Proxy: Enabled on port 5700"
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
echo ""
echo "   4. Access Metabase:"
echo "      URL: http://SERVER_IP:5700"
echo "      OR: Check Coolify generated domain"
echo ""
echo "✅ Port Configuration Updated Successfully!"