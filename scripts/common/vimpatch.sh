#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

getopt=${getopt:-getopt}
help=${help-}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog -h"
    echo "   or: $prog <file> <patch>"
}
error() {
    echo "error: $@" >&2
}
warn() {
    echo "warn: $@" >&2
}
die() {
    error "$@"
    exit 1
}
have() {
    type -- "$@" >/dev/null 2>&1
}
# usage: abspath <path> <cwd>
abspath() {
    case "$1" in
    /*) echo "$1" ;;
    *) echo "$2/$1" ;;
    esac
}

main() {
    if have getopt ; then
        opts=$("$getopt" -n "$prog" -o "h" -- "$@")
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h)
                help=1
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
    if test $# -ne 2 ; then
        usage >&2
        die "Must give only 2 arguments, <file> and <patch>."
    fi

    filename=$1
    patchfile=$(abspath "$2" "$(pwd)")
    vim "$filename" '+vert diffpatch '"$patchfile"
}
main "$@"
