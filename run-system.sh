#!/bin/sh

set -e

#Create a docker network shared between the containers
docker network create --label project=chinook-agent chinook-net

