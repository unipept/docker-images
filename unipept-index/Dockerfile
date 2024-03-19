FROM ubuntu:latest

LABEL maintainer="Pieter Verschaffelt <pieter.verschaffelt@ugent.be>"

RUN apt update && \
    apt install -y \
    git \
    wget \
    unzip \
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
    lz4 \
    dos2unix \
    pkg-config \
    clang \
    cmake

RUN git clone --depth 1 https://github.com/unipept/unipept-database
# Use the webserver branch for now
RUN git clone --depth 1 -b webserver https://github.com/BramDevlaminck/Thesis_rust_implementations
# Initialize all submodules for the suffix array
RUN cd Thesis_rust_implementations && git submodule update --init --recursive

# Make a directory that contains the initialization data for this script
RUN mkdir "/scripts"
COPY "initialize_container.sh" "/scripts/initialize_container.sh"
# Make sure that this script is executable in the container
RUN chmod u+x "/scripts/initialize_container.sh"

# Install Rust toolchain (https://rustup.rs/)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH="/root/.cargo/bin:${PATH}"

# Compile Rust binaries for the database
RUN /unipept-database/scripts/build_binaries.sh

# Clean up database build artifacts so they don't end up in the image
RUN rm -rf /unipept-database/scripts/helper_scripts/unipept-database-rs/target/

# Compile Rust binaries for the unipept index
RUN cd /Thesis_rust_implementations && cargo build --release

# Uninstall Rust again to keep the image size down
RUN rustup self uninstall -y

# Database types that should be processed by this image. Delimited by comma's.
ENV DB_TYPES swissprot
# Database URLs that should be downloaded and processed by this container. Delimited by comma's, n'th item in this list
# should correspond to n'th db type given in DB_TYPES arg.
ENV DB_SOURCES https://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.dat.gz
# How much memory is the database construction script allowed to use for sorting?
ENV SORT_MEMORY 2G

# Start initialization of the index construction process once the container is constructed.
CMD "/scripts/initialize_container.sh"
