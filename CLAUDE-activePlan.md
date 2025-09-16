# Plan: Self-Host Metabase

## Overview
Create a complete self-hosting solution for Metabase business intelligence platform without using Coolify. Working directory: `self-host-template/metabase/`

## Architecture Decision
- **Docker Compose**: Simple orchestration for single-host deployment
- **PostgreSQL Database**: Production-ready external database (vs default H2)
- **Persistent Storage**: Docker volumes for data persistence
- **Environment Configuration**: `.env` file approach for secrets management
- **Script Management**: Shell scripts following workspace patterns
- **Port Allocation**: Sequential ports starting from 5700, incrementing by 10 per service

## Port Allocation Strategy
- **Metabase Web UI**: Port 5700
- **PostgreSQL Database**: Port 5710 (external access for admin tools)

## Implementation Plan

### Part 1: Core Infrastructure
**Goal**: Set up Docker Compose stack with Metabase + PostgreSQL

**Files to Create**:
- `docker-compose.yml` - Main orchestration file with:
  - Metabase service (port 5700)
  - PostgreSQL service (port 5710 for external access)
  - Named volumes for persistence
  - Health checks for both services
  - Proper networking configuration

- `.example.env` - Environment variables template with:
  - Database credentials placeholders
  - Metabase configuration options
  - Port mappings
  - Volume paths

**Key Requirements**:
- Use `metabase/metabase:latest` image
- PostgreSQL with persistent volume
- Environment variables for DB connection
- Health checks
- Proper service dependencies

### Part 2: Management Scripts
**Goal**: Provide easy management commands following workspace patterns

**Scripts to Create**:
- `INSTALL.sh` - Initial setup script:
  - Copy `.env.template` to `.env`
  - Create necessary directories
  - Pull Docker images
  - Start services and wait for health
  - Display access information

- `UNINSTALL.sh` - Complete cleanup script:
  - Stop and remove containers
  - Remove Docker images
  - Remove volumes (with confirmation)
  - Clean up created files

- `START.sh` - Start services script
- `STOP.sh` - Stop services script  

**Script Requirements**:
- Follow `<UPPERCASE_SNAKE_CASE>.sh` naming
- Include debugging echo messages
- Error handling and validation
- Follow workspace colocation principle

### Part 3: Validation

**Testing Plan**:
- Test fresh installation process
- Verify uninstall cleans everything
- Test start/stop/restart operations
- Validate health checks work
- Confirm data persistence across restarts

## Security Considerations
- Use environment variables for all secrets
- No hardcoded passwords in any files
- Document secret key names only (never values)

## Success Criteria
1. ✅ Single command installation: `./INSTALL.sh`
2. ✅ Metabase accessible at `http://localhost:5700`
3. ✅ PostgreSQL accessible at `localhost:5710` for external tools
4. ✅ Data persists across container restarts
5. ✅ Complete cleanup with: `./UNINSTALL.sh`
6. ✅ All management scripts work reliably

## Following Workspace Patterns
- ✅ COLOCATION: All related files in same directory
- ✅ SIMPLICITY: Direct implementation, no over-engineering
- ✅ SHELL SCRIPTS: Uppercase naming convention
- ✅ RECOVERY: Uninstall capability for fresh starts