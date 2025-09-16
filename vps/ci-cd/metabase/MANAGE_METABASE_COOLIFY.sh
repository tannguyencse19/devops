#!/bin/bash

# Comprehensive Metabase Coolify Management Script
# This script manages both PostgreSQL service and Metabase application

set -e

# Configuration
COOLIFY_API_TOKEN="5|0IZMg4cQaIGgoBdeHN5x27idlmwFN0OQbA4XONAD84f15f59"
COOLIFY_BASE_URL="https://coolify.timothynguyen.work"
POSTGRES_SERVICE_UUID="j88g84ssgw8g4ock8g4g0s4o"
SERVICE_NAME="metabase-postgres"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  status           - Show PostgreSQL service status"
    echo "  deploy-postgres  - Deploy PostgreSQL service"
    echo "  stop-postgres    - Stop PostgreSQL service"
    echo "  start-postgres   - Start PostgreSQL service"
    echo "  setup-manual     - Show manual application setup instructions"
    echo "  check-ports      - Check if ports 5700/5710 are available"
    echo "  full-status      - Show comprehensive status of all components"
    echo ""
    echo "Management:"
    echo "  logs             - Show PostgreSQL service logs (via dashboard)"
    echo "  cleanup          - Remove PostgreSQL service"
    echo ""
    echo "Examples:"
    echo "  $0 full-status"
    echo "  $0 deploy-postgres"
    echo "  $0 setup-manual"
}

# Function to get PostgreSQL service status
get_postgres_status() {
    echo -e "${BLUE}🔍 Fetching PostgreSQL service status...${NC}"
    RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_SERVICE_UUID" 2>/dev/null || echo "ERROR")
    
    if [ "$RESPONSE" = "ERROR" ]; then
        echo -e "${RED}❌ Error: Cannot connect to Coolify API${NC}"
        return 1
    fi
    
    STATUS=$(echo "$RESPONSE" | jq -r '.status' 2>/dev/null || echo "unknown")
    DB_STATUS=$(echo "$RESPONSE" | jq -r '.databases[0].status' 2>/dev/null || echo "unknown")
    
    echo -e "${GREEN}📊 PostgreSQL Service Status: $STATUS${NC}"
    echo -e "${GREEN}   Database Status: $DB_STATUS${NC}"
    echo -e "${BLUE}   Service UUID: $POSTGRES_SERVICE_UUID${NC}"
    echo -e "${BLUE}   Service Name: $SERVICE_NAME${NC}"
    echo -e "${BLUE}   Port Mapping: 5710:5432${NC}"
}

# Function to check port availability
check_ports() {
    echo -e "${BLUE}🔌 Checking port availability...${NC}"
    
    # Check port 5700 (Metabase)
    if netstat -tuln 2>/dev/null | grep -q ":5700 "; then
        echo -e "${YELLOW}⚠️  Port 5700 is in use (Metabase)${NC}"
        netstat -tuln | grep ":5700 "
    else
        echo -e "${GREEN}✅ Port 5700 is available (Metabase)${NC}"
    fi
    
    # Check port 5710 (PostgreSQL)
    if netstat -tuln 2>/dev/null | grep -q ":5710 "; then
        echo -e "${YELLOW}⚠️  Port 5710 is in use (PostgreSQL)${NC}"
        netstat -tuln | grep ":5710 "
    else
        echo -e "${GREEN}✅ Port 5710 is available (PostgreSQL)${NC}"
    fi
}

# Function to deploy PostgreSQL service
deploy_postgres() {
    echo -e "${BLUE}🚀 Deploying PostgreSQL service...${NC}"
    RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_SERVICE_UUID/deploy")
    
    if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
        echo -e "${RED}❌ Error deploying PostgreSQL service:${NC}"
        echo "$RESPONSE" | jq '.errors'
        return 1
    fi
    
    echo -e "${GREEN}✅ PostgreSQL deployment initiated!${NC}"
    echo -e "${BLUE}   Monitor progress in Coolify dashboard${NC}"
}

# Function to show manual setup instructions
show_manual_setup() {
    echo -e "${BLUE}📚 Metabase Application Manual Setup${NC}"
    echo ""
    echo -e "${GREEN}Since Coolify Application API requires specific authentication,${NC}"
    echo -e "${GREEN}follow these steps to create the Metabase application:${NC}"
    echo ""
    echo -e "${YELLOW}🎯 Step 1: Ensure PostgreSQL is Running${NC}"
    echo "   Run: $0 deploy-postgres"
    echo "   Verify: $0 status"
    echo ""
    echo -e "${YELLOW}🎯 Step 2: Create Metabase Application in Dashboard${NC}"
    echo "   1. Go to: $COOLIFY_BASE_URL"
    echo "   2. Navigate: PRODUCTION project → + New Resource → Application"
    echo "   3. Choose: Docker Compose"
    echo "   4. Name: metabase-app"
    echo "   5. Use the docker-compose.app.yml file content"
    echo ""
    echo -e "${YELLOW}🎯 Step 3: Configure Environment Variables${NC}"
    echo "   MB_DB_TYPE: postgres"
    echo "   MB_DB_DBNAME: metabase"
    echo "   MB_DB_USER: metabase"
    echo "   MB_DB_PASS: <STRONG_PASSWORD>"
    echo "   MB_DB_HOST: 95.217.1.194"
    echo "   MB_DB_PORT: 5710"
    echo ""
    echo -e "${YELLOW}🎯 Step 4: Set Port Configuration${NC}"
    echo "   Ports Exposed: 3000"
    echo "   Port Mappings: 5700:3000"
    echo ""
    echo -e "${YELLOW}🎯 Step 5: Deploy Application${NC}"
    echo "   Click Deploy and monitor logs"
    echo ""
    echo -e "${GREEN}📖 Detailed instructions: SETUP_AS_APPLICATION.md${NC}"
}

