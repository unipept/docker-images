FROM postgres:16.2-bullseye

###
# Name: unipept-database
#
# This Dockerfile can be used to build an image that contains everything required to spin up a container with a
# functioning Unipept database (the database will be filled with all of the required data).
#
# Parameters (are being referenced as environment variables in the Dockerfile)
#   * DB_TYPES: names of the database sources that are to be parsed by this script (comma-delimited, one name per
#   source).
#   * DB_SOURCES: list of URLs that point to the database sources that should be used as a basis to construct the
#   database.
#   * FILTER_TAXA: a list of NCBI taxon ID's (comma-delimited) by which the resulting Unipept database should be
#   filtered. Only UniProt-entries that are associated with these ID's (or their children in the NCBI taxonomy
#   tree) are being kept during the build process.
#   * VERBOSE: Should all debugging information be printed during the Docker build? Is false by default.
#
# Mount-points:
#   * /index: Directory that will hold the Unipept database index. If this index is present from previous database
#   builds, and it is valid, it can help to speed up the construction process of future containers.
#   * /tmp: Directory that will be used by this container to store temporary files. Note that this directory can
#   become very large and that it will benefit from very fast storage.
#   * /tables: Directory that contains the generated database table files (that are used to fill up the constructed
#   database). These files will typically only be available during the construction process of the container.
#   * /var/lib/mysql: Directory that will contain the persistent MySQL datafiles. This directory should always be
#   mounted at the same location in order to start the database.
###

LABEL maintainer="Pieter Verschaffelt <pieter.verschaffelt@ugent.be>"

RUN mkdir -p /usr/share/man/man1
RUN apt update && \
    apt install -y \
    git \
    dos2unix \
    wget \
    unzip \
    expect \
    gawk \
    binutils \
    gcc \
    libssl-dev \
    uuid-runtime \
    pv \
    pigz \
    parallel \
    curl \
    sudo \
    lz4


# Configure curl to use the newly builded libcurl
#RUN ldconfig

RUN git clone --depth 1 -b feature/postgres https://github.com/stijndcl/unipept-database
COPY "db_entrypoint.sh" "/docker-entrypoint-initdb.d/db_entrypoint.sh"

# Sometimes, these files are copied over from Windows systems and need to be converted into Unix line endings to make
# sure that these can be properly executed by the container.
RUN dos2unix /unipept-database/scripts/**/*.sh && chmod u+x /unipept-database/scripts/*.sh

RUN echo 'root:unipept' | chpasswd

ADD ./rust-binaries /unipept-database/scripts/helper_scripts

# Database types that should be processed by this image. Delimited by comma's.
ENV DB_TYPES swissprot
# Database URLs that should be downloaded and processed by this container. Delimited by comma's, n'th item in this list
# should correspond to n'th db type given in DB_TYPES arg.
ENV DB_SOURCES https://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.dat.gz
# List of taxa (separated by comma's) for which all children (and the nodes themselves) should be present in the final
# database.
ENV FILTER_TAXA 1

ENV VERBOSE false

ENV SORT_MEMORY 2G

EXPOSE 3306
