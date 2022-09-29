#! /bin/bash

# Exit immediately when an error occurs
set -e
# Exit when a command in one of the pipelines fails
set -o pipefail

# This command should produce tsv.gz files that can later on be inserted into the database.
cd "/make-database"

if [ $VERBOSE = "true" ]
then
    VERBOSE="-v "
else
    VERBOSE=""
fi

echo "unipept" | su -c "./scripts/build_database.sh $VERBOSE-f $FILTER_TAXA -i '/index' -d '/tmp' -m $SORT_MEMORY database $DB_TYPES $DB_SOURCES '/tmp/tables'" root

echo "***** START LOADING TABLES *****"

# Data has been generated by this point. Now, we can load it into the MySQL-database for use later on.
mysql -uunipept -punipept < schemas/structure_no_index.sql
echo "unipept" | su -c "./scripts/load.sh '/tmp/tables'" root
rm -f '/tables/**/*.tsv.gz'

echo "***** START INDEXING TABLES *****"

echo "unipept" | su -c "./scripts/index.sh" root
