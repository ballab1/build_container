#!/bin/bash

set -o errexit
set -o nounset
set -o verbose

declare -r TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
declare -ar args=( $@ )

# global exceptions
declare -i dying=0
declare -i pipe_error=0 

#----------------------------------------------------------------------------
# Exit on any error
function catch_error() {
    echo "ERROR: an unknown error occurred at ${BASH_SOURCE[0]}:${BASH_LINENO[0]}" >&2
}

#----------------------------------------------------------------------------
# Detect when build is aborted
function catch_int() {
    die "${BASH_SOURCE[0]} has been aborted with SIGINT (Ctrl-C)"
}

#----------------------------------------------------------------------------
function catch_pipe() {
    pipe_error+=1
    [[ $pipe_error -eq 1 ]] || return 0
    [[ $dying -eq 0 ]] || return 0
    die "${BASH_SOURCE[0]} has been aborted with SIGPIPE (broken pipe)"
}

#----------------------------------------------------------------------------
function die() {
    local status=$?
    [[ $status -ne 0 ]] || status=255
    dying+=1

    printf "%s\\n" "FATAL ERROR" "$@" >&2
    exit $status
} 

#----------------------------------------------------------------------------
function exit_fn() {
    docker-compose down
    for arg in ${args[*]}; do
        local file="$( basename "$arg" )" 
        [[ -e "../opt/$file" ]] && rm "../opt/$file"
    done
} 

#----------------------------------------------------------------------------
function copyFilesToMount() {
    for arg in ${args[*]}; do
        local file="$( basename "$arg" )" 
        [[ -e "../opt/$file" ]] && rm "../opt/$file"
        cp  "${arg}" "../opt/$file"
    done
} 

#----------------------------------------------------------------------------
function getBldCmd() {
    local -r bldcmd=$1
    [[ -z $bldcmd ]] && die "no command specified to execute"
    basename "$bldcmd" 
} 

#---------------------------------------------------------------------------------------------- 


cd "$TOOLS"
declare bldcmd="$( getBldCmd "${args[0]}" )"

trap 'exit_fn' EXIT

copyFilesToMount
docker-compose up -d --build
docker exec alpinefull "/opt/$bldcmd"

exit 0 
