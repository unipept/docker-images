#! /bin/bash

# Exit immediately when an error occurs
set -e
# Exit when a command in one of the pipelines fails
set -o pipefail

# Check if the index is already present and only needs to be started (or needs to be constructed if no data is available)
if [ ! -f "/suffix-array/.completed" ]
then
  echo "Started construction of the suffix array"

  # Clear the suffix_array directory and restart the build of the index
  rm -rf /suffix-array && mkdir -p /suffix-array

  # Clear the temp directory
  rm -rf /tmp/*

  # First, build the input files for the database and store them in the temporary directory
  /unipept-database/scripts/build_database.sh -i '/index' -d '/tmp' -m $SORT_MEMORY database $DB_TYPES $DB_SOURCES '/tmp/tables'

  # Move the required files for the suffix array to its directory (and extract only the required columns)
  lz4cat /tmp/tables/uniprot_entries.tsv.lz4 | cut -f2,4,7 > /suffix-array/proteins.tsv
  lz4cat /tmp/tables/taxons.tsv.lz4 > /suffix-array/taxons.tsv

  # Remove all other database files
  rm -rf '/tmp/tables'

  # Now, construct the actual suffix array
  /Thesis_rust_implementations/target/release/suffixarray_builder -d /suffix-array/proteins.tsv -t /suffix-array/taxons.tsv --sample-rate 3 -o /suffix-array/sa.bin

  # Write the `.completed` file to indicate that this suffix array build is complete
  touch /suffix-array/.completed

  echo "Finished construction of the suffix array"
fi

echo "Start loading suffix array"

# At this point, we know that the suffix array exists and we can start it.
/Thesis_rust_implementations/target/release/suffixarray_server -d /suffix-array/proteins.tsv -t /suffix-array/taxons.tsv -i /suffix-array/sa.bin
