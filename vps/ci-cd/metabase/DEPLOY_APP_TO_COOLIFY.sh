#!/bin/bash

# Metabase Application Deployment to Coolify Script
# This script creates a Metabase application in Coolify with external PostgreSQL database

set -e

echo "🚀 Starting Metabase Application deployment to Coolify..."

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"
ENVIRONMENT_NAME="production"
APP_NAME="metabase-app"
DB_SERVICE_NAME="metabase-postgres"

echo "📋 Deployment Configuration:"
echo "   Application Name: $APP_NAME"
echo "   Database Service: $DB_SERVICE_NAME"
echo "   Project: PRODUCTION"
echo "   Server: timothy-3 Hetzner Server"
echo ""

# Step 1: Create PostgreSQL Database Service
echo "🗄️  Step 1: Creating PostgreSQL database service..."

# Check if PostgreSQL service already exists
EXISTING_DB_SERVICE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services" | jq -r ".[] | select(.name==\"$DB_SERVICE_NAME\") | .uuid" || echo "")

if [ ! -z "$EXISTING_DB_SERVICE" ]; then
    echo "✅ PostgreSQL service already exists with UUID: $EXISTING_DB_SERVICE"
    DB_SERVICE_UUID="$EXISTING_DB_SERVICE"
else
    echo "📝 Creating PostgreSQL service..."
    
    # PostgreSQL docker-compose for service
    POSTGRES_COMPOSE=$(cat <<'EOF'
services:
  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    ports:
      - "5710:5432"
    environment:
      POSTGRES_DB: ${POSTGRES_DATABASE}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DATABASE}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

volumes:
  postgres-data:
    driver: local
EOF
)

    POSTGRES_COMPOSE_ENCODED=$(echo "$POSTGRES_COMPOSE" | base64 -w 0)
    
    DB_PAYLOAD=$(cat <<EOF
{
    "name": "$DB_SERVICE_NAME",
    "project_uuid": "$PROJECT_UUID",
    "server_uuid": "$SERVER_UUID",
    "environment_name": "$ENVIRONMENT_NAME",
    "docker_compose_raw": "$POSTGRES_COMPOSE_ENCODED"
}
EOF
)

    DB_RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services" \
        -d "$DB_PAYLOAD")

    # Check for errors
    if echo "$DB_RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
        echo "❌ Error creating PostgreSQL service:"
        echo "$DB_RESPONSE" | jq '.errors'
        exit 1
    fi

    DB_SERVICE_UUID=$(echo "$DB_RESPONSE" | jq -r '.uuid' 2>/dev/null || echo "")
    if [ -z "$DB_SERVICE_UUID" ]; then
        echo "❌ Failed to extract database service UUID"
        exit 1
    fi

    echo "✅ PostgreSQL service created with UUID: $DB_SERVICE_UUID"
    
    # Set PostgreSQL environment variables
    echo "🔑 Setting PostgreSQL environment variables..."
    DB_ENV_VARS='[
        {"key": "POSTGRES_DATABASE", "value": "metabase"},
        {"key": "POSTGRES_USER", "value": "metabase"},
        {"key": "POSTGRES_PASSWORD", "value": "CHANGEME_STRONG_PASSWORD_HERE"}
    ]'

    for env_var in $(echo "$DB_ENV_VARS" | jq -r '.[] | @base64'); do
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
            "$COOLIFY_BASE_URL/api/v1/services/$DB_SERVICE_UUID/environment-variables" \
            -d "{\"key\": \"$KEY\", \"value\": \"$VALUE\"}" >/dev/null
    done
fi

# Step 2: Create Metabase Application
echo ""
echo "📱 Step 2: Creating Metabase application..."

# Check if application already exists
EXISTING_APP=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/applications" | jq -r ".[] | select(.name==\"$APP_NAME\") | .uuid" || echo "")

if [ ! -z "$EXISTING_APP" ]; then
    echo "⚠️  Application '$APP_NAME' already exists with UUID: $EXISTING_APP"
    echo "   Please delete it first if you want to recreate it."
    exit 1
