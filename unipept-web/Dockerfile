FROM ruby:2.7.5-bullseye

###
# Name: unipept-web
#
# This Dockerfile can be used to build an image that contains all required configuration to start up a Unipept web
# server that can handle all requests compatible with the Unipept API. Note that a valid unipept-database should be
# running at the same time as this container. This container queries the MySQL-database running in this separate 
# VM.
#
# Parameters:
#   N/A
#
# Mount-points:
#   N/A
###

LABEL maintainer="Pieter Verschaffelt <pieter.verschaffelt@ugent.be>"

EXPOSE 3000

# This container starts a web server for the Unipept application. The application will connect to the Docker database
# container that's currently running and expose all files available in there to the user in the form of an HTTP API
# (REST).

# First install all required dependencies for the web app to run.
RUN apt-get update && apt-get -y install git procps nodejs dos2unix

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/unipept/unipept.git
RUN cd unipept && git checkout master && gem install bundler
RUN cd unipept && bundle install
RUN cd unipept/config && sed -i "s/host: 127.0.0.1/host: host.docker.internal/" database.yml

CMD cd unipept && bundle exec rails server -b 0.0.0.0