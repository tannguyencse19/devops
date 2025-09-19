#!/bin/bash

echo "🎯 Creating Metabase Application - Manual Guide"
echo "=============================================="

# Check if PostgreSQL service is running
echo "1. Checking PostgreSQL service status..."
PG_STATUS=$(curl -s -H "Authorization: Bearer 5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59" \
    "https://coolify.timothynguyen.work/api/v1/servers/as4kgsw0gocg8ogk0880wcc0/resources" | \
    jq -r '.[] | select(.name == "metabase-db") | .status')

if [ "$PG_STATUS" = "running:healthy" ]; then
    echo "   ✅ PostgreSQL service is running and healthy"
else
    echo "   ⚠️  PostgreSQL status: $PG_STATUS"
    echo "   📝 Note: You may need to start it manually in Coolify dashboard"
fi

echo ""
echo "2. Current applications in Coolify:"
curl -s -H "Authorization: Bearer 5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59" \
    "https://coolify.timothynguyen.work/api/v1/servers/as4kgsw0gocg8ogk0880wcc0/resources" | \
    jq -r '.[] | select(.type == "application") | "   - " + .name + " (Status: " + .status + ")"'

echo ""
echo "🚀 MANUAL STEPS TO CREATE METABASE APPLICATION:"
echo "================================================"
echo ""
echo "Step 1: Go to Coolify Dashboard"
echo "   🌐 URL: https://coolify.timothynguyen.work"
echo "   🔑 Login with your credentials"
echo ""
echo "Step 2: Create New Application"
echo "   1. Click the [+ New] button (top right)"
echo "   2. Select [Application]"
echo "   3. Choose [Docker Image] as source"
echo ""
echo "Step 3: Application Configuration"
echo "   📝 Fill in EXACTLY these values:"
echo "   ┌─────────────────────────────────────────┐"
echo "   │ Name: metabase-app                      │"
echo "   │ Docker Image: metabase/metabase:latest  │"
echo "   │ Port Exposes: 3000                      │"
echo "   │ Port Mappings: 5700:3000               │"
echo "   └─────────────────────────────────────────┘"
echo ""
echo "Step 4: Environment Variables"
echo "   📋 Add these 6 environment variables:"
echo "   ┌─────────────────────────────────────────┐"
echo "   │ MB_DB_TYPE=postgres                     │"
echo "   │ MB_DB_HOST=postgres-tkc0s408ws00ckc4o88swc0s │"
echo "   │ MB_DB_PORT=5432                         │"
echo "   │ MB_DB_DBNAME=metabase                   │"
echo "   │ MB_DB_USER=metabase                     │"
echo "   │ MB_DB_PASS=metabase123                  │"
echo "   └─────────────────────────────────────────┘"
echo ""
echo "Step 5: Deploy"
echo "   1. Click [Save] to create the application"
echo "   2. Click [Deploy] to start deployment"
echo "   3. Wait 2-3 minutes for completion"
echo ""
echo "🔍 Verification:"
echo "After deployment, run this to verify:"
echo "   ./VERIFY_APPLICATION.sh"
echo ""
echo "📱 Access Metabase:"
echo "   Once running: http://YOUR_SERVER_IP:5700"
echo "   Or set up domain in Coolify for SSL access"
echo ""
echo "❓ Need Help?"
echo "   - Check deployment logs in Coolify if issues occur"
echo "   - Ensure all environment variables are exactly as shown"
echo "   - PostgreSQL service must be running before Metabase starts"
echo ""
echo "🚨 IMPORTANT: The Metabase application MUST be created manually"
echo "              in the Coolify dashboard. API creation has limitations."
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🎯 Next: Go to https://coolify.timothynguyen.work and follow the steps above!"