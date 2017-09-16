#!/bin/bash

set -o errexit
set -o nounset

docker-compose build alpinefull
docker-compose up -d
docker exec -it alpinefull /opt/build_nagios.sh
docker-compose down
