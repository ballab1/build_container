#!/bin/bash

chmod a+rwX /opt

declare -i org_gid=$(getent group docker | cut -d: -f3)
if [ ${DOCKER_GID:-} ] && [ $DOCKER_GID -ne $org_gid ]; then
    sudo groupmod -o -g $DOCKER_GID docker
    sudo usermod -a -G $DOCKER_GID builder
    sudo find / -mount -gid $org_gid -exec chgrp $DOCKER_GID '{}' \;
fi
