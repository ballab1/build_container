#!/bin/bash

declare -A builder=(
    ['user']=${BUILDER_USER:-builder}
    ['uid']=${BUILDER_UID:-$(builder.UID "${BUILDER_USER:-}")}
    ['group']=${BUILDER_GROUP:-builder}
    ['gid']=${BUILDER_GID:-$(builder.GID "${BUILDER_GROUP:-}")}
    ['shell']=/bin/bash
    ['home']="${BUILDER_HOME:-/home/builder}"
)
