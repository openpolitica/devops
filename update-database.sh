#/bin/bash -x
#Setting variables
if [ -z "$1" ]
  then
    echo "No services folder directory supplied replaced by $HOME/services"
		SERVICES_DIRECTORY=${HOME}/services
  else
		SERVICES_DIRECTORY=$1
fi

BACKEND_DIRECTORY=${SERVICES_DIRECTORY}/open-politica-backend
cd ${BACKEND_DIRECTORY}
#Run the script to load the database
./src/dbtools/reset_mysql.sh
