#!/bin/bash +x

#Variables for deployment
ROOT_DIRECTORY=${HOME}
SERVICES_DIRECTORY_NAME=services
SERVICES_DIRECTORY=${ROOT_DIRECTORY}/${SERVICES_DIRECTORY_NAME}

# move to home directory
cd ${ROOT_DIRECTORY}

# Installing docker and java
sudo ./install-docker.sh
sudo ./install-java.sh
sudo ./install-mysql-client.sh

# Prepare nginx environment
./prepare-nginx.sh ${ROOT_DIRECTORY} ${SERVICES_DIRECTORY_NAME}

# Install the backend
./deploy-backend.sh ${SERVICES_DIRECTORY}

# Load the database
./update-database.sh ${SERVICES_DIRECTORY}

exit
