# Setup Metabase as Coolify Application

Since Coolify Application API has restrictions, here's the manual setup process to deploy Metabase as an Application with proper domain management.

## 🎯 **Approach: Manual Setup via Coolify Dashboard**

### **Step 1: Create PostgreSQL Database Service**

The PostgreSQL database has already been created via API:
- **Service UUID**: `j88g84ssgw8g4ock8g4g0s4o`
- **Service Name**: `metabase-postgres`
- **Port**: 5710:5432

#### Deploy PostgreSQL:
1. Go to [Coolify Dashboard](https://coolify.timothynguyen.work)
2. Navigate to **PRODUCTION** project → **Services** → **metabase-postgres**
3. Update the **POSTGRES_PASSWORD** environment variable with a strong password
4. Click **Deploy**
5. Wait for deployment to complete and note the status

### **Step 2: Create Metabase Application via Dashboard**

#### Option A: Use Docker Compose (Recommended)
1. Go to **PRODUCTION** project → **+ New Resource** → **Application**
2. Choose **Docker Compose**
3. **Name**: `metabase-app`
4. **Server**: `timothy-3 Hetzner Server`
5. **Repository**: Skip (we'll use raw docker-compose)
6. **Docker Compose Configuration**:
   ```yaml
   services:
     metabase:
       image: metabase/metabase:latest
       restart: unless-stopped
       ports:
         - "5700:3000"
       environment:
         MB_DB_TYPE: postgres
         MB_DB_DBNAME: metabase
         MB_DB_PORT: 5710
         MB_DB_USER: metabase
         MB_DB_PASS: YOUR_STRONG_PASSWORD_HERE
         MB_DB_HOST: 95.217.1.194
       healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
         interval: 30s
         timeout: 10s
         retries: 5
         start_period: 300s
       volumes:
         - metabase-data:/plugins

   volumes:
     metabase-data:
       driver: local
   ```

#### Option B: Use Static Image
1. Go to **PRODUCTION** project → **+ New Resource** → **Application**
2. Choose **Docker Image**
3. **Name**: `metabase-app`
4. **Docker Image**: `metabase/metabase:latest`
5. **Ports Exposed**: `3000`
6. **Port Mappings**: `5700:3000`
7. **Environment Variables**:
   - `MB_DB_TYPE`: `postgres`
   - `MB_DB_DBNAME`: `metabase`
   - `MB_DB_USER`: `metabase`
   - `MB_DB_PASS`: `YOUR_STRONG_PASSWORD_HERE`
   - `MB_DB_HOST`: `95.217.1.194`
   - `MB_DB_PORT`: `5710`

### **Step 3: Configure Domain**
1. Once the application is created, go to **Settings** → **Domains**
2. Coolify will automatically generate a domain like: `metabase-app-xyz.timothynguyen.work`
3. Or add a custom domain if desired

### **Step 4: Deploy Metabase Application**
1. Ensure PostgreSQL service is running first
2. In the Metabase application, click **Deploy**
3. Monitor the logs for successful startup
4. Wait for health check to pass

## 🔧 **Port Configuration**
- **Metabase External**: Port 5700
- **Metabase Internal**: Port 3000
- **PostgreSQL External**: Port 5710
- **PostgreSQL Internal**: Port 5432

## 🔐 **Security Checklist**
- [ ] Update PostgreSQL password in the service
- [ ] Update PostgreSQL password in Metabase application environment
- [ ] Ensure both passwords match exactly
- [ ] Verify network connectivity between services

## 🌐 **Access Information**
- **PostgreSQL Connection**: `95.217.1.194:5710`
- **Metabase URL**: Auto-generated domain by Coolify
- **Direct Access**: `http://95.217.1.194:5700` (if port is exposed)

## ✅ **Verification Steps**
1. Check PostgreSQL service status: Should be "running"
2. Check Metabase application status: Should be "running"
3. Access Metabase URL: Should show Metabase setup/login page
4. Complete Metabase initial setup wizard

## 🐛 **Troubleshooting**
- **Connection refused**: Check if PostgreSQL service is running first
- **Password authentication failed**: Ensure passwords match in both services
- **Timeout**: Metabase needs 5+ minutes for initial startup
- **Health check failed**: Wait for full startup, health checks start after 300s

---
**PostgreSQL Service UUID**: `j88g84ssgw8g4ock8g4g0s4o`  
**Setup Date**: 2025-09-16  
**Status**: Ready for manual configuration