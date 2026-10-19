#!/bin/sh

set -e

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