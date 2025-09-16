#!/bin/bash

# Update PostgreSQL Password for Metabase Service
# This script updates the POSTGRES_PASSWORD environment variable in Coolify

set -e

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
SERVICE_UUID="qwo48og08k80og40c8k8k8g4"

echo "🔑 Updating PostgreSQL password for Metabase service..."

# Prompt for new password
echo "Please enter a strong password for PostgreSQL:"
echo "⚠️  Password requirements:"
echo "   - At least 12 characters"
echo "   - Include uppercase, lowercase, numbers, and special characters"
echo ""
read -s -p "New PostgreSQL Password: " NEW_PASSWORD
echo ""
read -s -p "Confirm Password: " CONFIRM_PASSWORD
echo ""

# Verify passwords match
if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
    echo "❌ Passwords don't match!"
    exit 1
fi

# Basic password strength check
if [ ${#NEW_PASSWORD} -lt 12 ]; then
    echo "❌ Password must be at least 12 characters long!"
    exit 1
fi

# Get current environment variables
echo "🔍 Fetching current environment variables..."
ENV_VARS=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID/environment-variables")

# Extract environment variable ID for POSTGRES_PASSWORD
ENV_VAR_ID=$(echo "$ENV_VARS" | jq -r '.[] | select(.key=="POSTGRES_PASSWORD") | .id' 2>/dev/null || echo "")

if [ -z "$ENV_VAR_ID" ]; then
    echo "❌ POSTGRES_PASSWORD environment variable not found!"
    echo "   Available variables:"
    echo "$ENV_VARS" | jq -r '.[] | "   - " + .key'
    exit 1
fi

# Update the password
echo "🔄 Updating password..."
RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -X PATCH \
    "$COOLIFY_BASE_URL/api/v1/environment-variables/$ENV_VAR_ID" \
    -d "{\"value\": \"$NEW_PASSWORD\"}")

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
    echo "❌ Error updating password:"
    echo "$RESPONSE" | jq '.errors'
    exit 1
fi

echo "✅ Password updated successfully!"
echo ""
echo "📋 Next Steps:"
echo "   1. Go to Coolify dashboard: $COOLIFY_BASE_URL"
echo "   2. Navigate to PRODUCTION project > Services > metabase-service"
echo "   3. Deploy the service to apply the new password"
echo "   4. Monitor the deployment logs for any issues"
echo ""
echo "⚠️  Remember to store this password securely!"

# Clear password from memory
unset NEW_PASSWORD
unset CONFIRM_PASSWORD