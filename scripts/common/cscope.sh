#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
prog="$(basename -- "$0")"
help="${CSCOPE_HELP:-}"
getopt="${CSCOPE_GETOPT:-getopt}"
allow_no_getopt="${CSCOPE_ALLOW_NO_GETOPT:-}"
cscope="${CSCOPE_CSCOPE:-cscope}"
verbose="${CSCOPE_VERBOSE:-0}"
files="${CSCOPE_FILES:-}"
reverse="${CSCOPE_REVERSE:-}"
echodo="${CSCOPE_ECHODO:-}"

have() { type "$@" >/dev/null 2>&1 ; }
usage() {
    echo "usage: $prog [-v] [-r] [-f <files>|<dir>]"
}
echodo() { echo "$@" ; "$@" ; }
warning() { echo "warning: $@" >&2 ; }
die() { echo "error: $@" >&2 ; exit 1 ; }

main() {
    if have "$getopt" ; then
        opts="$("$getopt" -n "$prog" -o "+hvrf:" -- "$@")"
        eval set -- "$opts"
        while true ; do
            case "$1" in
                -h) help=1 ;;
                -v) verbose=$(( $verbose + 1 ))
                    echodo="echodo"
                    ;;
                -r) reverse=1 ;;
                -f) files="$2" ; shift ;;
                --) shift ; break ;;
                *) usage >&2 ; exit 1 ;;
            esac
            shift
        done
    elif test -n "$allow_no_getopt" ; then
        warning "$getopt not found. Only taking options from the environment."
    else
        die "$getopt not found."
    fi
    test -z "$help" || { usage ; exit 0 ; }

    opts=""
    if test -n "$reverse" ; then
        opts="-q"
    fi
    if test -z "$files" ; then
        $echodo $cscope -b $opts -R
    else
        $echodo $cscope -b $opts -i "$files"
    fi
}
main "$@"
