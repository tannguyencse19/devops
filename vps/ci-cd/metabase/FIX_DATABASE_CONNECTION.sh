#!/bin/bash

echo "🔧 Fixing Metabase Database Connection"
echo "====================================="

API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_URL="https://coolify.timothynguyen.work"

METABASE_UUID="t0ks8gkc0s804o8w0o0o8w48"
POSTGRES_UUID="tkc0s408ws00ckc4o88swc0s"

echo "1. Current issue: Metabase can't connect to PostgreSQL"
echo "   Error: UnknownHostException: postgres-tkc0s408ws00ckc4o88swc0s"
echo ""

echo "2. The correct database connection method in Coolify:"
echo "   - For service-to-application connections, use the service container name"
echo "   - PostgreSQL service container name should be: metabase-db-${POSTGRES_UUID}"
echo ""

echo "3. Checking current Metabase environment variables..."
curl -s -H "Authorization: Bearer $API_TOKEN" \
    "$COOLIFY_URL/api/v1/applications/$METABASE_UUID/envs" | jq '.'

echo ""
echo "4. The correct environment variables should be:"
echo "   MB_DB_HOST=metabase-db-${POSTGRES_UUID}"
echo "   Or alternatively: MB_DB_HOST=localhost (if using host networking)"
echo ""

echo "🚨 MANUAL FIX REQUIRED:"
echo "========================================"
echo ""
echo "Go to: https://coolify.timothynguyen.work"
echo "Navigate to: Applications → metabase-app → Configuration → Environment Variables"
echo ""
echo "Change MB_DB_HOST from:"
echo "   OLD: postgres-tkc0s408ws00ckc4o88swc0s"
echo "   NEW: metabase-db-${POSTGRES_UUID}"
echo ""
echo "Or try these alternative values:"
echo "   Option 1: localhost"
echo "   Option 2: 127.0.0.1"
echo "   Option 3: metabase-db"
echo ""
echo "After changing, click 'Save' and 'Deploy' to restart the application."
echo ""
echo "🔍 Test connectivity afterward:"
echo "   ./VERIFY_APPLICATION.sh"
echo ""
echo "💡 If still having issues, we may need to:"
echo "   - Check Docker network configuration"
echo "   - Use PostgreSQL service's external port (5710)"
echo "   - Configure MB_DB_HOST=<server-ip> and MB_DB_PORT=5710"