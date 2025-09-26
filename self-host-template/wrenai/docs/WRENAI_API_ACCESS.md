# WrenAI API Access & Live Context

This document explains how to programmatically access your WrenAI deployment to read live context (e.g., whether modeling is deployed, number of chat conversations, API history) and how to call the core REST and GraphQL APIs.

Environment file: `src/.env`

| Service | URL | Port | Status | Purpose |
|---------|-----|------|--------|---------|
| **WrenAI UI** | https://business-insight-app-customize.timothynguyen.work | 3000 | ✅ Healthy | GraphQL API + web UI |
| **WrenAI Service** | https://business-insight-app-customize-wrenai-service.timothynguyen.work | 5555 | ✅ Healthy | Core AI REST API (FastAPI) |

## REST API (WrenAI Service)

Base: `https://business-insight-app-customize-wrenai-service.timothynguyen.work`

Key endpoints (from OpenAPI at `/openapi.json`):
- Health: `GET /health`
- Ask (submit a question): `POST /v1/asks`
- Poll result: `GET /v1/asks/{query_id}/result`
- Streaming result: `GET /v1/asks/{query_id}/streaming-result`
- Stop ask: `PATCH /v1/asks/{query_id}`

Ask flow (typical):
1) Submit ask
```
curl -s -H 'content-type: application/json' -d '{
  "query": "Which are the top 3 cities with the highest number of orders?",
  "mdl_hash": "<your_mdl_hash>",
  "request_from": "api"
}' \
  https://business-insight-app-customize-wrenai-service.timothynguyen.work/v1/asks
# => { "query_id": "..." }
```

2) Poll result
```
curl -s \
  https://business-insight-app-customize-wrenai-service.timothynguyen.work/v1/asks/<query_id>/result | jq .
```

Notes:
- `mdl_hash` is required. If you are using the UI, deploy the semantic model first and then reuse the MDL hash the UI uses.
- The service runs long operations in the background; poll until status is FINISHED/FAILED.

Other useful endpoints from OpenAPI:
- `POST /v1/instructions` and related: manage instructions used to steer responses.
- `POST /v1/semantics-preparations` + `GET /v1/semantics-preparations/{mdl_hash}/status`: prepare/check semantic indexing state.

## GraphQL API (WrenAI UI)

Endpoint: `POST https://business-insight-app-customize.timothynguyen.work/api/graphql`

Common queries we use for context:
- Threads list: `{ threads { id summary } }`
- Thread detail: `{ thread(threadId: ID) { id responses { id question sql } } }`
- Instructions: `{ instructions { id instruction isDefault createdAt } }`
- API history (paginated): `query($off:Int!,$lim:Int!){ apiHistory(pagination:{offset:$off,limit:$lim}){ total items { id apiType statusCode createdAt } } }`
- Project status: `{ onboardingStatus { status } modelSync { status } settings { productVersion language dataSource { type } } }`
