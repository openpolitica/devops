#/bin/bash -x

#Init directory 
INIT_DIR=${PWD}

echo "Staring health checking...".
./check-health.sh

if [[ ! $? = 0 ]]; then
  echo "Check-health has failed, can't upload".
  exit 1
fi

#Get latest changes from repository
git pull

DATABASE_FILEPATH=${INIT_DIR}/database.sql
DATABASE_BACKUP_FILEPATH=${INIT_DIR}/database.back.sql
# Check if there is a backup in path
if [ !  -f "$DATABASE_BACKUP_FILEPATH" ];then
  echo "Backup file doesn't found in directory, skipping"
  exit 1
fi


if [ !  -f "$DATABASE_FILEPATH" ];then
  echo "Previous database doesn't exit. Move current backup"
  mv $DATABASE_BACKUP_FILEPATH $DATABASE_FILEPATH
else
  #Comparing both databases
  # -I '^-- Dump completed on' avoids timestamp in dumps.
  # it also could be useful with --skip-dump-date when generating dumps
  # Based on https://stackoverflow.com/a/61417132/5107192
  DIFFERENCES=`diff -I '^-- Dump completed on' $DATABASE_FILEPATH $DATABASE_BACKUP_FILEPATH`
  if [ -z $DIFFERENCES ]; then
    echo "Both databases are equal, do not commit"
    exit 0 
  fi
  # Databases are different so update database
  rm $DATABASE_FILEPATH
  cp $DATABASE_BACKUP_FILEPATH $DATABASE_FILEPATH
fi

dt=$(date '+%d/%m/%Y %H:%M:%S');
git add $DATABASE_FILEPATH


SAVED_USER=`git config user.name`
SAVED_EMAIL=`git config user.email`

if [ !  -z $GIT_USER ]; then
  git config user.name $GIT_USER
elif [ !  -z $SAVED_USER ]; then
  GIT_USER=$SAVED_USER
else
  GIT_USER=Script
  git config user.name $GIT_USER
fi

if [ !  -z $GIT_EMAIL ]; then
  git config user.email $GIT_EMAIL
elif [ !  -z $SAVED_EMAIL ]; then
  GIT_EMAIL=$SAVED_EMAIL
else
  GIT_EMAIL=$GIT_USER@email.com
  git config user.email $GIT_EMAIL
fi

git commit -m "Update database $dt"

if [ -z $GIT_USER ] || [ -z $GIT_API ]; then
  echo "Environment variables not set, you should pass in prompt"
  git push -u origin database-update
else
  git push https://$GIT_USER:$GIT_API@github.com/openpolitica/devops.git database-update
fi

