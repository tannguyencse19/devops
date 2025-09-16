#!/bin/bash

# Metabase Application Creation Script for Coolify
# This script creates Metabase as a proper Coolify Application

set -e

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"  # production project
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"   # timothy-3 Hetzner Server

echo "🚀 Creating Metabase Application in Coolify..."

# Create Application JSON payload
APPLICATION_PAYLOAD=$(cat <<EOF
{
  "name": "metabase-app",
  "project_uuid": "$PROJECT_UUID",
  "server_uuid": "$SERVER_UUID",
  "environment_name": "production",
  "build_pack": "dockerfile",
  "dockerfile": "FROM metabase/metabase:latest\n\n# Install curl for health checks\nUSER root\nRUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*\nUSER metabase\n\n# Expose port 3000\nEXPOSE 3000\n\n# Health check\nHEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=5 \\\\\n    CMD curl -f http://localhost:3000/api/health || exit 1\n\n# Start Metabase\nCMD [\"java\", \"-jar\", \"/app/metabase.jar\"]",
  "ports_exposes": "3000",
  "ports_mappings": "5700:3000",
  "dockerfile_location": "/",
  "base_directory": "/",
  "publish_directory": "",
  "health_check_enabled": true,
  "health_check_path": "/api/health",
  "health_check_port": "3000",
  "health_check_interval": 30,
  "health_check_timeout": 10,
  "health_check_retries": 5,
  "health_check_return_code": 200,
  "restart_policy": "unless-stopped",
  "redirect": "/"
}
EOF
)

echo "📝 Application payload prepared"

# Create the application
echo "🔗 Creating application via API..."
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$APPLICATION_PAYLOAD" \
  "$COOLIFY_BASE_URL/api/v1/applications")

echo "📋 API Response:"
echo "$RESPONSE" | jq .

# Extract application UUID
APP_UUID=$(echo "$RESPONSE" | jq -r '.uuid // empty')

if [ -n "$APP_UUID" ] && [ "$APP_UUID" != "null" ] && [ "$APP_UUID" != "" ]; then
  echo "✅ Application created successfully!"
  echo "🆔 Application UUID: $APP_UUID"
  echo "📱 Application Name: metabase-app"
  
  # Set environment variables for the application
  echo ""
  echo "🔧 Setting environment variables..."
  
  ENV_VARS=(
    "MB_DB_TYPE=postgres"
    "MB_DB_HOST=postgres-j88g84ssgw8g4ock8g4g0s4o"
    "MB_DB_PORT=5432"
    "MB_DB_DBNAME=metabase"
    "MB_DB_USER=metabase"
    "MB_DB_PASS=secure_password_2024"
  )
  
  for env_var in "${ENV_VARS[@]}"; do
    KEY=$(echo "$env_var" | cut -d'=' -f1)
    VALUE=$(echo "$env_var" | cut -d'=' -f2-)
    
    ENV_PAYLOAD=$(cat <<EOF
{
  "key": "$KEY",
  "value": "$VALUE",
  "is_preview": false,
  "is_build_time": false,
  "is_literal": false
}
EOF
)
    
    echo "   Setting $KEY..."
    curl -s -X POST \
      -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$ENV_PAYLOAD" \
      "$COOLIFY_BASE_URL/api/v1/applications/$APP_UUID/envs" > /dev/null
  done
  
  echo "✅ Environment variables configured"
  echo ""
  echo "🎯 Next steps:"
  echo "   1. Go to Coolify dashboard: $COOLIFY_BASE_URL"
  echo "   2. Navigate to Applications > metabase-app"
  echo "   3. Click 'Deploy' to start the application"
  echo "   4. Configure domain settings if needed"
  echo ""
  echo "📊 Application will be accessible on port 5700"
  echo "🔗 PostgreSQL connection: postgres-j88g84ssgw8g4ock8g4g0s4o:5432"
  
else
  echo "❌ Failed to create application"
  echo "📋 Full response:"
  echo "$RESPONSE"
  
  echo ""
  echo "🔍 Trying alternative approach - Docker Image application..."
  
  # Try with docker image approach
  ALT_PAYLOAD=$(cat <<EOF
{
  "name": "metabase-app",
  "project_uuid": "$PROJECT_UUID",
  "server_uuid": "$SERVER_UUID",
  "environment_name": "production",
  "build_pack": "static",
  "static_image": "metabase/metabase:latest",
  "ports_exposes": "3000",
  "ports_mappings": "5700:3000"
}
EOF
)

  ALT_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$ALT_PAYLOAD" \
    "$COOLIFY_BASE_URL/api/v1/applications")

  echo "📋 Alternative API Response:"
  echo "$ALT_RESPONSE" | jq .
  
  ALT_UUID=$(echo "$ALT_RESPONSE" | jq -r '.uuid // empty')
  
  if [ -n "$ALT_UUID" ] && [ "$ALT_UUID" != "null" ] && [ "$ALT_UUID" != "" ]; then
    echo "✅ Application created with Docker image approach!"
    echo "🆔 Application UUID: $ALT_UUID"
  else
    echo "❌ Both approaches failed. Manual setup required."
    echo ""
    echo "📖 Please follow manual setup instructions:"
    echo "   ./MANAGE_METABASE_COOLIFY.sh setup-manual"
  fi
fi

echo ""
echo "🚀 Script completed!"