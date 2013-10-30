#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

SVN_EXE=${SVN_EXE:-svn} ; export SVN_EXE
help=${help:-}
verbose=${verbose:-0}
getopt=${getopt:-getopt}
GREPOPTS=${GREPOPTS:-}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-h] [-v] <string> <filename>"
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

main() {
    if have getopt ; then
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
    if test $# -ne 2 ; then
        error "Must give a <string> and <filename>"
        usage >&2
        exit 1
    fi

    string="$1"
    filename="$2"
    if test -z "$string" ; then
        error "Must supply a non-empty <string>"
        exit 1
    fi
    if test -z "$filename" ; then
        error "Must supply a non-empty <filename>"
        exit 1
    fi

    # Get all svn revision numbers in which $filename
    # was involved, in ascending order.
    all_rev_nums="$($SVN_EXE log -- "$filename" \
        | grep -o -- '^r[0-9]\+' \
        | grep -o -- '[0-9]\+$' \
        | sort -n)"

    for revnum in $all_rev_nums ; do
        verbose 1 "Trying r$revnum"
        if $SVN_EXE cat -r"$revnum" -- "$filename" 2>/dev/null | grep -q $GREPOPTS -- "$string" ; then
            $SVN_EXE blame -r"$revnum" -- "$filename" 2>/dev/null | grep $GREPOPTS -- "$string"
            # Since they're in ascending order, we've found
            # the first one. So we can quit now.
            exit 0
        fi
    done

    # If we never found $string in any revision of $filename, return an error.
    exit 1
}
main "$@"
