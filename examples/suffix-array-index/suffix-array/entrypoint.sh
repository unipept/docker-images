#! /bin/bash

# Exit immediately when an error occurs
set -e

# Exit when a command in one of the pipelines fails
set -o pipefail

if [ $COMPRESSED = "true" ]
then
    COMPRESSED="-c"
else
    COMPRESSED=""
fi

# Check if the index is already present and only needs to be started (or needs to be constructed if no data is available)
if [ ! -f "/suffix-array/.completed" ]
then
    rm -rf /suffix-array/*

    # Move the required files for the suffix array to its directory (and extract only the required columns)
    echo "📋 Start extracting required data for suffix array construction..."
    lz4cat /tmp/tables/uniprot_entries.tsv.lz4 | cut -f2,4,7,8 > /suffix-array/proteins.tsv
    lz4cat /tmp/tables/taxons.tsv.lz4 > /suffix-array/taxons.tsv
    echo "✅ Successfully extracted the required data!"

    # Remove all other database files
    rm -rf '/tmp/tables'

    /unipept-index/target/release/sa-builder -d /suffix-array/proteins.tsv -t /suffix-array/taxons.tsv --sparseness-factor "$SAMPLE_RATE" -o /suffix-array/sa.bin "$COMPRESSED"

    # Write the `.completed` file to indicate that this suffix array build is complete
    touch /suffix-array/.completed
else
    echo
    echo "✅ Suffix array has already been constructed!"
fi

echo
/unipept-index/target/release/sa-server -d /suffix-array/proteins.tsv -t /suffix-array/taxons.tsv -i /suffix-array/sa.bin
