#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:

# Gives an absolute path to the root of the working copy directory for a git
# repository.
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}
help=${help-}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-h]"
    echo "   or: $prog [<wcdir>...]"
}
error() { echo "error: $@" >&2 ; }
warn() { echo "warn: $@" >&2 ; }
die() { error "$@" ; exit 1 ; }
have() { type "$@" >/dev/null 2>&1 ; }

main() {
    if have getopt ; then
        e=0
        opts="$("$getopt" -n "$prog" -o "h" -- "$@")" || e=$?
        test $e -eq 0 || exit 1
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
            -h) help=1 ; ;;
            --) shift ; break ; ;;
            *) die "Unknown option: $1" ; ;;
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
    for i in "$@" ; do
        (cd -- "$i" && echo "$(pwd)/$(git rev-parse --show-cdup)" )
    done
}
main "$@"
