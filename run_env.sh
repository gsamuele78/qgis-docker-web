#!/bin/bash
# Load environment variables
source .env

# Verify calculations
echo "Container UID: ${QGIS_USER_UID}, GID: ${QGIS_USER_GID}"
# setenv.sh (run before compose commands)
#export BASE_UID=1000
#export BASE_GID=1000
#export QGIS_USER_UID=$(expr $BASE_UID + 6000)
#export QGIS_USER_GID=$(expr $BASE_GID + 6000)
#export XPRA_PORT=14500
##export XPRA_PASSWORD=xpra_admin
#export XPRA_PASSWORD
#export XPRA_UPLOAD_LIMIT=100M
#export XPRA_FILE_SIZE_LIMIT=1G
## Paths (relative to compose file)
#export QGIS_DATA_DIR=/home/qgisuser/projects
#

#export QGIS_USER_UID
#export QGIS_USER_GID
#export XPRA_PORT
#export XPRA_PASSWORD
#export XPRA_UPLOAD_LIMIT
#export XPRA_FILE_SIZE_LIMIT
#export QGIS_DATA_DIR


# Stop and remove all containers
docker compose down --rmi all --volumes --remove-orphans

# Remove all unused Docker objects
docker system prune -a --volumes --force

# Remove specific leftover files (if needed)
#sudo rm -rf ./data/* ./log/* ./config/*
sudo rm -rf ./data/* ./logs/* 

# Check build context and Dockerfile location
docker compose config | grep -A5 'build:'
# Should show:
#       build:
#         context: /your/project/path
#         dockerfile: Dockerfile

#Create required directories on host
#sudo rm -rf data log 
#mkdir -p ./data/storage ./log ./config/qgis ./config/filebrowser/db

#mkdir -p data/storage/{uploads,downloads} 
#sudo chown -R ${BASE_UID}:${BASE_GID}  ./data ./log ./config 

sudo rm -rf data log logs
mkdir -p ./data/storage ./logs/qgis ./config/qgis ./config/filebrowser/db ./logs/filebrowser
#sudo rm -rf data log
#mkdir -p ./data/storage ./log/filebrowser ./config/qgis ./config/filebrowser/db 
sudo chown -R ${BASE_UID}:${BASE_GID}  ./data ./config ./.logs

# Build and run
#docker compose build --no-cache qgis
#docker compose up qgis
docker compose build --no-cache filebrowser qgis
docker compose up filebrowser qgis

# Create filebrowser default user
#./build/filebrowser/create_default_user.sh


