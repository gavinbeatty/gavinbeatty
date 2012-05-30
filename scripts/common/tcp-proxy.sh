#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}
help=${help-}
verbose=${verbose-1}
dry_run=${dry_run-}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-h] [-n] [-v] [-q] <local_port> <remote_host> [<remote_port>]"
}
error() { echo "error: $@" >&2 ; }
warn() { echo "warn: $@" >&2 ; }
#usage: verbose <level> <msg>...
verbose() {
    if test $verbose -ge "$1" ; then
        shift
        echo "$@" >&2
    fi
}
die() { error "$@" ; exit 1 ; }
have() { type -- "$@" >/dev/null 2>&1 ; }
run() { test -n "$dry_run" || "$@" ; }

main() {
    if have getopt ; then
        e=0
        opts="$("$getopt" -n "$prog" -o "hvqn" -- "$@")" || e=$?
        test $e -eq 0 || exit 1
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
            -h) help=1 ;;
            -v) verbose=$(( $verbose + 1 )) ;;
            -q) verbose=$(( $verbose - 1 )) ;;
            -n) verbose=1 ; dry_run=1 ;;
            --) shift ; break ;;
            *) die "Unknown option: $1" ;;
            esac
            shift
        done
    fi
    if test -n "$help" ; then
        usage
        exit 0
    fi
    if (test $# -lt 2) || (test $# -gt 3) ; then
        usage >&2
        exit 1
    fi
    local_port="$1"
    remote_port="$1"
    remote_host="$2"
    if test $# -ge 3 ; then
        remote_port="$3"
    fi
    verbose 1 socat "tcp-listen:${local_port},fork" "tcp:${remote_host}:${remote_port}"
    run socat "tcp-listen:${local_port},fork" "tcp:${remote_host}:${remote_port}"
}
main "$@"
