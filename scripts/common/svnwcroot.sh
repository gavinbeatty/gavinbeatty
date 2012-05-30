#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

# Gives an absolute path to the root of the working copy directory for an svn
# repository.

SVN_EXE=${SVN_EXE-svn} ; export SVN_EXE
getopt=${getopt-getopt}
help=${help-}
verbose=${verbose-0}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-h] [-v]"
}
error() { echo "error: $@" >&2 ; }
warn() { echo "warn: $@" >&2 ; }
#usage: verbose <level> <msg>...
verbose() {
    if test $verbose -ge "$1" ; then
        shift
        echo "verbose: $@" >&2
    fi
}
die() { error "$@" ; exit 1 ; }
have() { type -- "$@" >/dev/null 2>&1 ; }

main() {
    if have getopt ; then
        e=0
        opts="$("$getopt" -n "$prog" -o "hv" -- "$@")" || e=$?
        test $e -eq 0 || exit 1
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
            -h) help=1 ; ;;
            -v) verbose=$(( $verbose + 1 )) ; ;;
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
    anyerr=0
    for i in "$@" ; do
        if ! wc="$(LC_ALL=C ${SVN_EXE} info "$i" | sed -n 's/^Working Copy Root Path: //p')" ; then
            continue
        fi
        if test -z "$wc" ; then
            anyerr=1
            error "\`${SVN_EXE} info\` does not have \"Working Copy Root Path\" field for $i"
        else
            echo "$wc"
        fi
    done
    exit $anyerr
}
main "$@"
