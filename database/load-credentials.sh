#!/bin/bash 
# Script to load credentials employed for other scripts

#Set environment variables
MYSQL_USER=root
LOGIN=local

if [ -z $MYSQL_HOST ]; then
  echo "Environment variable MYSQL_HOST not set, replacing by default value"
  MYSQL_HOST=`sudo docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' open-politica-backend_votu_backend_mariadb_1`
fi

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
