#!/bin/bash

# Metabase Service Management Script for Coolify
# This script provides management operations for the Metabase service

set -e

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
SERVICE_UUID="qwo48og08k80og40c8k8k8g4"
SERVICE_NAME="metabase-service"

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  status    - Show service status"
    echo "  deploy    - Deploy/redeploy the service"
    echo "  stop      - Stop the service"
    echo "  start     - Start the service"
    echo "  restart   - Restart the service"
    echo "  logs      - Show recent logs"
    echo "  delete    - Delete the service (with confirmation)"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 deploy"
    echo "  $0 logs"
}

# Function to get service status
get_status() {
    echo "🔍 Fetching service status..."
    RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID")
    
    STATUS=$(echo "$RESPONSE" | jq -r '.status' 2>/dev/null || echo "unknown")
    METABASE_STATUS=$(echo "$RESPONSE" | jq -r '.applications[0].status' 2>/dev/null || echo "unknown")
    POSTGRES_STATUS=$(echo "$RESPONSE" | jq -r '.databases[0].status' 2>/dev/null || echo "unknown")
    
    echo "📊 Service Status: $STATUS"
    echo "   Metabase: $METABASE_STATUS"
    echo "   PostgreSQL: $POSTGRES_STATUS"
    
    # Show FQDN if available
    FQDN=$(echo "$RESPONSE" | jq -r '.applications[0].fqdn' 2>/dev/null || echo "null")
    if [ "$FQDN" != "null" ] && [ "$FQDN" != "" ]; then
        echo "🌐 Access URL: $FQDN"
    fi
}

# Function to deploy service
deploy_service() {
    echo "🚀 Deploying Metabase service..."
    RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID/deploy")
    
    if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
        echo "❌ Error deploying service:"
        echo "$RESPONSE" | jq '.errors'
        exit 1
    fi
    
    echo "✅ Deployment initiated!"
    echo "   Monitor progress in Coolify dashboard"
}

# Function to stop service
stop_service() {
    echo "🛑 Stopping Metabase service..."
    curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID/stop" >/dev/null
    
    echo "✅ Stop command sent!"
}

# Function to start service
start_service() {
    echo "▶️  Starting Metabase service..."
    curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID/start" >/dev/null
    
    echo "✅ Start command sent!"
}

# Function to restart service
restart_service() {
    echo "🔄 Restarting Metabase service..."
    stop_service
    sleep 5
    start_service
}

# Function to show logs
show_logs() {
    echo "📋 Recent logs for Metabase service:"
    echo "   Note: Use Coolify dashboard for real-time logs"
    echo "   Dashboard: $COOLIFY_BASE_URL"
}

# Function to delete service
delete_service() {
    echo "⚠️  WARNING: This will permanently delete the Metabase service!"
    echo "   Service: $SERVICE_NAME ($SERVICE_UUID)"
    echo "   This action cannot be undone."
    echo ""
    read -p "Type 'DELETE' to confirm: " CONFIRMATION
    
    if [ "$CONFIRMATION" != "DELETE" ]; then
        echo "❌ Deletion cancelled"
        exit 1
    fi
    
    echo "🗑️  Deleting service..."
    RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X DELETE \
        "$COOLIFY_BASE_URL/api/v1/services/$SERVICE_UUID")
    
    if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
        echo "❌ Error deleting service:"
        echo "$RESPONSE" | jq '.errors'
        exit 1
    fi
    
    echo "✅ Service deleted successfully!"
}

# Main script logic
COMMAND=${1:-""}

case $COMMAND in
    "status")
        get_status
        ;;
    "deploy")
        deploy_service
        ;;
    "stop")
        stop_service
        ;;
    "start")
        start_service
        ;;
    "restart")
        restart_service
        ;;
    "logs")
        show_logs
        ;;
    "delete")
        delete_service
        ;;
    *)
        show_usage
        exit 1
        ;;
esac