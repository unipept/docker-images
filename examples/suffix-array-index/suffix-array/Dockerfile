FROM ubuntu:latest

RUN apt update && \
    apt install -y \
    git \
    curl \
    sudo \
    lz4 \
    binutils \
    gcc \
    libssl-dev \
    uuid-runtime \
    curl \
    sudo \
    lz4 \
    pkg-config \
    clang \
    cmake

# RUN git clone --depth 1 -b feature/sa-compression https://github.com/unipept/unipept-index
COPY "unipept-index" "/unipept-index"
# Initialize all submodules for the suffix array
RUN cd unipept-index && git submodule update --init --recursive

# Make a directory that contains the initialization data for this script
RUN mkdir "/scripts"
COPY "entrypoint.sh" "/scripts/entrypoint.sh"
# Make sure that this script is executable in the container
RUN chmod u+x "/scripts/entrypoint.sh"

# Install Rust toolchain (https://rustup.rs/)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH="/root/.cargo/bin:${PATH}"

# Compile Rust binaries for the unipept index
RUN cd /unipept-index && cargo build --release

# Uninstall Rust again to keep the image size down
RUN rustup self uninstall -y

# Start initialization of the index construction process once the container is constructed.
CMD "/scripts/entrypoint.sh"
