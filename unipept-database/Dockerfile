FROM mysql:latest

###
# Name: unipept-database
#
# This Dockerfile can be used to build a image that contains everything required to spin up a container with a
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
RUN apt-get update && \
    apt-get install -y \
    default-jdk \
    git \
    dos2unix \
    maven \
    make \
    wget \
    unzip \
    expect \
    gawk \
    binutils \
    gcc \
    libssl-dev \
    uuid-runtime \
    pv \
    nodejs \
    pigz \
    parallel \
    sudo

# Now, build curl from source to upgrade it to version 7.68.0 (instead of the default 7.52.0 in this image)
# This fixes https://github.com/curl/curl/issues/3750 which is present in older versions of curl
RUN wget https://curl.haxx.se/download/curl-7.68.0.zip && \
    unzip curl-7.68.0.zip && \
    cd curl-7.68.0 && \
    ./configure --disable-dependency-tracking --with-ssl && \
    make && \
    make install && \
    cd "/"

# Configure curl to use the newly builded libcurl
RUN ldconfig

# Using this branch is a temporary solution and should no longer be required when the latest changes are merged with
# the make-database repository.
RUN git clone https://github.com/unipept/make-database && cd make-database && git checkout feature/cleanup
COPY "db_entrypoint.sh" "/docker-entrypoint-initdb.d/db_entrypoint.sh"

# Sometimes, these files are copied over from Windows systems and need to be converted into Unix line endings to make
# sure that these can be properly executed by the container.
RUN dos2unix /make-database/scripts/**/*.sh /make-database/scripts/**/*.js && chmod u+x /make-database/scripts/*.sh

COPY "config/custom_mysql_config.cnf" "/etc/mysql/conf.d/custom_mysql_config.cnf"
RUN chmod a-w "/etc/mysql/conf.d/custom_mysql_config.cnf"

RUN echo 'root:unipept' | chpasswd

# Database types that should be processed by this image. Delimited by comma's.
ENV DB_TYPES swissprot
# Database URLs that should be downloaded and processed by this container. Delimited by comma's, n'th item in this list
# should correspond to n'th db type given in DB_TYPES arg.
ENV DB_SOURCES https://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.xml.gz
# List of taxa (separated by comma's) for which all children (and the nodes themselves) should be present in the final
# database.
ENV FILTER_TAXA 9682
