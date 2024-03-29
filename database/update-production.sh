#/bin/bash -x

#Init directory 
INIT_DIR=${PWD}

#Get most recent database
git pull origin database-update

DATABASE_FILEPATH=${INIT_DIR}/database.sql
DATABASE_BACKUP_FILEPATH=${INIT_DIR}/database.back.sql
# Check if there is a backup in path
if [ !  -f "$DATABASE_FILEPATH" ];then
  echo "Backup file doesn't found in directory, skipping"
  exit 1
fi

#Create a backup of current database
./create-backup.sh

#Compare both databases
DIFFERENCES=`diff -I '^-- Dump completed on' $DATABASE_FILEPATH $DATABASE_BACKUP_FILEPATH`
if [ -z $DIFFERENCES ]; then
  echo "Both databases are equal, do not update database from repository"
  exit 0 
fi
# Databases are different so update database

#Set environment variables
MYSQL_HOST=`sudo docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' open-politica-backend_votu_backend_mariadb_1`
MYSQL_USER=root
MYSQL_PWD=op123%
LOGIN=local

# Delete previous configuration
rm -rf ~/.mylogin.cnf

# Used to pass the password in simulating interactive mode
unbuffer expect -c "
spawn mysql_config_editor set --login-path=$LOGIN --host=$MYSQL_HOST --user=$MYSQL_USER --password
expect -nocase \"Enter password:\" {send \"$MYSQL_PWD\r\"; interact}
"

DATABASE_NAME=op

#Drop database
mysqladmin --login-path=$LOGIN -f drop $DATABASE_NAME 
mysqladmin --login-path=$LOGIN create $DATABASE_NAME 

#Restore from backup
mysql --login-path=$LOGIN --database=op < $DATABASE_FILEPATH
