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
mkdir -p matomo
cd matomo

#Add configuration files for backend
cp ${INIT_DIR}/docker-compose.yml ./

if [ -z $HOST_DOMAIN ] || [ -z $EMAIL_DOMAIN ]; then
  echo "Environment variables not set, loading .env file"
  cp ${INIT_DIR}/.env ./
else
  echo "HOST_DOMAIN=${HOST_DOMAIN}" > .env
  echo "EMAIL_DOMAIN=${EMAIL_DOMAIN}" >> .env
fi

#Copy files to nginx-proxy
PROXY_DIRECTORY=${SERVICES_DIRECTORY}/nginx-proxy
cp ${INIT_DIR}/matomo.conf ${PROXY_DIRECTORY}/vhost.d/${HOST_DOMAIN}
sudo sed -i 's/php-handler/'${HOST_DOMAIN}'-upstream/g' ${PROXY_DIRECTORY}/vhost.d/${HOST_DOMAIN}

sudo docker-compose up -d
