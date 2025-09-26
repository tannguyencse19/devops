# Prerequistes

- Deploy Postgres container in WrenAI container network (docker compose)

# Information use to connect WrenAI to Postgres

+ Display name: Business Insight App PostgreSQL
+ Host: <PostgreSQL_Docker_Container_Name> (not `host.docker.internal`, use this `docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Image}}" | grep postgres`)
+ Port: 5432
+ Username: <SPECIFIED_IN_THE_DOCKER_COMPOSE>
+ Password: <SPECIFIED_IN_THE_DOCKER_COMPOSE>
+ Database name: <TARGET_DATABASE_NAME>
+ Use SSL: true