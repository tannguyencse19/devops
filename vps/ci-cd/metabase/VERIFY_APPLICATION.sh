#!/bin/bash

# Verification script for Metabase Application deployment

COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"

echo "🔍 Verifying Metabase Application Deployment"
echo "==========================================="

# Check Applications
echo ""
echo "📱 Applications:"
APPLICATIONS=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  "$COOLIFY_BASE_URL/api/v1/applications")

if echo "$APPLICATIONS" | jq -e '.[] | select(.name | contains("metabase"))' > /dev/null 2>&1; then
  echo "$APPLICATIONS" | jq -r '.[] | select(.name | contains("metabase")) | "   ✅ " + .name + " (UUID: " + .uuid + ", Status: " + (.status // "unknown") + ")"'
else
  echo "   ❌ No Metabase application found"
  echo "      Please create the application manually in the dashboard"
fi

# Check Services
echo ""
echo "🐘 Services:"
SERVICES=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
  "$COOLIFY_BASE_URL/api/v1/services")

echo "$SERVICES" | jq -r '.[] | select(.name | contains("metabase")) | "   📊 " + .name + " (UUID: " + .uuid + ", Status: " + .status + ")"'

# Check Ports
echo ""
echo "🔌 Port Status:"
if netstat -ln | grep -q ":5700"; then
  echo "   ✅ Port 5700 (Metabase): Active"
else
  echo "   ⏳ Port 5700 (Metabase): Not active yet"
fi

if netstat -ln | grep -q ":5710"; then
  echo "   ✅ Port 5710 (PostgreSQL): Active"
else
  echo "   ⏳ Port 5710 (PostgreSQL): Not active yet"
fi

# Test connections
echo ""
echo "🌐 Connection Tests:"
if curl -s --connect-timeout 5 http://localhost:5700 > /dev/null 2>&1; then
  echo "   ✅ Metabase (localhost:5700): Responding"
else
  echo "   ⏳ Metabase (localhost:5700): Not responding yet"
fi

if nc -z localhost 5710 2>/dev/null; then
  echo "   ✅ PostgreSQL (localhost:5710): Port open"
else
  echo "   ⏳ PostgreSQL (localhost:5710): Port not open yet"
fi

echo ""
echo "📋 Summary:"
echo "   Dashboard: $COOLIFY_BASE_URL"
echo "   Expected Application: metabase-app (port 5700)"
echo "   Expected Service: metabase-postgresql (port 5710)"
echo ""
echo "🔄 Run this script again to check progress: ./VERIFY_APPLICATION.sh"