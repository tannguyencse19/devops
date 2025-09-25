## Quick Diagnosis:
```bash
curl -X POST http://localhost:7200/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"operationName": "CreateAskingTask", "variables": {"data": {"question": "test"}}, "query": "mutation CreateAskingTask($data: AskingTaskInput!) { createAskingTask(data: $data) { id __typename } }"}' \
  | jq '.errors[0].message'
```

# Error 1: "Cannot read properties of null (reading 'hash')"

**Symptom:**
```json
{
  "errors": [
    {
      "message": "Cannot read properties of null (reading 'hash')",
      "extensions": {
        "code": "INTERNAL_SERVER_ERROR"
      }
    }
  ]
}
```

**API Request:**
```json
{
  "operationName": "CreateAskingTask",
  "variables": {
    "data": {
      "question": "Which are the top 3 cities with the highest number of orders?"
    }
  },
  "query": "mutation CreateAskingTask($data: AskingTaskInput!) {\n  createAskingTask(data: $data) {\n    id\n    __typename\n  }\n}"
}
```

**Root Cause:**
WrenAI has no data model configured. The system cannot process natural language questions because there are no database tables/models defined to query against.

**Evidence:**
- `/app/data/mdl/sample.json` contains empty models array: `{"models": []}`
- Related to GitHub issue #319

**Technical Explanation:**
When a user asks "Which are the top 3 cities with the highest number of orders?", the WrenAI system needs to:

1. Parse the natural language question
2. Map it to available data models (tables, columns, relationships)
3. Generate appropriate SQL
4. Execute the query

However, since `models: []` is empty, the system cannot find any data structure to map the question "cities" and "orders" to. When it tries to access properties of the data model object (likely accessing a `hash` property for model identification), it encounters a null/undefined object, causing the JavaScript error.

**Impact:**
- Users cannot ask any questions about their data
- The AI-powered querying feature is completely non-functional
- This affects the core functionality of WrenAI

**Resolution:**
1. **Connect a data source** (database, data warehouse, etc.)
2. **Import/define data models** that describe their tables, columns, and relationships
3. **Configure the semantic layer** so WrenAI can understand concepts like "cities" and "orders"

**Note:** This is a configuration issue, not a code bug. WrenAI cannot function without a properly configured data model that maps business concepts to database structures.

## Debugging Commands

```bash
# Check current data model
docker exec wrenai-wren-ui-1 cat /app/data/mdl/sample.json

# Reproduce the error
curl -X POST http://localhost:7200/api/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "operationName": "CreateAskingTask",
    "variables": {
      "data": {
        "question": "Which are the top 3 cities with the highest number of orders?"
      }
    },
    "query": "mutation CreateAskingTask($data: AskingTaskInput!) {\n  createAskingTask(data: $data) {\n    id\n    __typename\n  }\n}"
  }'

# Check WrenUI logs for errors
docker compose logs wren-ui --tail=20
```

---

# Error 2: "connect ECONNREFUSED 10.0.3.5:7210"

**Symptom:**
```json
{
  "errors": [
    {
      "locations": [
        {
          "line": 2,
          "column": 3
        }
      ],
      "path": [
        "createAskingTask"
      ],
      "message": "connect ECONNREFUSED 10.0.3.5:7210",
      "extensions": {
        "code": "INTERNAL_SERVER_ERROR",
        "message": "connect ECONNREFUSED 10.0.3.5:7210",
        "shortMessage": "Internal server error"
      }
    }
  ],
  "data": null
}
```

**Root Cause:**
Port configuration mismatch in wren-ai-service force deploy logic causing infinite restart loop. When `SHOULD_FORCE_DEPLOY=1`, the wren-ai-service startup script incorrectly attempts to connect to wren-ui on port 7220, but wren-ui actually runs on internal port 3000.

**Evidence:**
- wren-ai-service logs show: `"Timeout: wren-ui did not start within 60 seconds"`
- Container status shows frequent restarts: "Up 30 seconds (healthy)" 
- Environment has `SHOULD_FORCE_DEPLOY=1` and `WREN_UI_PORT=7220`
- wren-ui actually runs on port 3000 internally: `docker port wrenai-wren-ui-1` shows `3000/tcp -> 0.0.0.0:7200`
- Manual startup without force deploy succeeds: `SHOULD_FORCE_DEPLOY="" uvicorn src.__main__:app` works
- Connectivity test: `nc -z wren-ui 7220` fails, `nc -z wren-ui 3000` succeeds

**Technical Explanation:**
The wren-ai-service entrypoint script contains flawed force deploy logic:
1. Starts uvicorn in background successfully
2. Waits for wren-ai-service itself on port 7210 ✓  
3. **FAILS** waiting for `wren-ui:$WREN_UI_PORT` (7220) - this port doesn't exist
4. Times out after 60 seconds and exits due to `set -e`
5. Docker restarts container due to `restart: on-failure`
6. Creates infinite restart loop

The issue is a variable misunderstanding: `WREN_UI_PORT=7220` from .env is meant for external references, but wren-ui always runs on port 3000 inside its container. The entrypoint script incorrectly uses the external port variable to check internal container connectivity.

**Impact:**
- wren-ai-service never truly starts due to infinite restart loop
- All AI-powered functionality completely broken with ECONNREFUSED errors
- High resource usage from continuous container restart cycle
- System appears "healthy" in Docker status but core features fail
- Unlike temporary race conditions, this prevents the service from ever becoming available

**Note:** This is a configuration/startup script issue, not a service dependency problem. The wren-ai-service container appears "healthy" to Docker because the health check only tests port availability, but the actual service process exits due to the failed force deploy dependency check.


## Debugging Commands
```bash
# Check container status and restart patterns
docker compose ps

# Check wren-ai-service restart loop logs
docker compose logs wren-ai-service --tail=50

# Verify environment variables causing the issue
docker exec wrenai-wren-ai-service-1 env | grep -E "(SHOULD_FORCE_DEPLOY|WREN_UI_PORT)"

# Check actual wren-ui port mapping vs expected
docker port wrenai-wren-ui-1

# Test connectivity on correct vs incorrect ports  
docker exec wrenai-wren-ai-service-1 nc -z wren-ui 3000 && echo "SUCCESS: Port 3000" || echo "FAIL: Port 3000"
docker exec wrenai-wren-ai-service-1 nc -z wren-ui 7220 && echo "SUCCESS: Port 7220" || echo "FAIL: Port 7220"

# Test manual startup without force deploy logic
docker exec wrenai-wren-ai-service-1 bash -c 'SHOULD_FORCE_DEPLOY="" uvicorn src.__main__:app --host 0.0.0.0 --port 7210 &'

# View the problematic entrypoint script
docker exec wrenai-wren-ai-service-1 cat /app/entrypoint.sh
```

## Related Resources

- [WrenAI GitHub Repository](https://github.com/Canner/WrenAI)
- [Issue #319: Failed to create asking task](https://github.com/Canner/WrenAI/issues/319)