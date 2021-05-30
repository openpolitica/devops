#!/bin/bash

#Init directory 
INIT_DIR=${PWD}

MATOMO_DB_CONTAINER=matomo_db_1
MATOMO_BACK_DIR=${PWD}/backup

sudo docker exec $MATOMO_DB_CONTAINER bash -c 'cd /var/lib/mysql ; time mysqldump --extended-insert --no-autocommit --quick --single-transaction op -uop -pMIPASSWORD > matomo_backup_database.sql'

# Copy backup of matomo database 
sudo docker cp matomo_db_1:/var/lib/mysql/matomo_backup_database.sql ${MATOMO_BACK_DIR}/matomo_backup_database.sql

# Compress database backup
tar zcf ${MATOMO_BACK_DIR}/matomo-mysql-database-$(date +%Y-%m-%d-%H.%M.%S).sql.tar.gz ${MATOMO_BACK_DIR}/matomo_backup_database.sql
