#!/bin/bash

# Metabase Deployment to Coolify Script
# This script creates a Metabase service in Coolify

set -e

echo "🚀 Starting Metabase deployment to Coolify..."

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"
ENVIRONMENT_NAME="production"
SERVICE_NAME="metabase-service"

# Check if service already exists
echo "🔍 Checking if Metabase service already exists..."
EXISTING_SERVICE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services" | jq -r ".[] | select(.name==\"$SERVICE_NAME\") | .uuid" || echo "")

if [ ! -z "$EXISTING_SERVICE" ]; then
    echo "⚠️  Service '$SERVICE_NAME' already exists with UUID: $EXISTING_SERVICE"
    echo "   Please delete it first if you want to recreate it."
    exit 1
fi

# Read and encode docker-compose file
echo "📝 Encoding docker-compose.yml..."
DOCKER_COMPOSE_RAW=$(base64 -w 0 docker-compose.yml)

# Create service payload
echo "🔧 Creating service payload..."
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

# Set environment variables
echo "🔑 Setting up environment variables..."

# Default environment variables
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
echo "🎉 Metabase service deployment completed!"
echo ""
echo "📋 Next Steps:"
echo "   1. Go to Coolify dashboard: $COOLIFY_BASE_URL"
echo "   2. Navigate to PRODUCTION project > Services > $SERVICE_NAME"
echo "   3. Update the POSTGRES_PASSWORD environment variable with a strong password"
echo "   4. Deploy the service"
echo "   5. Once deployed, access Metabase through the generated domain"
echo ""
echo "⚠️  IMPORTANT: Change the default POSTGRES_PASSWORD before deployment!"
echo "   Current value: CHANGEME_STRONG_PASSWORD_HERE"
echo ""
echo "Service UUID: $SERVICE_UUID"