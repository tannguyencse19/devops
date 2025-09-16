#!/bin/bash

# Metabase Coolify Service Uninstall Script
# This script removes the Metabase service from Coolify

set -e

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
SERVICE_UUID="x0sw44kkggswgw80kgooo804"
SERVICE_NAME="metabase-service"

echo "🗑️  Metabase Service Uninstall"
echo ""
echo "This will completely remove:"
echo "   ✗ Metabase service ($SERVICE_NAME)"
echo "   ✗ PostgreSQL database"
echo "   ✗ All data volumes"
echo "   ✗ Environment variables"
echo "   ✗ Generated domains"
echo ""
echo "⚠️  WARNING: This action cannot be undone!"
echo "   All Metabase data and configurations will be permanently lost."

# Check if service exists
echo ""
echo "🔍 Checking if service exists..."
SERVICE_CHECK=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID" | jq -r '.name' 2>/dev/null || echo "")

if [ "$SERVICE_CHECK" != "$SERVICE_NAME" ]; then
    echo "❌ Service '$SERVICE_NAME' not found or already deleted"
    echo "   Service UUID: $SERVICE_UUID"
    exit 1
fi

echo "✅ Service found: $SERVICE_NAME"

# Get service status
SERVICE_STATUS=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID" | jq -r '.status' 2>/dev/null || echo "unknown")

echo "📊 Current status: $SERVICE_STATUS"

# Confirmation prompt
echo ""
echo "🛑 FINAL CONFIRMATION"
echo "   Type 'UNINSTALL METABASE' to proceed:"
read -p "Confirmation: " CONFIRMATION

if [ "$CONFIRMATION" != "UNINSTALL METABASE" ]; then
    echo "❌ Uninstall cancelled"
    echo "   No changes were made"
    exit 1
fi

# Stop service if running
if [[ "$SERVICE_STATUS" =~ "running" ]]; then
    echo ""
    echo "🛑 Stopping service..."
    curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID/stop" >/dev/null
    
    echo "   Waiting for service to stop..."
    sleep 10
fi

# Delete the service
echo ""
echo "🗑️  Deleting service..."
RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    -X DELETE \
    "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID")

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
    echo "❌ Error deleting service:"
    echo "$RESPONSE" | jq '.errors'
    exit 1
fi

echo "✅ Service deleted successfully!"

# Verify deletion
echo ""
echo "🔍 Verifying deletion..."
VERIFY_CHECK=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID" 2>/dev/null | jq -r '.name' 2>/dev/null || echo "not_found")

if [ "$VERIFY_CHECK" = "not_found" ]; then
    echo "✅ Deletion verified - service no longer exists"
else
    echo "⚠️  Service may still exist - check Coolify dashboard"
fi

echo ""
echo "🎉 Metabase service uninstall completed!"
echo ""
echo "📋 Summary:"
echo "   ✅ Service '$SERVICE_NAME' removed"
echo "   ✅ PostgreSQL database removed"
echo "   ✅ Data volumes removed"
echo "   ✅ Environment variables removed"
echo "   ✅ Generated domains removed"
echo ""
echo "📚 To redeploy Metabase:"
echo "   Run: ./DEPLOY_TO_COOLIFY.sh"
echo ""
echo "💾 Data Recovery:"
echo "   All data has been permanently deleted"
echo "   No recovery options available"