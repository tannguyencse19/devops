#!/bin/bash

echo "🔄 Switching Metabase to Internal Docker Networking"
echo "=================================================="

API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_URL="https://coolify.timothynguyen.work"
METABASE_UUID="t0ks8gkc0s804o8w0o0o8w48"

DB_HOST_ENV_UUID="qscco88wcs84og8sck8o4ggs"
DB_PORT_ENV_UUID="xk0480gs40804oo04cwcwg08"

echo "🔍 Current Issue: Port mapping not working despite correct configuration"
echo "✅ Solution: Use Docker internal networking instead"
echo ""

echo "1. Updating MB_DB_HOST environment variable..."
curl -X PUT \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "MB_DB_HOST",
    "value": "postgres-tkc0s408ws00ckc4o88swc0s"
  }' \
  "$COOLIFY_URL/api/v1/applications/$METABASE_UUID/envs/$DB_HOST_ENV_UUID"

echo ""
echo "2. Updating MB_DB_PORT environment variable..."
curl -X PUT \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "MB_DB_PORT", 
    "value": "5432"
  }' \
  "$COOLIFY_URL/api/v1/applications/$METABASE_UUID/envs/$DB_PORT_ENV_UUID"

echo ""
echo "3. Deploying Metabase application with new settings..."
curl -X POST \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  "$COOLIFY_URL/api/v1/applications/$METABASE_UUID/deploy"

echo ""
echo "✅ Internal networking configuration applied!"
echo ""
echo "📋 New Configuration:"
echo "   MB_DB_HOST = postgres-tkc0s408ws00ckc4o88swc0s"
echo "   MB_DB_PORT = 5432"
echo ""
echo "💡 How this works:"
echo "   - Uses Docker's internal container networking"
echo "   - Metabase connects directly to PostgreSQL container"
echo "   - No dependency on host port mapping"
echo "   - Container name: postgres-tkc0s408ws00ckc4o88swc0s"
echo ""
echo "🔄 Verification:"
echo "   Wait 2-3 minutes for deployment to complete, then run:"
echo "   ./VERIFY_APPLICATION.sh"
echo ""
echo "🎯 Expected Result:"
echo "   ✅ Metabase: Status changes to 'running:healthy'"
echo "   ✅ Port 5700: Becomes active for web access"
echo "   🌐 Access: http://91.99.53.200:5700"