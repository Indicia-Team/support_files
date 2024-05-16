#!/bin/bash

# This script should be called with the -l flag indicating the taxon list
# or comma separated list of taxon lists to use. Examples:
# ./elastic-uksi-lookups.sh -l 1
# ./elastic-ukis-lookups.sh -l 15,251,258,260,261,265,277

while getopts "l:" flag; do
 case $flag in
   l) # Handle the -l flag
   list_ids=$OPTARG
   ;;
 esac
done

if [ "$list_ids" == "" ]; then
  echo "No list ids supplied"
  exit
fi

# Modify the SQL files to use taxon list ID(s) supplied as script argument
# and add the indicia schema to the search_path
if [[ $list_ids == *","* ]]; then
  # Comma separated list of taxon_list IDs
  sed -e "s/=<taxon_list_id>/ IN ($list_ids)/g" prepare-taxa-lookup.sql | sed '1 i\SET search_path to indicia;' > prepare-taxa-lookup-modified.sql
  sed -e "s/=<taxon_list_id>/ IN ($list_ids)/g" prepare-taxon-paths.sql | sed '1 i\SET search_path to indicia;' > prepare-taxon-paths-modified.sql
else
  # Single taxon_list ID
  sed -e "s/<taxon_list_id>/$list_ids/g" prepare-taxa-lookup.sql | sed '1 i\SET search_path to indicia;' > prepare-taxa-lookup-modified.sql
  sed -e "s/<taxon_list_id>/$list_ids/g" prepare-taxon-paths.sql | sed '1 i\SET search_path to indicia;' > prepare-taxon-paths-modified.sql
fi

# Create taxa CSV
psql -U postgres -d indicia --csv -f prepare-taxa-lookup-modified.sql > taxa.csv 

# Remove unwanted header lines
# And replace double & triple text delimeters with single
tail -n +6 taxa.csv | sed -e 's/"""/""/g' | sed -e 's/""/"/g' > taxa.yml 

# Create taxon-paths CSV
psql -U postgres -d indicia --csv -f prepare-taxon-paths-modified.sql > taxon-paths.csv 

# Remove unwanted header lines 
# And replace double & triple text delimeters with single
tail -n +6 taxon-paths.csv | sed -e 's/"""/""/g' | sed -e 's/""/"/g' > taxon-paths.yml 

# Remove temporary files
#rm prepare-taxa-lookup-modified.sql
#rm prepare-taxon-paths-modified.sql
#rm taxa.csv
#rm taxon-paths.csv