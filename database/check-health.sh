#/bin/bash -x
# This script makes some queries to the database to check if it has a correct
# set of data.
# Basically it performs two processes:
# 1. Verify if candidate related tables has more than a specified number of
# rows
# 2. Verify that generated tables has no null values
#
####### REQUIRES TO SET ENVIRONMENT VALUES #########
# export MYSQL_HOST=localhost_or_remote_host
# export MYSQL_PWD=password_for_root_user
# export MYSQL_TCP_PORT=tcp_port_if_not_3306

CANDIDATE_NUMBER_THRESHOLD=2000

# Includes all tables which has some relationship with candidate
candidate_related_tables=(\
  candidato \
  afiliacion \
  bien_mueble \
  bien_inmueble \
  data_ec \
  educacion \
  experiencia \
  extra_data\
  ingreso \
  sentencias_ec \
  sentencia_civil \
  sentencia_penal \
)

# Include all tables which should be in the database
expected_tables=(\
  ${candidate_related_tables[@]} \
  locations \
  proceso_electoral \
  dirty_lists \
)

# We expect some tables has the same number as the candidates number
# other tables are not directly related to candidate number so the threshold is
# hardcoded in those cases
threshold_minimum=(\
  $CANDIDATE_NUMBER_THRESHOLD \
  3000 \
  2000 \
  3500 \
  $CANDIDATE_NUMBER_THRESHOLD \
  11000 \
  5000 \
  $CANDIDATE_NUMBER_THRESHOLD \
  $CANDIDATE_NUMBER_THRESHOLD \
  150 \
  150 \
  50 \
  25 \
  2000 \
  150 \
  )

generated_tables=()

# Login to mysql
echo "----------------------------------------------"
echo "#### Login to MySQL"
mysql_config_editor set --login-path=local --skip-warn --user=root

function build_sql_command() {
  echo 'mysql --login-path=local --database=op --default-character-set=utf8 -s -N -e "'$*'"'
}

# Requires $sql_query variable to process the command
# Make a query and store results in variables
# Based on: https://www.pontikis.net/blog/store-mysql-result-to-array-from-bash
function read_sql_result_one(){
  local column_names=$*
  i=0
  cmd=`build_sql_command $sql_query`
  while IFS=$'\t' read ${column_names[0]} ;do
    name="${column_names[0]}"
    VALUES[$i]="${!name}"
    ((i++))
  done < <( eval $cmd )
}

# Based on https://stackoverflow.com/a/16453214/5107192
function read_sql_result_two(){
  local column_names=$@
  i=0
  cmd=`build_sql_command $sql_query`
  while IFS=$'\t' read ${column_names[@]} ;do
      IFS=' ' read -a ARRAY <<< "${column_names[@]}"
      name_1="${ARRAY[0]}"
      name_2="${ARRAY[1]}"
      VALUES_1[$i]="${!name_1}"
      VALUES_2[$i]="${!name_2}"
      ((i++))
  done < <( eval $cmd )
}
# Converts the array to a coma separated string
# Based on: https://stackoverflow.com/a/53839433/5107192
function join_arr() {
  local IFS="$1"
  shift
  echo "$*" | sed s/"$IFS"/"$IFS"\ /g
}

# Get index of value in array
# Based on: https://stackoverflow.com/a/15028821/5107192
function get_index() {
  local value="$1"
  shift
  my_array="$*"
  for i in "${!my_array[@]}"; do
     if [[ "${my_array[$i]}" = "${value}" ]]; then
         echo "${i}";
         break
     fi
  done
}

# 1. Verify if expected tables exists in database
sql_query="SHOW TABLES from op;"
columns=(table_name)
read_sql_result_one ${columns[@]}

missing_tables=0
for expected_table in ${expected_tables[@]}; do
   if [[ "${VALUES[@]}" =~ "${expected_table}" ]]; then
     echo "$expected_table is in the database ... Ok";
   else
     echo "$expected_table isn't in the database ... Fail";
     ((missing_tables++))
   fi
done

if [[ $missing_tables > 0 ]]; then
  echo "There are $missing_tables missing tables. Check failed."
  exit 1
fi


# 2. Verify if expected tables has a minimum number of rows
# Create a temporary table to hold the count data 
# Build sql sentence
TEMP_COUNT_TABLE=temp_count
count_column_names=(table_name count)
sql_query="DROP TABLE IF EXISTS $TEMP_COUNT_TABLE;  
  CREATE TABLE $TEMP_COUNT_TABLE (${count_column_names[0]} TEXT,\
    ${count_column_names[1]} INT(11));"

for table_name in "${expected_tables[@]}"; do
  sql_query="${sql_query} INSERT INTO $TEMP_COUNT_TABLE VALUES ('$table_name',
  (SELECT COUNT(*) FROM $table_name));"
done

sql_query="${sql_query} SELECT `join_arr , ${count_column_names[@]}` FROM $TEMP_COUNT_TABLE;"
echo $sql_query

IFS=" "
read_sql_result_two "${count_column_names[@]}"

# For each table name search index and threshold value to compare with actual
# count value
i=0
count_inconsistent=0
for table_name in ${VALUES_1[@]}; do
  index=`get_index $table_name ${VALUES_1[@]}`

  if [[ $VALUES_2[$i] > $threshold_minimum[$index] ]]; then
    echo "Number of rows in $table_name, greater than minimum ... Ok."
  else
    echo "Number of rows in $table_name, lesser than minimum. \
      It has $count_values[$i] and expect a minimum of \
      $threshold_minimum[$index] ... Fail."

    ((count_inconsistent++))
  fi
  ((i++))
done


if [[ $count_inconsistent > 0 ]]; then
  echo "There are $count_inconsistent tables with less data than \
    expected. Check failed."
  exit 1
fi

