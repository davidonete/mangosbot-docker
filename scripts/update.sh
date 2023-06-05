#!/bin/bash

script_path=$(dirname "$0")
cd "$script_path"
cd ..

mangosd_container="mangosbot_mangosd_1"
realmd_container="mangosbot_realmd_1"

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

echo "Rebuilding containers..."
docker-compose build --no-cache

echo "Starting the containers..."
docker-compose up -d