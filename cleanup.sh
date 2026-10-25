#!/bin/sh

# Cleanup script to remove all docker constructs created by run-system.sh
docker rm -fv chinook-agent chinook-gateway chinook-seeder chinook-db || true  
docker network rm chinook-net || true
docker rmi chinook-seeder-image chinook-agent-image || true

