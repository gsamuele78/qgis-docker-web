#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Set up directory structure
mkdir -p data/storage log certbot filebrowser
touch log/qgis.log log/nginx.log log/filebrowser.log
chown -R $USER:$USER data log # Replace with your user if needed

# Join domain (if needed) - Uncomment the following line after configuring scripts/join-domain.sh
# ./scripts/join-domain.sh

# Build and run Docker Compose
docker-compose build
docker-compose up -d

echo "Setup completed. Services are running in the background."
echo "Access QGIS at https://<your_domain_or_ip>"
echo "Access File Browser at https://<your_domain_or_ip>/files"
