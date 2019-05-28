#!/bin/bash

#----------------------------------------------------------------------------------------------
function my.usage()
{
    local -i exit_status=${1:-1}

    cat >&2 << EOF
Usage:
    $progname [ -h | --help ]
              [ -f | --force ]
              [ -c | --console ]
              [ --logdir <logDir> ]
              [ -l | --logfile <logName> ]
              [ -o | --os <osName> ]
              [ -p | --push ]
              [ <repoName> <repoName> <repoName> ]

    Common options:
        -h --help                  Display a basic set of usage instructions
        -c --console               log build info to conolse : default is to log to logdir and just display summary on cpnsole
        -f --force                 force build : do not check if fingerprint exists locally or in registry
           --logdir                log directory. If not specified, defalts to
        -l --logfile <logName>     log build results to <logName>. Defaults to build.YYYYMMDDhhmmss.log
        -o --os <osName>           specify OS <osName> that will be used. Default all OS types defined
        -p --push                  always push image to regitry

    build one or more component repos

EOF
    exit "$exit_status"
}

#----------------------------------------------------------------------------------------------
function my.cmdLineArgs()
{
    local base="${1:?}"
    shift
    local usage='my.usage'

    # Parse command-line options into above variable
    local -r progname="$( basename "${BASH_SOURCE[0]}" )"
    local -r options=$(getopt --longoptions "help,Help,HELP,console,force,logdir:,logfile:,push,os:" --options "Hhcfl:po:" --name "$progname" -- "$@") || "$usage" $?
    eval set -- "$options"

    local -A opts=()
    opts['base']="$(readlink -f "$base")"
    opts['logdir']="${opts['base']}/logs"
    opts['logfile']="logs/build.$(date +"%Y%m%d%H%M%S").log"
    opts['conlog']=0

    while true; do
        case "${1:-}" in
            -h|--h|--help|-help)  "$usage" 1;;
            -H|--H|--HELP|-HELP)  "$usage" 1;;
            --Help|-Help)         "$usage" 1;;
            -c|--c|--console)     opts['console']=1; shift 1;;
               --logdir)          opts['logdir']="$2"; shift 2;;
            -l|--l|--logfile)     opts['logfile']="$2"; shift 2;;
            -o|--o|--os)          opts['os']="$2"; shift 2;;
            -f|--f|--force)       opts['force']=1; shift 1;;
            -p|--p|--push)        opts['push']=1; shift 1;;
            --)                   shift; break;;
        esac
    done

    appenv.results "$@"
}

#----------------------------------------------------------------------------------------------

declare -i status
declare -a args
declare fn=build.wrapper

declare loader="$(dirname "${BASH_SOURCE[0]}")/libs/appenv.bashlib"
if [ ! -e "$loader" ]; then
    echo 'Unable to load libraries'
    exit 1
fi
source "$loader"
appenv.loader "$fn"

args=$( my.cmdLineArgs "$TOP" "$@" ) && status=$? || status=$?
[ $status -eq 0 ] || exit $status
"$fn" ${args[@]}
