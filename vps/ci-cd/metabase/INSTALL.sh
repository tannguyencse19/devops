#!/bin/bash

# INSTALL.sh - Deploy Metabase to Coolify APPLICATION
# This script provides instructions and API verification for Coolify deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COOLIFY_ENV_FILE="/root/CODE/TIMOTHY/devops/vps/ci-cd/coolify/.env"

echo "=============================================="
echo "Metabase Coolify Application Deployment"
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
echo "Step 1: Checking Coolify API connection..."
echo "----------------------------------------"

# Test API connection
response=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_URL/api/v1/applications" || echo "FAILED")

if [[ "$response" == "FAILED" ]]; then
    echo "ERROR: Failed to connect to Coolify API"
    echo "Please check your network connection and API token"
    exit 1
else
    echo "SUCCESS: Connected to Coolify API"
fi

echo ""
echo "Step 2: Checking current applications..."
echo "---------------------------------------"

# List current applications to see if metabase already exists
echo "Current applications in Coolify:"
echo "$response" | jq -r '.data[]? | "- \(.name) (ID: \(.id))"' 2>/dev/null || echo "No applications found or jq not available"

echo ""
echo "Step 3: Manual APPLICATION Creation Required"
echo "===========================================" 
echo ""
echo "Due to Coolify's architecture, you need to create the APPLICATION manually in the Coolify UI."
echo "Please follow these steps:"
echo ""
echo "1. Open Coolify Dashboard: $COOLIFY_URL"
echo "   - Username: $ROOT_USERNAME"
echo "   - Password: <check $COOLIFY_ENV_FILE for ROOT_USER_PASSWORD>"
echo ""
echo "2. Navigate to your Project and click 'Create New Resource'"
echo ""
echo "3. Select 'Applications' -> 'Docker Compose Empty'"
echo ""
echo "4. Configure the application:"
echo "   - Name: metabase"
echo "   - Description: Metabase Analytics Platform"
echo ""
echo "5. Copy the docker-compose.yml content:"
echo "   - Source file: $SCRIPT_DIR/docker-compose.yml"
echo "   - Paste the content into Coolify's Docker Compose editor"
echo ""
echo "6. Set Environment Variables (if needed):"
echo "   - POSTGRES_DATABASE=metabase"
echo "   - POSTGRES_USER=metabase"
echo "   - Note: SERVICE_PASSWORD_POSTGRES will be auto-generated"
echo ""
echo "7. Deploy the application by clicking 'Deploy'"
echo ""
echo "8. Monitor deployment progress in Coolify dashboard"
echo ""
echo "After manual setup, run VERIFY.sh to check deployment status."
echo ""
echo "=============================================="
echo "Installation guide completed"
echo "=============================================="