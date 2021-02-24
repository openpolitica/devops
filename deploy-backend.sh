#!/bin/bash -x

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

sudo docker-compose up -d
