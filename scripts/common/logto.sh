#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

verbose=${verbose-0}
append=${append-}
ignore_interrupts=${ignore_interrupts-}
timestamp=${timestamp-}
dateformat=${dateformat-%Y%m%d-%H:%M:%S%:::z}
format=${format--%s}
logfile=${logfile-}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-h] [-a] [-i] [-t [-d <dateformat>]] -l <logfile> [--] <command> [<args>...]"
}
error() {
    echo "error: $@" >&2
}
verbose() {
    if test "$verbose" -ge "$1" ; then
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
        opts="$(getopt -n "$prog" -o "+hvl:aitd:f:" -- "$@")"
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h)
                usage
                exit 0
                ;;
            -v)
                verbose=1
                ;;
            -l)
                logfile=$2
                shift
                ;;
            -a)
                append=1
                ;;
            -i)
                ignore_interrupts=1
                ;;
            -t)
                timestamp=1
                ;;
            -d)
                timestamp=1
                dateformat=$2
                shift
                ;;
            -f)
                format=$2
                shift
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

    if test $# -eq 0 ; then
        usage >&2
        die "no <command> given"
    fi
    if test -z "$logfile" ; then
        usage >&2
        die "no -l <logfile> given"
    fi
    if test "$1" = "--" ; then
        shift
    fi
    if ! have "$1" ; then
        die "command \`$1' not found"
    fi

    if test -n "$timestamp" ; then
        date=$(printf -- "$format" "$(date "+$dateformat")")
        # insert $date before extension or at the end
        logfile=$(echo "$logfile" | perl -we \
            'while(<STDIN>){s/((\.[^.]+?)?)$/$ARGV[0]$1/;print;}' \
            -- "$date")
    fi

    teeargs=" "
    if test -n "$append" ; then
        teeargs="${teeargs}-a "
    fi
    if test -n "$ignore_interrupts" ; then
        teeargs="${teeargs}-i "
    fi
    # teeargs is always either " " or " $stuff "
    verbose 1 "command: $@ | tee${teeargs}$logfile"
    "$@" | tee${teeargs}"$logfile"
}
main "$@"
