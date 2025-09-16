#!/bin/bash

# Metabase Deployment Monitoring Script
# This script helps monitor the deployment progress

COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
POSTGRES_UUID="v40ww8ksosc844c844s84wc8"

echo "🔍 Metabase Deployment Monitor"
echo "============================="

# Check PostgreSQL Service Status
echo ""
echo "🐘 PostgreSQL Service Status:"
echo "   UUID: $POSTGRES_UUID"
echo "   Name: metabase-postgresql"

POSTGRES_STATUS=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_UUID" | jq -r '.status // "unknown"')

echo "   Status: $POSTGRES_STATUS"

# Check port 5710
echo ""
echo "🔌 Port Status:"
if netstat -ln | grep -q ":5710"; then
  echo "   ✅ PostgreSQL (5710): Active"
else
  echo "   ⏳ PostgreSQL (5710): Not yet active"
fi

if netstat -ln | grep -q ":5700"; then
  echo "   ✅ Metabase (5700): Active"
else
  echo "   ⏳ Metabase (5700): Waiting for manual application setup"
fi

# Check Applications
echo ""
echo "📱 Applications Status:"
APPLICATIONS=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  "$COOLIFY_BASE_URL/api/v1/applications" | jq '.[] | select(.name | contains("metabase"))')

if [ -n "$APPLICATIONS" ]; then
  echo "   ✅ Metabase Application found:"
  echo "$APPLICATIONS" | jq -r '"   Name: " + .name + ", Status: " + (.status // "unknown")'
else
  echo "   ⏳ Metabase Application: Not created yet"
  echo "      Follow manual setup instructions in DEPLOYMENT_STATUS.md"
fi

echo ""
echo "🌐 Dashboard Access:"
echo "   Coolify: $COOLIFY_BASE_URL"
echo ""
echo "📖 Quick Setup Reminder:"
echo "   1. Go to Applications > + New"
echo "   2. Docker Image: metabase/metabase:latest"
echo "   3. Port: 3000 → 5700:3000"
echo "   4. Environment variables from DEPLOYMENT_STATUS.md"
echo "   5. Deploy!"
echo ""
echo "🔄 Run this script again to check progress: ./MONITOR_DEPLOYMENT.sh"