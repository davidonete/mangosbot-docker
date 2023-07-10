#!/bin/bash

script_path=$(dirname "$0")
cd "$script_path"
cd ..

mangosd_container="mangosbot-mangosd"
realmd_container="mangosbot-realmd"

# Stop mangosd container and wait for it to finish
echo "Stopping ${mangosd_container}..."
docker stop "$mangosd_container"

echo "Waiting for ${mangosd_container} to stop gracefully..."
while [[ $(docker inspect -f '{{.State.Running}}' "$mangosd_container" 2>/dev/null) == "true" ]]; do
  sleep 5
done

echo "Stopping ${realmd_container}..."
docker stop "$realmd_container"

echo "Remove old containers and images to rebuild"
docker rm "$mangosd_container"
docker rm "$realmd_container"
#docker rmi "$(docker images -q "$mangosd_container")"
#docker rmi "$(docker images -q "$realmd_container")"

# Remove the initialized flag
rm -rf config/.initialized

# Stop the script execution if errors happen
set -e

echo "Rebuilding containers..."
docker-compose build --no-cache

echo "Starting the containers..."
docker-compose up -d