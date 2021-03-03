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

#Detects if service directory exists
if [ !  -d "$SERVICES_DIRECTORY" ];then
  echo "Services directory doesn't exist, creating."
  mkdir -p $SERVICES_DIRECTORY
fi

BACKEND_DIRECTORY=${SERVICES_DIRECTORY}/open-politica-backend
#Detects if service directory exists
if [ !  -d "$BACKEND_DIRECTORY" ];then
  echo "Backend directory doesn't exist, cloning from repository."
  cd ${SERVICES_DIRECTORY}
  git clone https://github.com/openpolitica/open-politica-backend.git
  cd open-politica-backend
  git checkout tags/v1.0 -b 1.0
fi

cd ${BACKEND_DIRECTORY}/src/dbtools

#Set environment variables
MYSQL_HOST=`sudo docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' open-politica-backend_votu_backend_mariadb_1`
MYSQL_USER=root
LOGIN=local

if [ -z $MYSQL_PWD ]; then
  echo "Environment variable MYSQL_PWD not set, replacing by default value"
  MYSQL_PWD=op123%
fi

if [ -z $MYSQL_TCP_PORT ]; then
  echo "Environment variable MYSQL_TCP_PORT not set, replacing by default value"
  MYSQL_TCP_PORT=3306
fi

rm -rf ~/.mylogin.cnf
export MYSQL_HOST=$MYSQL_HOST
export MYSQL_PWD=$MYSQL_PWD
export MYSQL_TCP_PORT=$MYSQL_TCP_PORT

#restore changes made for other scripts
git restore reset_mysql.sh
#Run the script to load the database
./reset_mysql.sh

cd ${INIT_DIR}
./create-backup.sh
