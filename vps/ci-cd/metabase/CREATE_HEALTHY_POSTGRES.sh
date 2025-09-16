#!/bin/bash

# Create a healthy PostgreSQL service for Metabase

set -e

COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
PROJECT_UUID="s480okgoock0ok4oo4cwsskg"
SERVER_UUID="as4kgsw0gocg8ogk0880wcc0"

echo "🗑️ Step 1: Remove existing problematic PostgreSQL service..."

# Delete existing service
curl -s -X DELETE -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  "$COOLIFY_BASE_URL/api/v1/services/v40ww8ksosc844c844s84wc8"

echo "⏱️ Waiting 10 seconds for cleanup..."
sleep 10

echo "🐘 Step 2: Creating new healthy PostgreSQL service..."

# Create a simpler, more reliable PostgreSQL compose
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
      POSTGRES_PASSWORD: secure_postgres_2024
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256 --auth-local=scram-sha-256"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U metabase -d metabase"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
volumes:
  postgres_data:
    driver: local
EOF
)

POSTGRES_COMPOSE_B64=$(echo "$POSTGRES_COMPOSE" | base64 -w 0)

POSTGRES_SERVICE_PAYLOAD=$(cat <<EOF
{
  "name": "metabase-postgres-new",
  "description": "PostgreSQL database for Metabase Application",
  "project_uuid": "$PROJECT_UUID",
  "server_uuid": "$SERVER_UUID",
  "environment_name": "production",
  "docker_compose_raw": "$POSTGRES_COMPOSE_B64"
}
EOF
)

echo "📝 Creating new PostgreSQL service..."
POSTGRES_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$POSTGRES_SERVICE_PAYLOAD" \
  "$COOLIFY_BASE_URL/api/v1/services")

POSTGRES_UUID=$(echo "$POSTGRES_RESPONSE" | jq -r '.uuid // empty')

if [ -n "$POSTGRES_UUID" ] && [ "$POSTGRES_UUID" != "null" ] && [ "$POSTGRES_UUID" != "" ]; then
  echo "✅ PostgreSQL service created successfully!"
  echo "🆔 Service UUID: $POSTGRES_UUID"
  
  # Deploy PostgreSQL service
  echo "🚀 Deploying PostgreSQL service..."
  curl -s -X POST \
    -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_UUID/action" > /dev/null
  
  echo "✅ PostgreSQL deployment initiated!"
  echo ""
  echo "📊 New PostgreSQL Service Details:"
  echo "   Name: metabase-postgres-new"
  echo "   UUID: $POSTGRES_UUID"
  echo "   Port: 5710:5432"
  echo "   Database: metabase"
  echo "   User: metabase"
  echo "   Password: secure_postgres_2024"
  echo ""
  echo "🔧 Updated Environment Variables for Metabase Application:"
  echo "   MB_DB_TYPE=postgres"
  echo "   MB_DB_HOST=postgres-$POSTGRES_UUID"
  echo "   MB_DB_PORT=5432"
  echo "   MB_DB_DBNAME=metabase"
  echo "   MB_DB_USER=metabase"
  echo "   MB_DB_PASS=secure_postgres_2024"
  echo ""
  echo "⏱️ Waiting 30 seconds for PostgreSQL to start..."
  sleep 30
  
  # Test the service
  echo "🔍 Testing new PostgreSQL service..."
  ./VERIFY_APPLICATION.sh
  
else
  echo "❌ Failed to create PostgreSQL service"
  echo "📋 Response: $POSTGRES_RESPONSE"
  exit 1
fi