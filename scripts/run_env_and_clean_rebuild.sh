#!/bin/bash
# Load environment variables
source .env

# Verify calculations
echo "Container UID: ${QGIS_USER_UID}, GID: ${QGIS_USER_GID}"
# setenv.sh (run before compose commands)
export BASE_UID=1000
export BASE_GID=1000
export QGIS_USER_UID=$(expr $BASE_UID + 10000)
export QGIS_USER_GID=$(expr $BASE_GID + 10000)
export XPRA_PORT=14500
#export XPRA_PASSWORD=xpra_admin
export XPRA_PASSWORD
export XPRA_UPLOAD_LIMIT=100M
export XPRA_FILE_SIZE_LIMIT=1G
# Paths (relative to compose file)
export QGIS_DATA_DIR=/home/qgisuser/projects


# Stop and remove all containers
docker compose down --rmi all --volumes --remove-orphans

# Remove all unused Docker objects
docker system prune -a --volumes --force

# Remove specific leftover files (if needed)
sudo rm -rf ./data/storage/* ./log/*

# Check build context and Dockerfile location
docker compose config | grep -A5 'build:'
# Should show:
#       build:
#         context: /your/project/path
#         dockerfile: Dockerfile

#Create required directories on host
mkdir -p data/storage log
#mkdir -p data/storage/{uploads,downloads} 
sudo chown -R ${BASE_UID}:${BASE_GID}  data log
# Build and run
docker compose build --no-cache qgis
docker compose up qgis filebrowser
