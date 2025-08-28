#!/bin/bash

# ./vps/ci-cd/secrets/COOLIFY-ENV-SYNC.sh demo-develop-app-with-tdd

set -euo pipefail

APP_NAME="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="${SCRIPT_DIR}/${APP_NAME}.env"
COOLIFY_ENV_FILE="${SCRIPT_DIR}/../coolify/.env"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"

usage() {
    echo "Usage: $0 <APP_NAME>"
    echo "Example: $0 demo-develop-app-with-tdd"
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

validate_prerequisites() {
    log "Validating prerequisites..."
    
    command -v curl >/dev/null 2>&1 || error "curl is required but not installed"
    command -v jq >/dev/null 2>&1 || error "jq is required but not installed"
    
    if [[ -z "$APP_NAME" ]]; then
        error "Application name is required"
        usage
    fi
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        error "Secrets file not found: $SECRETS_FILE"
    fi
    
    if [[ ! -f "$COOLIFY_ENV_FILE" ]]; then
        error "Coolify environment file not found: $COOLIFY_ENV_FILE"
    fi
    
    log "Prerequisites validated successfully"
}

load_coolify_token() {
    log "Loading Coolify API token..."
    
    # Preserve the original APP_NAME before sourcing
    local original_app_name="$APP_NAME"
    
    if ! source "$COOLIFY_ENV_FILE"; then
        error "Failed to source Coolify environment file"
    fi
    
    # Restore the original APP_NAME
    APP_NAME="$original_app_name"
    
    if [[ -z "${GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN:-}" ]]; then
        error "GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN not found in $COOLIFY_ENV_FILE"
    fi
    
    log "Coolify API token loaded successfully"
}

load_secrets() {
    log "Loading secrets from $SECRETS_FILE..."
    
    declare -g ENV_KEYS=()
    declare -g ENV_VALUES=()
    local secrets_count=0
    local has_required_var=false
    
    # Process each line - handle files without trailing newlines properly
    local content
    content=$(cat "$SECRETS_FILE")
    [[ "${content: -1}" != $'\n' ]] && content+=$'\n'
    
    local lines
    readarray -t lines <<< "$content"
    
    for line in "${lines[@]}"; do
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        if [[ "$line" =~ ^[[:space:]]*([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [[ -n "$key" && -n "$value" ]]; then
                ENV_KEYS+=("$key")
                ENV_VALUES+=("$value")
                secrets_count=$((secrets_count + 1))
                [[ "$key" == "VITE_SUPABASE_URL" ]] && has_required_var=true
            fi
        fi
    done
    
    if [[ $secrets_count -eq 0 ]]; then
        error "No valid environment variables found in $SECRETS_FILE"
    fi
    
    if [[ "$has_required_var" != "true" ]]; then
        error "Required variable VITE_SUPABASE_URL not found in $SECRETS_FILE"
    fi
    
    log "Loaded $secrets_count environment variables successfully"
}

find_coolify_application() {
    log "Finding Coolify application: $APP_NAME"
    
    local response
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN" \
        -H "Content-Type: application/json" \
        "$COOLIFY_BASE_URL/api/v1/applications" || true)
    
    local body=$(echo "$response" | head -n -1)
    local http_code=$(echo "$response" | tail -n 1)
    
    if [[ "$http_code" != "200" ]]; then
        error "Failed to fetch applications from Coolify API (HTTP $http_code)"
    fi
    
    local app_uuid
    app_uuid=$(echo "$body" | jq -r --arg name "$APP_NAME" '.[] | select(.name == $name) | .uuid' 2>/dev/null || echo "")
    
    if [[ -z "$app_uuid" || "$app_uuid" == "null" ]]; then
        error "Application '$APP_NAME' not found in Coolify"
    fi
    
    APP_UUID="$app_uuid"
    log "Found application '$APP_NAME' with UUID: $APP_UUID"
}

sync_environment_variables() {
    log "Syncing environment variables to Coolify..."
    
    local success_count=0
    local total_count=${#ENV_KEYS[@]}
    
    for (( i=0; i<${#ENV_KEYS[@]}; i++ )); do
        local key="${ENV_KEYS[i]}"
        local value="${ENV_VALUES[i]}"
        local is_build_time="false"
        
        if [[ "$key" =~ ^VITE_ ]]; then
            is_build_time="true"
        fi
        
        local payload
        payload=$(jq -n \
            --arg key "$key" \
            --arg value "$value" \
            --argjson is_build_time "$is_build_time" \
            '{
                key: $key,
                value: $value,
                is_build_time: $is_build_time,
                is_preview: false,
                is_literal: false
            }')
        
        # Try POST first (create)
        local response
        response=$(curl -s -w "\n%{http_code}" \
            -X POST \
            -H "Authorization: Bearer $GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "$COOLIFY_BASE_URL/api/v1/applications/$APP_UUID/envs" || true)
        
        local body=$(echo "$response" | head -n -1)
        local http_code=$(echo "$response" | tail -n 1)
        
        if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
            log "✓ Created variable: $key (build_time=$is_build_time)"
            ((success_count++))
        elif [[ "$http_code" == "409" ]]; then
            # Variable exists, try PATCH (update)
            log "Variable exists, updating: $key"
            response=$(curl -s -w "\n%{http_code}" \
                -X PATCH \
                -H "Authorization: Bearer $GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$payload" \
                "$COOLIFY_BASE_URL/api/v1/applications/$APP_UUID/envs" || true)
            
            body=$(echo "$response" | head -n -1)
            http_code=$(echo "$response" | tail -n 1)
            
            if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
                log "✓ Updated variable: $key (build_time=$is_build_time)"
                success_count=$((success_count + 1))
            else
                log "✗ Failed to update variable: $key (HTTP $http_code)"
                log "Response body: $body"
            fi
        else
            log "✗ Failed to sync variable: $key (HTTP $http_code)"
            log "Response body: $body"
        fi
    done
    
    log "Environment variable sync completed: $success_count/$total_count successful"
    
    if [[ $success_count -ne $total_count ]]; then
        error "Some environment variables failed to sync"
    fi
}

main() {
    log "Starting Coolify environment variable sync for: $APP_NAME"
    
    validate_prerequisites
    load_coolify_token
    load_secrets
    find_coolify_application
    sync_environment_variables
    
    log "✓ Successfully synced all environment variables for '$APP_NAME'"
    log "✓ Total variables synced: ${#ENV_KEYS[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi