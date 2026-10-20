#!/bin/sh

set -e

export MSYS_NO_PATHCONV=1

#Create a docker network shared between the containers
docker network create --label project=chinook-agent chinook-net

# Start the database on the network
docker run -d \
    --name chinook-db \
    --network chinook-net \
    --label project=chinook-agent \
    -e "POSTGRES_USER=chinook_user" \
    -e "POSTGRES_PASSWORD=chinook_pass" \
    -e "POSTGRES_DB=chinook" \
    postgres

#  Wait for the database to be ready
until docker exec chinook-db pg_isready -h localhost -U chinook_user; do
    echo "Waiting for database to be ready..."
    sleep 2
done

# Build the seeder image 
docker build \
    --target seeder \
    --label project=chinook-agent \
    -t chinook-seeder-image \
    .

# Run the seeder so the script waits for the data load to finish
docker run \
    --name chinook-seeder \
    --network chinook-net \
    --label project=chinook-agent \
    -v "$(pwd)/Chinook.db:/app/Chinook.db" \
    -e SQLITE_FILE=/app/Chinook.db \
    -e DATABASE_URL=postgres://chinook_user:chinook_pass@chinook-db:5432/chinook \
    chinook-seeder-image

# Starting the MCP gateway
docker run -d \
    --name chinook-gateway \
    --network chinook-net \
    --label project=chinook-agent \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$(pwd)/mcp_config.yaml:/mcp_config.yaml" \
    -v "$(pwd)/mcp_secret.env:/run/secrets/database-url" \
    docker/mcp-gateway:latest \
    --transport=sse \
    --secrets=/run/secrets/database-url \
    --allow-unauthenticated \
    --servers=cockroachdb \
    --tools=execute_query \
    --config=/mcp_config.yaml 