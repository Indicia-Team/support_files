#!/bin/bash

START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "UKSI Update started : $START_TIME"

# Paths
WAREHOUSE_PATH="/srv/sites/devwarehouse.indicia.org.uk"

BASE_PATH="$(dirname "$0")"
CSV_PATH="$BASE_PATH/"
SCRIPTS_FOLDER="$BASE_PATH/scripts"

# Read DB host & database from warehouse config
DB_HOST=$(php -r "define('SYSPATH', 1); include '$WAREHOUSE_PATH/application/config/database.php'; echo \$config['default']['connection']['host'];")
DB_NAME=$(php -r "define('SYSPATH', 1); include '$WAREHOUSE_PATH/application/config/database.php'; echo \$config['default']['connection']['database'];")

# PostgreSQL superuser
SU_USER="m"
SU_PASS="9"
export PGPASSWORD="$SU_PASS"

echo "DB host: $DB_HOST"
echo "DB name: $DB_NAME"
echo "Scripts folder: $SCRIPTS_FOLDER"
echo "CSV path: $CSV_PATH"

    psql -h "$DB_HOST" -U "$SU_USER" -d "$DB_NAME" \
       -f "$SCRIPTS_FOLDER/resetcounters.sql"

#############################################
# STEP 1: FULL UKSI IMPORT (no-extras mode)
#############################################
php import-uksi.php \
  --warehouse-path=$WAREHOUSE_PATH \
  --su="$SU_USER" \
  --supass="$SU_PASS" \
  --taxon_list_id=15 \
  --user_id=1 \
  --no-extras=true 


#############################################
# STEP 2: RUN FINALISATION.SQL IN BATCHES
#############################################

#echo "Running finalisation.sql in 1M-row batches..."

# This value should match the max occurrence ID in your table
#MAX_ID=$(psql -h "$DB_HOST" -U "$SU_USER" -d "$DB_NAME" -t -c "SELECT max(id) FROM occurrences;")
#MAX_ID=$(echo $MAX_ID | xargs)

#BATCH=1000000
#START=0
#END=$BATCH

#while [ $START -le $MAX_ID ]
#do
#    echo "Processing occurrences id BETWEEN $START AND $END"

#    psql -h "$DB_HOST" -U "$SU_USER" -d "$DB_NAME" \
#       -v start_id=$START \
#      -v end_id=$END \
#      -f "$SCRIPTS_FOLDER/finalisation.sql"

#    START=$((END + 1))
#    END=$((END + BATCH))
#done

#############################################
# ALL DONE
#############################################

FINISH_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "UKSI Update finished : $FINISH_TIME"