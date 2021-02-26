#!/bin/bash -x

#Init directory 
INIT_DIR=${PWD}

#Setting variables
if [ -z "$1" ]
  then
    echo "No services folder directory supplied replaced by $HOME/services"
		SERVICES_DIRECTORY=${HOME}/services
  else
		SERVICES_DIRECTORY=$1
fi

cd ${SERVICES_DIRECTORY}
git clone https://github.com/openpolitica/open-politica-backend.git
cd open-politica-backend
git checkout tags/v1.0 -b 1.0

#Add configuration files for backend
cp ${INIT_DIR}/backend/Dockerfile ./
cp ${INIT_DIR}/backend/docker-compose ./

if [ -z $HOST_DOMAIN ] || [ -z $EMAIL_DOMAIN ]; then
  echo "Environment variables not set, loading .env file"
  cp ${INIT_DIR}/backend/.env ./
fi

sudo docker build -t openpolitica/votu_backend:latest -f Dockerfile . 

sudo docker-compose up -d
