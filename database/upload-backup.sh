#/bin/bash -x

#Init directory 
INIT_DIR=${PWD}

DATABASE_BACKUP_FILEPATH=${INIT_DIR}/database.sql
# Check if there is a backup in path
if [ !  -f "$DATABASE_BACKUP_FILEPATH" ];then
  echo "Backup file doesn't found in directory, skipping"
  exit 1
fi

dt=$(date '+%d/%m/%Y %H:%M:%S');
git add $DATABASE_BACKUP_FILEPATH
git commit -m "Update database $dt"

if [ -z $GIT_USER ] || [ -z $GIT_API ]; then
  echo "Environment variables not set, you should pass in prompt"
  git push -u origin database-update
else
  git push --repo https://$GIT_USER:$GIT_API@github.com/openpolitica/devops.git database-update
fi

