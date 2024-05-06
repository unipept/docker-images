#! /bin/bash

# Exit immediately when an error occurs
set -e
# Exit when a command in one of the pipelines fails
set -o pipefail

echo "Started Unipept Database entrypoint execution"

# This command should produce tsv.gz files that can later on be inserted into the database.
cd "/unipept-database"

if [ $VERBOSE = "true" ]
then
    VERBOSE="-v "
else
    VERBOSE=""
fi

echo "unipept" | su -c "./scripts/build_database.sh $VERBOSE-f $FILTER_TAXA -i '/index' -d '/tmp' -m $SORT_MEMORY database $DB_TYPES $DB_SOURCES '/tmp/tables'" root

echo "***** START LOADING TABLES *****"

# Data has been generated by this point. Now, we can load it into the PSQL-database for use later on.
PGPASSWORD=unipept psql -U unipept < schemas/structure_no_index_no_constraints.sql
echo "unipept" | su -c "./scripts/parallel_load.sh '/tmp/tables'" root
rm -f '/tables/**/*.tsv.lz4'

echo "***** START APPLYING CONSTRAINTS *****"
PGPASSWORD=unipept psql -U unipept < schemas/structure_constraints_only.sql

echo "***** START INDEXING TABLES *****"

echo "unipept" | su -c "./scripts/parallel_index.sh" root
