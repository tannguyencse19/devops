# 🔧 Simple Database Connection Fix

## 🎯 **Problem Identified**
Your Metabase application is running but can't connect to PostgreSQL because:
- **Error**: `UnknownHostException: postgres-tkc0s408ws00ckc4o88swc0s`
- **Cause**: Incorrect database hostname in environment variables

## ✅ **Current Status**
- ✅ **Metabase App**: Created and running (status: running:unhealthy)  
- ✅ **PostgreSQL Service**: Running and healthy
- ❌ **Connection**: Failed due to wrong hostname

## 🚀 **Quick Fix (2 minutes)**

### Go to Coolify Dashboard:
**URL**: https://coolify.timothynguyen.work

### Navigate to:
**Applications** → **metabase-app** → **Configuration** → **Environment Variables**

### Change This ONE Variable:
```
Variable: MB_DB_HOST
Current Value: postgres-tkc0s408ws00ckc4o88swc0s
New Value: 91.99.53.200
```

### Also Change:
```
Variable: MB_DB_PORT  
Current Value: 5432
New Value: 5710
```

### Then:
1. Click **"Save"**
2. Click **"Deploy"** 
3. Wait 2-3 minutes for restart

## 🎉 **Why This Works**

Instead of trying to resolve complex Docker networking, we're using:
- **Direct server IP**: `91.99.53.200`
- **External PostgreSQL port**: `5710` (maps to internal 5432)

This bypasses Docker network hostname resolution entirely.

## 🔍 **Test Success**

After the fix, run:
```bash
./VERIFY_APPLICATION.sh
```

Expected result:
- ✅ Metabase application: running:healthy
- ✅ Port 5700: Active and responding
- 🌐 Access: `http://91.99.53.200:5700`

## 🏆 **Final Result**

Once fixed, you'll have:
- **Metabase**: `http://91.99.53.200:5700`
- **Domain setup**: Available in Coolify dashboard
- **SSL certificates**: Automatic via Coolify
- **Professional setup**: Ready for business use

---

**Next Step**: Make the changes above and test! 🚀