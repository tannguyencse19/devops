#!/bin/bash

# VERIFY.sh - Check Metabase Coolify APPLICATION deployment status
# This script verifies the Metabase application status via Coolify API

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COOLIFY_ENV_FILE="/root/CODE/TIMOTHY/devops/vps/ci-cd/coolify/.env"

echo "=============================================="
echo "Metabase Coolify Application Verification"
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
    echo "❌ ERROR: Failed to connect to Coolify API"
    echo "Please check your network connection and API token"
    exit 1
else
    echo "✅ SUCCESS: Connected to Coolify API"
fi

echo ""
echo "Step 2: Searching for Metabase applications..."
echo "---------------------------------------------"

# Look for metabase applications
metabase_found=false
metabase_details=""

if command -v jq >/dev/null 2>&1; then
    # Use jq if available for better parsing
    metabase_details=$(echo "$response" | jq -r '.data[]? | select(.name | test("metabase"; "i")) | "Name: \(.name)\nID: \(.id)\nStatus: \(.status // "unknown")\nURL: \(.fqdn // "not set")\n---"' 2>/dev/null || echo "")
    
    if [[ -n "$metabase_details" ]]; then
        metabase_found=true
        echo "✅ Found Metabase application(s):"
        echo "$metabase_details"
    else
        echo "❌ No Metabase applications found"
    fi
else
    # Fallback without jq
    echo "⚠️  jq not available - checking for metabase in application names..."
    if echo "$response" | grep -i metabase >/dev/null 2>&1; then
        metabase_found=true
        echo "✅ Found potential Metabase application(s)"
        echo "Raw response (install jq for better formatting):"
        echo "$response"
    else
        echo "❌ No Metabase applications found"
    fi
fi

echo ""
echo "Step 3: Checking deployment status..."
echo "-----------------------------------"

if [[ "$metabase_found" == true ]]; then
    echo "✅ Metabase application exists in Coolify"
    
    # Try to check additional details if jq is available
    if command -v jq >/dev/null 2>&1; then
        echo ""
        echo "📊 Detailed Status Information:"
        echo "$response" | jq -r '.data[]? | select(.name | test("metabase"; "i")) | "Application: \(.name)\nStatus: \(.status // "unknown")\nEnvironment: \(.environment // "unknown")\nCreated: \(.created_at // "unknown")\nUpdated: \(.updated_at // "unknown")"' 2>/dev/null || echo "Unable to parse detailed status"
    fi
    
    echo ""
    echo "🔗 Access Information:"
    echo "- Coolify Dashboard: $COOLIFY_URL"
    echo "- Check application logs and status in the Coolify UI"
    echo "- If FQDN is configured, the application should be accessible via that URL"
    
else
    echo "❌ Metabase application not found in Coolify"
    echo ""
    echo "Possible reasons:"
    echo "1. Application hasn't been created yet - run INSTALL.sh"
    echo "2. Application was deleted"
    echo "3. Application name doesn't contain 'metabase'"
    echo ""
    echo "Next steps:"
    echo "- Check the Coolify dashboard manually at: $COOLIFY_URL"
    echo "- Verify application exists in your project"
    echo "- Run INSTALL.sh if application needs to be created"
fi

echo ""
echo "Step 4: Additional checks..."
echo "---------------------------"

# Check projects
echo "Checking available projects..."
projects_response=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    "$COOLIFY_URL/api/v1/projects" || echo "FAILED")

if [[ "$projects_response" != "FAILED" ]]; then
    if command -v jq >/dev/null 2>&1; then
        echo "Available projects:"
        echo "$projects_response" | jq -r '.data[]? | "- \(.name) (ID: \(.id))"' 2>/dev/null || echo "Unable to parse projects"
    else
        echo "✅ Projects API accessible (install jq for better formatting)"
    fi
else
    echo "⚠️  Unable to fetch projects information"
fi

echo ""
echo "=============================================="
echo "Verification completed"
echo "=============================================="

if [[ "$metabase_found" == true ]]; then
    echo "✅ RESULT: Metabase application found in Coolify"
    exit 0
else
    echo "❌ RESULT: Metabase application not found"
    exit 1
fi