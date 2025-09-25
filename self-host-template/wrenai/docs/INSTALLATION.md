# Installation

https://docs.getwren.ai/oss/installation

`curl -L https://github.com/Canner/WrenAI/releases/latest/download/wren-launcher-linux.tar.gz | tar -xz && ./wren-launcher-linux`

# Fixes

## Fix `host.docker.internal: forward host lookup failed`

`echo "127.0.0.1 host.docker.internal" | sudo tee -a /etc/hosts`

## Fix "Invalid initializing SQL" error with sample datasets

**Issue**: ECOMMERCE sample dataset fails with "Invalid initializing SQL" error (INIT_SQL_ERROR)

**Root Cause**: The wren-engine Java application is hardcoded to listen on port 8080, but custom configurations may set `WREN_ENGINE_PORT` to other values. The UI tries to connect using the configured port but gets connection refused.

**Fix**: In `.env` file, ensure `WREN_ENGINE_PORT` matches the hardcoded port:
```bash
WREN_ENGINE_PORT=8080
```

**Note**: While other service ports can be customized, `WREN_ENGINE_PORT` must remain `8080` due to the Java application limitation.