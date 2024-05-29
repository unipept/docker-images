#! /bin/bash

# Exit immediately when an error occurs
set -e

# Exit when a command in one of the pipelines fails
set -o pipefail

echo
echo "📋 Generating all input files..."
echo "unipept" | su -c "/unipept-database/scripts/build_database.sh -i '/index' -d '/tmp' -m $SORT_MEMORY suffix-array-index $DB_TYPES $DB_SOURCES '/tmp/tables'" 'root'

echo "unipept" | su -c "touch /tmp/tables/.completed" 'root'

echo
echo "📋 Loading the database tables..."
mariadb -uunipept -punipept < /unipept-database/schemas/structure_no_index.sql
/unipept-database/scripts/load.sh '/tmp/tables'
rm -f '/tables/**/*.tsv.lz4'

echo
echo "📋 indexing the database..."
/unipept-database/scripts/index.sh

echo "✅ Finished construction of the database!"
