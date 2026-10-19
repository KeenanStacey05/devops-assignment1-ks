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
    