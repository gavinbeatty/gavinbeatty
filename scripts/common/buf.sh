#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
prog="$(basename -- "$0")"
getopt="${getopt-getopt}"
verbose="${verbose-0}"
dryrun="${dryrun-}"
echodo="${echodo-}"
stdin="${stdin-}"
file="${file-}"
sel="${sel-p}" # primary is default
clear="${clear:-}"

usage() {
	echo "usage: $prog [-h] [-vqn] [-p|-b] [-c|-i|-f <file>]"
}
error() { echo "error: $@" >&2 ; }
warn() { echo "warn: $@" >&2 ; }
die() { error "$@" ; exit 1 ; }
have() { type "$@" >/dev/null 2>&1 ; }
echodo() { echo "$@" ; "$@" ; }

main() {
	if have getopt ; then
		opts=$("$getopt" -n "$prog" -o "hpbcvqnif:" -- "$@")
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
            -h) usage ; exit 0 ; ;;
            -p) sel=p ; ;;
            -b) sel=b ; ;;
            -c) clear=1 ; ;;
            -v) verbose=1 ; echodo="echodo" ; ;;
            -q) verbose=0 ; echodo="" ; ;;
            -n) dryrun=1 ; verbose=1 ; echodo="echo" ; ;;
            -i) stdin=1 ; ;;
            -f) file="$2" ; shift ; ;;
            --) shift ; break ; ;;
            *) die "Unknown option: $1" ; ;;
            esac
            shift
        done
    fi
    test -n "$dryrun" && echodo="echo"

    case "$sel" in
    b|p) ;;
    *) die "Unknown sel=$sel" ; ;;
    esac

    cif=0
    test -n "$clear" && cif=$(( cif + 1 ))
    test -n "$stdin" && cif=$(( cif + 1 ))
    test -n "$file" && cif=$(( cif + 1 ))
    case "$cif" in
    0) stdin=1 ; ;; # stdin by default
    1) ;; # fine
    2|3) die "Must give only one of -i, -f <file> and -c" ; ;;
    *) die "Assertion cif" ; ;;
    esac

    if have xsel ; then
        if test -n "$file" ; then
            if test "$verbose" -gt 0 ; then
                echo xsel -"$sel"i \< "$file"
            fi
            if test -z "$dryrun" ; then
                xsel -"$sel"i < "$file"
            fi
        else
            opt=
            if test -n "$stdin" ; then opt="i"
            elif test -n "$clear" ; then opt="c"
            fi
            $echodo xsel -"$sel"$opt
        fi
    elif have pbcopy ; then
        die "XXX no pbcopy implementation"
    else
        die "no underlying implementation found"
    fi
}
main "$@"
