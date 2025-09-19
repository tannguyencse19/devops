#!/bin/bash

# UNINSTALL.sh - Remove Metabase from Coolify APPLICATION
# This script provides instructions for removing the Metabase application from Coolify

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COOLIFY_ENV_FILE="/root/CODE/TIMOTHY/devops/vps/ci-cd/coolify/.env"

echo "=============================================="
echo "Metabase Coolify Application Removal"
echo "=============================================="

# Source Coolify environment variables
if [[ -f "$COOLIFY_ENV_FILE" ]]; then
    echo "Loading Coolify environment variables..."
    source "$COOLIFY_ENV_FILE"
else
    echo "ERROR: Coolify environment file not found at $COOLIFY_ENV_FILE"
    echo "Please ensure Coolify is installed and configured."
    exit 1
fi

# Check if required variables are set
if [[ -z "$GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN" ]]; then
    echo "ERROR: GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN not found in environment"
    exit 1
fi

COOLIFY_URL="https://coolify.timothynguyen.work"
API_TOKEN="$GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN"

echo ""
echo "Step 1: Checking for Metabase application..."
echo "-------------------------------------------"

# Check if metabase application exists
response=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_URL/api/v1/applications" || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    echo "ERROR: Failed to connect to Coolify API"
    echo "Please check your network connection and API token"
    exit 1
fi

# Look for metabase application
metabase_apps=$(echo "$response" | jq -r '.data[]? | select(.name | test("metabase"; "i")) | "\(.name) (ID: \(.id))"' 2>/dev/null || echo "")

if [[ -n "$metabase_apps" ]]; then
    echo "Found potential Metabase applications:"
    echo "$metabase_apps"
else
    echo "No Metabase applications found in Coolify"
fi

echo ""
echo "⚠️  IMPORTANT DATA WARNING ⚠️"
echo "=============================="
echo ""
echo "Removing the Metabase application will:"
echo "- Stop all Metabase containers"
echo "- Remove the application from Coolify"
echo "- PERMANENTLY DELETE all Metabase data including:"
echo "  * All dashboards and questions"
echo "  * User accounts and settings"
echo "  * Database connections and metadata"
echo "  * PostgreSQL database data"
echo ""
echo "This action CANNOT be undone!"
echo ""

# Confirmation prompt
read -p "Are you sure you want to proceed? Type 'DELETE' to confirm: " confirmation

if [[ "$confirmation" != "DELETE" ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo "Step 2: Manual APPLICATION Removal Required"
echo "=========================================="
echo ""
echo "Due to Coolify's architecture, you need to remove the APPLICATION manually in the Coolify UI."
echo "Please follow these steps:"
echo ""
echo "1. Open Coolify Dashboard: $COOLIFY_URL"
echo "   - Username: $ROOT_USERNAME"
echo "   - Password: <check $COOLIFY_ENV_FILE for ROOT_USER_PASSWORD>"
echo ""
echo "2. Navigate to your Project"
echo ""
echo "3. Find the Metabase application in your applications list"
echo ""
echo "4. Click on the Metabase application"
echo ""
echo "5. Go to 'Settings' or 'Danger Zone'"
echo ""
echo "6. Click 'Delete Application'"
echo ""
echo "7. Confirm the deletion when prompted"
echo ""
echo "8. Wait for Coolify to:"
echo "   - Stop all containers"
echo "   - Remove application configuration"
echo "   - Clean up resources"
echo ""
echo "Alternative: If you want to keep data for backup:"
echo "1. Stop the application instead of deleting it"
echo "2. Export any important dashboards manually first"
echo "3. Then proceed with deletion if desired"
echo ""
echo "=============================================="
echo "Uninstallation guide completed"
echo "=============================================="