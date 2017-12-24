#!/bin/sh

set -o errexit

if [ "$1" = 'alpinefull' ]; then
    sleep 86400
else
    exec $@
fi