fi

# Create Metabase application using static image (since we have a Dockerfile)
echo "🔧 Creating Metabase application..."

APP_PAYLOAD=$(cat <<EOF
{
    "name": "$APP_NAME",
    "project_uuid": "$PROJECT_UUID",
    "server_uuid": "$SERVER_UUID",
    "environment_name": "$ENVIRONMENT_NAME",
    "build_pack": "static",
    "static_image": "metabase/metabase:latest",
    "ports_exposes": "3000",
    "ports_mappings": "5700:3000"
}
EOF
)

APP_RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -X POST \
    "$COOLIFY_BASE_URL/api/v1/applications" \
    -d "$APP_PAYLOAD")

# Check for errors
if echo "$APP_RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
    echo "❌ Error creating application:"
    echo "$APP_RESPONSE" | jq '.errors'
    exit 1
fi

APP_UUID=$(echo "$APP_RESPONSE" | jq -r '.uuid' 2>/dev/null || echo "")
if [ -z "$APP_UUID" ]; then
    echo "❌ Failed to extract application UUID from response:"
    echo "$APP_RESPONSE"
    exit 1
fi

echo "✅ Metabase application created successfully!"
echo "   Application UUID: $APP_UUID"
echo "   Application Name: $APP_NAME"

# Step 3: Configure Metabase Environment Variables
echo ""
echo "🔑 Step 3: Setting up Metabase environment variables..."

# Set Metabase environment variables to connect to PostgreSQL
MB_ENV_VARS='[
    {"key": "MB_DB_TYPE", "value": "postgres"},
    {"key": "MB_DB_DBNAME", "value": "metabase"},
    {"key": "MB_DB_USER", "value": "metabase"},
    {"key": "MB_DB_PASS", "value": "CHANGEME_STRONG_PASSWORD_HERE"},
    {"key": "MB_DB_HOST", "value": "95.217.1.194"},
    {"key": "MB_DB_PORT", "value": "5710"}
]'

for env_var in $(echo "$MB_ENV_VARS" | jq -r '.[] | @base64'); do
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
        "$COOLIFY_BASE_URL/api/v1/applications/$APP_UUID/environment-variables" \
        -d "{\"key\": \"$KEY\", \"value\": \"$VALUE\"}" >/dev/null
done

echo ""
echo "🎉 Metabase Application deployment completed!"
echo ""
echo "📋 Created Resources:"
echo "   ✅ PostgreSQL Service UUID: $DB_SERVICE_UUID"
echo "   ✅ Metabase Application UUID: $APP_UUID"
echo "   ✅ Port Mapping: 5700:3000 (Metabase)"
echo "   ✅ Database Port: 5710:5432 (PostgreSQL)"
echo ""
echo "📋 Next Steps:"
echo "   1. Go to Coolify dashboard: $COOLIFY_BASE_URL"
echo "   2. Update POSTGRES_PASSWORD in both PostgreSQL service and Metabase app"
echo "   3. Deploy PostgreSQL service first:"
echo "      - Navigate to Services > $DB_SERVICE_NAME > Deploy"
echo "   4. Deploy Metabase application:"
echo "      - Navigate to Applications > $APP_NAME > Deploy"
echo "   5. Access Metabase at generated domain (will be available after deployment)"
echo ""
echo "⚠️  IMPORTANT: Change the default passwords before deployment!"
echo "   PostgreSQL Password: CHANGEME_STRONG_PASSWORD_HERE"
echo "   Update in BOTH PostgreSQL service AND Metabase application environment variables"
echo ""
echo "🌟 Application Features:"
echo "   ✅ Proper domain management through Coolify"
echo "   ✅ Automatic SSL certificates"
echo "   ✅ Integrated with Coolify proxy"
echo "   ✅ External PostgreSQL database"
echo "   ✅ Health checks enabled"
echo ""
echo "PostgreSQL Service UUID: $DB_SERVICE_UUID"
echo "Metabase Application UUID: $APP_UUID"