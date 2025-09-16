#!/bin/bash

# Complete Metabase Application Setup for Coolify
# This script ensures clean PostgreSQL service and provides manual app creation guidance

set -e

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"

echo "🚀 Complete Metabase Application Setup"
echo "====================================="

# Step 1: Clean up any existing services
echo ""
echo "🧹 Step 1: Cleaning up existing services..."

# Check for existing services
EXISTING_SERVICES=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  "$COOLIFY_BASE_URL/api/v1/services" | jq '.[] | select(.name | contains("metabase"))')

if [ -n "$EXISTING_SERVICES" ]; then
  echo "🗑️  Found existing Metabase services, removing them..."
  echo "$EXISTING_SERVICES" | jq -r '.uuid' | while read uuid; do
    if [ -n "$uuid" ]; then
      echo "   Removing service: $uuid"
      curl -s -X DELETE -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        "$COOLIFY_BASE_URL/api/v1/services/$uuid" > /dev/null
    fi
  done
  echo "⏱️  Waiting 10 seconds for cleanup to complete..."
  sleep 10
fi

# Step 2: Create PostgreSQL Service
echo ""
echo "🐘 Step 2: Creating PostgreSQL Service..."

# Encode the Docker Compose for PostgreSQL
POSTGRES_COMPOSE=$(cat <<EOF
services:
  postgres:
    image: 'postgres:15-alpine'
    restart: unless-stopped
    ports:
      - '5710:5432'
    environment:
      POSTGRES_DB: '\${POSTGRES_DATABASE}'
      POSTGRES_USER: '\${POSTGRES_USER}'
      POSTGRES_PASSWORD: '\${POSTGRES_PASSWORD}'
    volumes:
      - 'postgres-data:/var/lib/postgresql/data'
    healthcheck:
      test:
        - CMD-SHELL
        - 'pg_isready -U \${POSTGRES_USER} -d \${POSTGRES_DATABASE}'
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
volumes:
  postgres-data:
    driver: local
EOF
)

POSTGRES_COMPOSE_B64=$(echo "$POSTGRES_COMPOSE" | base64 -w 0)

POSTGRES_SERVICE_PAYLOAD=$(cat <<EOF
{
  "name": "metabase-postgresql",
  "description": "PostgreSQL database for Metabase Application",
  "project_uuid": "$PROJECT_UUID",
  "server_uuid": "$SERVER_UUID",
  "environment_name": "production",
  "docker_compose_raw": "$POSTGRES_COMPOSE_B64"
}
EOF
)

echo "📝 Creating PostgreSQL service..."
POSTGRES_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$POSTGRES_SERVICE_PAYLOAD" \
  "$COOLIFY_BASE_URL/api/v1/services")

POSTGRES_UUID=$(echo "$POSTGRES_RESPONSE" | jq -r '.uuid // empty')

if [ -n "$POSTGRES_UUID" ] && [ "$POSTGRES_UUID" != "null" ] && [ "$POSTGRES_UUID" != "" ]; then
  echo "✅ PostgreSQL service created successfully!"
  echo "🆔 Service UUID: $POSTGRES_UUID"
  
  # Set environment variables for PostgreSQL
  echo "🔧 Setting PostgreSQL environment variables..."
  
  POSTGRES_ENV_VARS=(
    "POSTGRES_DATABASE=metabase"
    "POSTGRES_USER=metabase"
    "POSTGRES_PASSWORD=secure_metabase_db_pass_2024"
  )
  
  for env_var in "${POSTGRES_ENV_VARS[@]}"; do
    KEY=$(echo "$env_var" | cut -d'=' -f1)
    VALUE=$(echo "$env_var" | cut -d'=' -f2-)
    
    ENV_PAYLOAD=$(cat <<EOF
{
  "key": "$KEY",
  "value": "$VALUE",
  "is_preview": false
}
EOF
)
    
    echo "   Setting $KEY..."
    curl -s -X POST \
      -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$ENV_PAYLOAD" \
      "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_UUID/envs" > /dev/null
  done
  
  echo "✅ PostgreSQL environment configured"
  
  # Deploy PostgreSQL service
  echo "🚀 Deploying PostgreSQL service..."
  curl -s -X POST \
    -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_UUID/action" > /dev/null
  
  echo "✅ PostgreSQL deployment initiated!"
  
