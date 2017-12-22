#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose

declare -r BUILDTIME_PKGS="alpine-sdk busybox curl findutils freetype gd git libpng libxml2-dev linux-headers jpeg mysql perl perl-plack rsync zlib"
declare -r CORE_PKGS="bash bash-completion coreutils openssh-client shadow supervisor ttf-dejavu unzip"
declare -r NAGIOS_PKGS="busybox rsync perl gd zlib libpng jpeg freetype mysql perl-plack"
declare -r OTHER_PKGS="gd-dev libpng-dev jpeg-dev"    

declare -r TZ=${TZ:-'America/New_York'}
declare TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  


# global exceptions
declare -i dying=0
declare -i pipe_error=0


#----------------------------------------------------------------------------
# Exit on any error
function catch_error() {
    echo "ERROR: an unknown error occurred at $BASH_SOURCE:$BASH_LINENO" >&2
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

    printf "%s\n" "FATAL ERROR" "$@" >&2
    exit $status
}  

#############################################################################
function cleanup()
{
    printf "\nclean up\n"
    apk del .buildDepedencies
}
 
#############################################################################
function installAlpinePackages() {
    apk update
    apk add --no-cache $CORE_PKGS $OTHER_PKGS
    apk add --no-cache --virtual .buildDepedencies $BUILDTIME_PKGS
}

#############################################################################
function installTimezone() {
    echo "$TZ" > /etc/TZ
    cp /usr/share/zoneinfo/$TZ /etc/timezone
    cp /usr/share/zoneinfo/$TZ /etc/localtime
}

#############################################################################
function install_CUSTOMIZATIONS()
{
    printf "\nAdd configuration and customizations\n"
    cp -r "${TOOLS}/usr"/* /usr
    ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh
}


#############################################################################
function setPermissions()
{
    printf "\nmake sure that ownership & permissions are correct\n"

    chmod u+rwx /usr/local/bin/docker-entrypoint.sh
}


#############################################################################

trap catch_error ERR
trap catch_int INT
trap catch_pipe PIPE 

set -o verbose

installAlpinePackages
installTimezone 
install_CUSTOMIZATIONS
setPermissions
cleanup
exit 0 