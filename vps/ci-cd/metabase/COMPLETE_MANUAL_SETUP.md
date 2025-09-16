# Complete Manual Setup Guide - Metabase Application

## 🚨 **Current Situation**
The PostgreSQL service is created but may need manual intervention in the Coolify dashboard to start properly.

## ✅ **PostgreSQL Service Ready**
- **Name**: `metabase-db`
- **UUID**: `tkc0s408ws00ckc4o88swc0s` 
- **Status**: Created, needs manual start
- **Port**: 5710:5432

## 🎯 **Complete Setup Steps**

### Step 1: Start PostgreSQL Service Manually
1. Go to: https://coolify.timothynguyen.work
2. Navigate to: **Services** → **metabase-db**
3. Click the **"Start"** button
4. Wait for status to change to "running:healthy" (may take 1-2 minutes)

### Step 2: Create Metabase Application
1. In Coolify, click **"+ New"** → **"Application"**
2. Choose **"Docker Image"** as source
3. Fill in **exactly**:
   - **Name**: `metabase-app`
   - **Docker Image**: `metabase/metabase:latest`
   - **Port Exposes**: `3000`
   - **Port Mappings**: `5700:3000`

### Step 3: Environment Variables
Add these **6 environment variables**:
```
MB_DB_TYPE=postgres
MB_DB_HOST=postgres-tkc0s408ws00ckc4o88swc0s
MB_DB_PORT=5432
MB_DB_DBNAME=metabase
MB_DB_USER=metabase
MB_DB_PASS=metabase123
```

### Step 4: Deploy Application
1. Click **"Save"** to create the application
2. Click **"Deploy"** to start it
3. Wait for deployment to complete

## ✅ **Expected Result**

After completing both steps:
- **Services**: `metabase-db` (running on port 5710)
- **Applications**: `metabase-app` (running on port 5700)

## 🔍 **Verification**

Run this command to verify everything is working:
```bash
cd /root/CODE/TIMOTHY/devops/vps/ci-cd/metabase
./VERIFY_APPLICATION.sh
```

Expected output:
- ✅ Metabase application found and running
- ✅ PostgreSQL service running  
- ✅ Ports 5700 and 5710 active
- ✅ Both services responding

## 🌐 **Access Metabase**

Once both are running:
- **URL**: `http://your-server-ip:5700`
- **Domain**: Configure in Coolify application settings

## 🔧 **If PostgreSQL Won't Start**

If the PostgreSQL service still won't start in the dashboard:
1. Check the **Logs** in the service page for error messages
2. Common issues:
   - Port conflict (check if something else uses 5710)
   - Volume/permission issues
   - Docker network problems

Alternative: You can also try **"Restart"** instead of **"Start"**

## 🎉 **Final Architecture**

Once complete, you'll have:
- **PostgreSQL**: Reliable database service (port 5710)
- **Metabase**: Full application with domain management (port 5700)
- **Benefits**: SSL, domains, health checks, rollbacks

---

**The key difference**: Manual dashboard control sometimes works better than API for service management in Coolify. Both the PostgreSQL service and Application setup are ready - just needs manual starting! 🚀