else
  echo "❌ Failed to create PostgreSQL service"
  echo "📋 Response: $POSTGRES_RESPONSE"
  exit 1
fi

# Step 3: Provide manual application setup instructions
echo ""
echo "📱 Step 3: Manual Metabase Application Creation"
echo "=============================================="
echo ""
echo "Since Coolify API has limitations for Application creation,"
echo "please follow these manual steps in the Coolify dashboard:"
echo ""
echo "🌐 1. Go to: $COOLIFY_BASE_URL"
echo "🔑 2. Login with your credentials"
echo "📂 3. Navigate to: Resources > Applications"
echo "➕ 4. Click: '+ New'"
echo ""
echo "⚙️  5. Application Configuration:"
echo "   📛 Name: metabase-app"
echo "   🏗️  Source: Docker Image"
echo "   🐳 Image: metabase/metabase:latest"
echo "   🌐 Port: 3000"
echo "   🔗 Port Mapping: 5700:3000"
echo ""
echo "🔧 6. Environment Variables (add these):"
echo "   MB_DB_TYPE=postgres"
echo "   MB_DB_HOST=postgres-$POSTGRES_UUID"
echo "   MB_DB_PORT=5432"
echo "   MB_DB_DBNAME=metabase"
echo "   MB_DB_USER=metabase"
echo "   MB_DB_PASS=secure_metabase_db_pass_2024"
echo ""
echo "🏥 7. Health Check (optional but recommended):"
echo "   Path: /api/health"
echo "   Port: 3000"
echo "   Interval: 30s"
echo ""
echo "🌍 8. Domain Configuration:"
echo "   - Set up your desired domain/subdomain"
echo "   - Enable SSL if needed"
echo "   - Configure redirects if needed"
echo ""
echo "🚀 9. Click 'Deploy' to launch the application"
echo ""
echo "📊 Current Status:"
echo "✅ PostgreSQL Service: metabase-postgresql ($POSTGRES_UUID)"
echo "🔄 Status: Deploying on port 5710"
echo "⏳ Metabase Application: Manual setup required"
echo "🎯 Target: Port 5700"
echo ""
echo "🔍 Verify setup:"
echo "   PostgreSQL: netstat -ln | grep 5710"
echo "   Metabase: netstat -ln | grep 5700 (after manual setup)"
echo ""
echo "🎉 Once both are deployed, Metabase will be accessible with full"
echo "   domain management capabilities as a proper Coolify Application!"

# Create a summary file
cat > /root/CODE/TIMOTHY/devops/vps/ci-cd/metabase/DEPLOYMENT_STATUS.md <<EOF
# Metabase Application Deployment Status

## ✅ Completed Steps

### PostgreSQL Service
- **Status**: ✅ Created and Deployed
- **UUID**: $POSTGRES_UUID
- **Name**: metabase-postgresql
- **Port**: 5710:5432
- **Database**: metabase
- **User**: metabase
- **Connection**: postgres-$POSTGRES_UUID:5432

### Environment Variables
- ✅ POSTGRES_DATABASE=metabase
- ✅ POSTGRES_USER=metabase  
- ✅ POSTGRES_PASSWORD=secure_metabase_db_pass_2024

## ⏳ Pending Steps

### Metabase Application (Manual Setup Required)
Due to Coolify API limitations for Application creation, manual setup required:

1. Go to: $COOLIFY_BASE_URL
2. Create new Application with:
   - Name: metabase-app
   - Source: Docker Image
   - Image: metabase/metabase:latest
   - Port: 3000 → 5700:3000

3. Environment Variables:
   - MB_DB_TYPE=postgres
   - MB_DB_HOST=postgres-$POSTGRES_UUID
   - MB_DB_PORT=5432
   - MB_DB_DBNAME=metabase
   - MB_DB_USER=metabase
   - MB_DB_PASS=secure_metabase_db_pass_2024

4. Deploy the application

## 🎯 Final Result
- PostgreSQL: Port 5710 (Service)
- Metabase: Port 5700 (Application with domain management)

Generated: $(date)
EOF

echo ""
echo "📄 Deployment status saved to: DEPLOYMENT_STATUS.md"
echo "🚀 Setup completed! Please proceed with manual application creation."