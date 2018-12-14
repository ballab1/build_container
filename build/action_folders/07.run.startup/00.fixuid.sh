#!/bin/bash

usermod -G "$DOCKER_GROUP" -a builder
# if Docker socket exists, make sure we can access it
[ ! -S /var/run/docker.sock ] || chmod 666 /var/run/docker.sock
