#!/bin/bash

# Load environment variables
source ../.env

# Set the default user credentials
DEFAULT_USER="default_user"
DEFAULT_PASSWORD="default_password"

# Create the default user with the specified permissions
docker exec -it ${PROJECT_NAME}-filebrowser-container filebrowser users add ${DEFAULT_USER} ${DEFAULT_PASSWORD} --perm.download --perm.upload
