# Metabase Dockerfile for Coolify Application Deployment
FROM metabase/metabase:latest

# Install curl for health checks
USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
USER metabase

# Expose port 3000 (internal) - Coolify will map to external port 5700
EXPOSE 3000

# Create data directory for H2 database (fallback if no external DB)
USER root
RUN mkdir -p /app/data && chown -R metabase:metabase /app/data
USER metabase

# Environment variables will be set by Coolify
# Default to H2 if no external database configured
ENV MB_DB_TYPE=h2
ENV MB_DB_FILE=/app/data/metabase.db

# Health check for Coolify
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=5 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Start Metabase on port 3000
CMD ["java", "-jar", "/app/metabase.jar"]