# WrenAI Deploy Model Error

## Quick Fix (Most Common Issue)

**Problem:** Deployment fails with `{"status": "FAILED", "error": "...hash..., [object Object]"}`

**Root Cause:** OpenAI API quota exceeded

**Solution:**
1. Visit [OpenAI Platform Billing](https://platform.openai.com/account/billing)
2. Add credits to your account
3. Retry deployment

---

## Error Details

**GraphQL Request:**
```json
{
  "operationName": "Deploy",
  "variables": {},
  "query": "mutation Deploy {\n  deploy\n}"
}
```

**Response:**
```json
{
  "data": {
    "deploy": {
      "status": "FAILED", 
      "error": "Wren AI Error: deployment hash:27a7ee69c008ed8b184d27448d8427c5ac1539ff, [object Object]"
    }
  }
}
```


## Complete Debugging Commands

```bash
# Service health
docker compose ps
docker compose logs wren-ai-service --tail=20

# Data model check
docker exec wrenai-wren-ui-1 ls -la /app/data/
docker exec wrenai-wren-ui-1 cat /app/data/mdl/sample.json

# Network test
docker compose exec wren-ui ping wren-ai-service

# Error pattern search
docker compose logs wren-ai-service | grep -E "(quota|credential|RateLimitError|insufficient_quota|Error code: 429)"
```

### Service Restart Sequence
```bash
# After configuration changes
docker compose down
# Edit .env file
docker compose up -d
docker compose ps  # Verify all running
```

### Quick Debugging

```bash
# Check deployment status
curl -X POST http://localhost:7200/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"operationName": "Deploy", "variables": {}, "query": "mutation Deploy {\n  deploy\n}"}'

# Monitor logs during deployment
docker compose logs --follow wren-ai-service | grep -E "(quota|error|RateLimitError)"

# Check OpenAI key is loaded
docker compose exec wren-ai-service printenv | grep OPENAI_API_KEY
```

---

## Possible Cause

### Vector Dimension Mismatch ⚠️ **CONFIGURATION ERROR**

**Error in Logs:**
```
Vector dimension error: expected dim: 3072, got 1536
qdrant_client.http.exceptions.UnexpectedResponse: Unexpected Response: 400 (Bad Request)
```

**Root Cause:** Configuration mismatch in `config.yaml`:
- Line 18: `model: text-embedding-3-small` → produces **1536 dimensions**
- Line 36: `embedding_model_dim: 3072` → expects **3072 dimensions**

**Solution:**
```bash
# Fix the configuration mismatch
# Edit config.yaml line 36:
embedding_model_dim: 1536  # Change from 3072 to 1536

# Then clear vector database and restart
docker compose down
docker volume rm wrenai_data
docker compose up -d
```

### OpenAI API Quota Exceeded 

**Error in Logs:**
```
openai.RateLimitError: Error code: 429 - {'error': {'message': 'You exceeded your current quota, please check your plan and billing details...', 'type': 'insufficient_quota'}}
```

### Missing OpenAI API Key

**Check `.env` file:**
```bash
OPENAI_API_KEY=  # ❌ Empty
OPENAI_API_KEY=sk-proj-... # ✅ Configured
```

**Fix:** Add valid API key and restart services:
```bash
docker compose restart wren-ai-service
```

### Empty Data Model

**Check if models exist:**
```bash
docker exec wrenai-wren-ui-1 cat /app/data/mdl/sample.json
```

**If empty (`"models": []`):** Configure data models before deployment.


### Service Connection Problems
```
connect ECONNREFUSED 10.0.3.5:7210
```
**Fix:** Restart all services: `docker compose restart`

---

## Resources

- [OpenAI Platform (Billing)](https://platform.openai.com/account/billing)
- [OpenAI Error Codes](https://platform.openai.com/docs/guides/error-codes/api-errors) 
- [WrenAI GitHub](https://github.com/Canner/WrenAI)