#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
prog="$(basename -- "$0")"
have() { type "$@" >/dev/null 2>&1 ; }
usage() { echo "usage: ${prog} [--] <path>" ; }
die() { echo "error: $@" >&2 ; exit 1 ; }
main() {
    if test $# -eq 2 ; then
        if test "$1" = "--" ; then
            shift
        fi
    fi
    test $# -ne 0 || set -- .
    if test $# -ne 1 ; then
        die "Must give zero or one <path> arguments."
    fi
    exec svn info -- "$1" 2>/dev/null 1>/dev/null
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
