# Unipept - Docker images
This repository contains a collection of Docker images that are used by various components of the Unipept ecosystem. See below for an explanation of what each of these containers does and what they can be used for. All of these images can be pulled from the Docker Hub and will be updated regularly.

## unipept-database
### Overview
This image can be used to filter UniProt-entries from both SwissProt and Trembl and to build a MySQL-database from the resulting information. This image is used by the Unipept Desktop app and makes it possible for this application to offer local analyses and analyses supported by custom, targetted databases.

### Building this database
```
# In the root folder where this Dockerfile resides, perform the following command.
# The version number should always be incremented according to the semver policy.
$ docker build -t unipept/unipept-database:1.0.0 .
```

### Version history

#### unipept/unipept-database:1.0.0
Initial release.

## unipept-web
This image can be used to start an instance of the Unipept API that automatically connects to a valid Unipept database server that's listening on port 3306 (the default MySQL-port). This image is also being used by the Unipept Desktop app and powers it's local and targetted protein analyses.

```
# In the root folder where the Dockerfile for the unipept-web image resides, perform the following command.
$ docker build -t unipept/unipept-web:1.0.0
```

### Version history

#### unipept/unipept-web:1.0.0
Initial release.