# Function to show comprehensive status
show_full_status() {
    echo -e "${BLUE}🌟 Comprehensive Metabase Coolify Status${NC}"
    echo "==========================================="
    echo ""
    
    # PostgreSQL Service Status
    get_postgres_status
    echo ""
    
    # Port Status
    check_ports
    echo ""
    
    # Application Status (manual check)
    echo -e "${BLUE}📱 Metabase Application Status:${NC}"
    echo -e "${YELLOW}   Manual check required - see dashboard${NC}"
    echo -e "${BLUE}   Dashboard: $COOLIFY_BASE_URL${NC}"
    echo ""
    
    # Configuration Summary
    echo -e "${BLUE}⚙️  Configuration Summary:${NC}"
    echo -e "${GREEN}   PostgreSQL Service: $SERVICE_NAME${NC}"
    echo -e "${GREEN}   PostgreSQL UUID: $POSTGRES_SERVICE_UUID${NC}"
    echo -e "${GREEN}   PostgreSQL Port: 5710:5432${NC}"
    echo -e "${GREEN}   Metabase Port: 5700:3000${NC}"
    echo -e "${GREEN}   Project: PRODUCTION${NC}"
    echo -e "${GREEN}   Server: timothy-3 Hetzner Server${NC}"
}

# Function to stop PostgreSQL service
stop_postgres() {
    echo -e "${BLUE}🛑 Stopping PostgreSQL service...${NC}"
    curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_SERVICE_UUID/stop" >/dev/null
    
    echo -e "${GREEN}✅ PostgreSQL stop command sent!${NC}"
}

# Function to start PostgreSQL service
start_postgres() {
    echo -e "${BLUE}▶️  Starting PostgreSQL service...${NC}"
    curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X POST \
        "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_SERVICE_UUID/start" >/dev/null
    
    echo -e "${GREEN}✅ PostgreSQL start command sent!${NC}"
}

# Function to show logs information
show_logs() {
    echo -e "${BLUE}📋 PostgreSQL Service Logs${NC}"
    echo -e "${YELLOW}Access logs via Coolify dashboard:${NC}"
    echo -e "${BLUE}$COOLIFY_BASE_URL${NC}"
    echo "Navigate to: PRODUCTION → Services → $SERVICE_NAME → Logs"
}

# Function to cleanup service
cleanup_service() {
    echo -e "${RED}⚠️  WARNING: This will permanently delete the PostgreSQL service!${NC}"
    echo -e "${RED}   Service: $SERVICE_NAME ($POSTGRES_SERVICE_UUID)${NC}"
    echo -e "${RED}   This action cannot be undone.${NC}"
    echo ""
    read -p "Type 'DELETE POSTGRES' to confirm: " CONFIRMATION
    
    if [ "$CONFIRMATION" != "DELETE POSTGRES" ]; then
        echo -e "${YELLOW}❌ Cleanup cancelled${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🗑️  Deleting PostgreSQL service...${NC}"
    RESPONSE=$(curl -s -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Accept: application/json" \
        -X DELETE \
        "$COOLIFY_BASE_URL/api/v1/services/$POSTGRES_SERVICE_UUID")
    
    if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
        echo -e "${RED}❌ Error deleting service:${NC}"
        echo "$RESPONSE" | jq '.errors'
        return 1
    fi
    
    echo -e "${GREEN}✅ PostgreSQL service deleted successfully!${NC}"
}

# Main script logic
COMMAND=${1:-""}

case $COMMAND in
    "status")
        get_postgres_status
        ;;
    "deploy-postgres")
        deploy_postgres
        ;;
    "stop-postgres")
        stop_postgres
        ;;
    "start-postgres")
        start_postgres
        ;;
    "setup-manual")
        show_manual_setup
        ;;
    "check-ports")
        check_ports
        ;;
    "full-status")
        show_full_status
        ;;
    "logs")
        show_logs
        ;;
    "cleanup")
        cleanup_service
        ;;
    *)
        show_usage
        exit 1
        ;;
esac