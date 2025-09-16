#!/bin/bash

# Fix PostgreSQL service for Metabase - Create a working service

set -e

COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"

echo "🔧 Fixing PostgreSQL Service for Metabase"
echo "========================================="

# Step 1: Remove problematic service
echo ""
echo "🗑️ Step 1: Removing current unhealthy service..."
curl -s -X DELETE -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  "$COOLIFY_BASE_URL/api/v1/services/w0ok0cos8k0wg40o0wkosks8"

echo "⏱️ Waiting 15 seconds for complete cleanup..."
sleep 15

# Step 2: Create minimal, reliable PostgreSQL configuration
echo ""
echo "🐘 Step 2: Creating minimal PostgreSQL service..."

# Very simple PostgreSQL setup - minimal configuration
POSTGRES_COMPOSE=$(cat <<'EOF'
services:
  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    ports:
      - "5710:5432"
    environment:
      POSTGRES_DB: metabase
      POSTGRES_USER: metabase
      POSTGRES_PASSWORD: metabase123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  postgres_data:
    driver: local
EOF
)

POSTGRES_COMPOSE_B64=$(echo "$POSTGRES_COMPOSE" | base64 -w 0)

POSTGRES_SERVICE_PAYLOAD=$(cat <<EOF
{
  "name": "metabase-db",
  "description": "PostgreSQL for Metabase",
  "project_uuid": "$PROJECT_UUID",
  "server_uuid": "$SERVER_UUID",
  "environment_name": "production",
  "docker_compose_raw": "$POSTGRES_COMPOSE_B64"
}
EOF
)

echo "📝 Creating minimal PostgreSQL service..."
POSTGRES_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$POSTGRES_SERVICE_PAYLOAD" \
  "$COOLIFY_BASE_URL/api/v1/services")

POSTGRES_UUID=$(echo "$POSTGRES_RESPONSE" | jq -r '.uuid // empty')

if [ -n "$POSTGRES_UUID" ] && [ "$POSTGRES_UUID" != "null" ] && [ "$POSTGRES_UUID" != "" ]; then
  echo "✅ PostgreSQL service created!"
  echo "🆔 Service UUID: $POSTGRES_UUID"
  
  # Step 3: Deploy the service
  echo ""
  echo "🚀 Step 3: Deploying PostgreSQL service..."
  DEPLOY_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_UUID/action")
  
  echo "✅ Deploy command sent: $DEPLOY_RESPONSE"
  
  # Step 4: Wait and check status
  echo ""
  echo "⏱️ Step 4: Waiting 45 seconds for deployment..."
  sleep 45
  
  echo "🔍 Checking service status..."
  SERVICE_STATUS=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_UUID" | jq -r '.status // "unknown"')
  
  echo "📊 PostgreSQL Service Status: $SERVICE_STATUS"
  
  # Step 5: Check port connectivity
  echo ""
  echo "🔌 Step 5: Checking port connectivity..."
  if netstat -ln | grep -q ":5710"; then
    echo "✅ Port 5710 is active!"
  else
    echo "⏳ Port 5710 not yet active, checking in dashboard..."
  fi
  
  # Step 6: Provide application setup info
  echo ""
  echo "🎯 Step 6: Updated Metabase Application Environment Variables:"
  echo "=================================================="
  echo "MB_DB_TYPE=postgres"
  echo "MB_DB_HOST=postgres-$POSTGRES_UUID"
  echo "MB_DB_PORT=5432"
  echo "MB_DB_DBNAME=metabase"
  echo "MB_DB_USER=metabase"
  echo "MB_DB_PASS=metabase123"
  echo ""
  echo "📋 Service Details:"
  echo "   Name: metabase-db"
  echo "   UUID: $POSTGRES_UUID"
  echo "   Port: 5710:5432"
  echo "   Status: $SERVICE_STATUS"
  echo ""
  echo "🌐 Dashboard: $COOLIFY_BASE_URL"
  echo ""
  
  # Update the verification script with new UUID
  echo "🔧 Updating verification script with new UUID..."
  sed -i "s/w0ok0cos8k0wg40o0wkosks8/$POSTGRES_UUID/g" VERIFY_APPLICATION.sh
  
  echo "🧪 Running verification test..."
  ./VERIFY_APPLICATION.sh
  
else
  echo "❌ Failed to create PostgreSQL service"
  echo "📋 Response: $POSTGRES_RESPONSE"
  exit 1
fi

echo ""
echo "🎉 PostgreSQL service setup completed!"
echo "👉 Next: Create Metabase Application in dashboard with the environment variables above"