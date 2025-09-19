# 🎯 How to Access Your Metabase App

## 📊 **Current Status**
- ✅ **PostgreSQL Service**: `metabase-db` is running and healthy
- ❌ **Metabase Application**: NOT created yet - needs manual setup

## 🚀 **To Access Metabase, Complete These Steps:**

### Step 1: Create Metabase Application in Coolify Dashboard

1. **Go to Coolify Dashboard**: https://coolify.timothynguyen.work
2. **Click "New +"** → **"Application"** 
3. **Select "Docker Image"**
4. **Configure Application**:
   - **Name**: `metabase-app`
   - **Docker Image**: `metabase/metabase:latest`
   - **Port Exposes**: `3000`
   - **Port Mappings**: `5700:3000`

### Step 2: Add Environment Variables
Add these **6 environment variables** in the application:

```
MB_DB_TYPE=postgres
MB_DB_HOST=postgres-tkc0s408ws00ckc4o88swc0s
MB_DB_PORT=5432
MB_DB_DBNAME=metabase
MB_DB_USER=metabase
MB_DB_PASS=metabase123
```

### Step 3: Deploy and Access

1. **Click "Save"** → **"Deploy"**
2. **Wait for deployment** (2-3 minutes)
3. **Access your Metabase**:

## 🌐 **Access Methods**

### Option 1: Direct IP Access
```
http://YOUR_SERVER_IP:5700
```

### Option 2: Domain Access (Recommended)
1. In Coolify, go to your `metabase-app` application
2. Click **"Domains"** tab
3. Add your domain (e.g., `metabase.yourdomain.com`)
4. Coolify will automatically handle SSL certificates
5. Access: `https://metabase.yourdomain.com`

## 🔍 **Verify Everything is Working**

Run this command to check status:
```bash
cd /root/CODE/TIMOTHY/devops/vps/ci-cd/metabase
./VERIFY_APPLICATION.sh
```

Expected output when ready:
- ✅ Metabase application found and running
- ✅ PostgreSQL service running:healthy  
- ✅ Ports 5700 and 5710 active
- ✅ Both services responding

## 🎉 **First-Time Metabase Setup**

When you first access Metabase, you'll need to:

1. **Create Admin Account**: Set up your admin username/password
2. **Database Already Connected**: PostgreSQL is pre-configured via environment variables
3. **Start Building Dashboards**: Your data visualization platform is ready!

## 🛠️ **If Something Goes Wrong**

### Application Won't Deploy?
- Check the deployment logs in Coolify dashboard
- Verify all 6 environment variables are correct
- Make sure port 5700 isn't used by other services

### Can't Connect to Database?
- Verify PostgreSQL service is running (should show "running:healthy")
- Double-check environment variables match exactly
- Check PostgreSQL logs if needed

---

**🚨 Important**: You MUST complete the manual application creation in the Coolify dashboard first. The PostgreSQL database is ready and waiting for your Metabase application!

**⏰ Estimated Time**: 5-10 minutes for manual setup → Full Metabase access