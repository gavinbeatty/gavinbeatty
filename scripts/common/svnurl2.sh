#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

SVN_EXE=${SVN_EXE-svn} ; export SVN_EXE
getopt=${getopt:-getopt}
help=${help-}
verbose=${verbose-0}

prog=$(basename -- "$0")
usage() {
    echo "usage: $prog [-h] [-v] <path>..."
}
error() {
    echo "error: $@" >&2
}
warn() {
    echo "warn: $@" >&2
}
#usage: verbose <level> <msg>...
verbose() {
    if test $verbose -ge "$1" ; then
        shift
        echo "verbose: $@" >&2
    fi
}
die() {
    error "$@"
    exit 1
}
have() {
    type "$@" >/dev/null 2>&1
}
getopt_works() {
    "$getopt" -n "test" -o ab:c -- -a -b -c -c >/dev/null 2>&1
}

main() {
    if getopt_works ; then
        opts=$("$getopt" -n "$prog" -o "hv" -- "$@")
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h)
                help=1
                ;;
            -v)
                verbose=$(($verbose + 1))
                ;;
            --)
                shift
                break
                ;;
            *)
                die "Unknown option: $1"
                ;;
            esac
            shift
        done
    fi
    if test -n "$help" ; then
        usage
        exit 0
    fi

    if test $# -eq 0 ; then
        set -- .
    fi
    ret=0
    for i in "$@" ; do
        e=0
        info=$(LC_ALL=C ${SVN_EXE} info -- "$i") || e=$?
        if test $e -eq 0 ; then
            echo "$info" | sed -n 's/^URL: //p'
        else
            ret=1
        fi
    done
    exit $ret
}
main "$@"
