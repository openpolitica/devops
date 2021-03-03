#/bin/bash -x

#Set environment variables
MYSQL_HOST=`sudo docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' open-politica-backend_votu_backend_mariadb_1`
MYSQL_USER=root
LOGIN=local

DATABASE_NAME=op

rm -rf ~/.mylogin.cnf
export MYSQL_HOST=$MYSQL_HOST
export MYSQL_PWD=$MYSQL_PWD
export MYSQL_TCP_PORT=$MYSQL_TCP_PORT
mysql_config_editor set --login-path=local --skip-warn --user=root
#Create a copy for a modified database
#Column-statistics is disabled, otherwise will throw an error
mysqldump --login-path=$LOGIN --column-statistics=0  --databases $DATABASE_NAME > database.sql
