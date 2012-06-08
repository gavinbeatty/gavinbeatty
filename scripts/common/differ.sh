#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}
help=${help-}
verbose=${verbose-0}
noprint=${noprint-}
inplace=${inplace-}
perlcode=${perlcode-}
awkcode=${awkcode-}
sedcode=${sedcode-}
perl=${perl-perl}
awk=${awk-awk}
sed=${sed-sed}
diff=${diff-}
diffopts=${diffopts--u}
patch=${patch-patch}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-v] [-i] [-P] -p <perlcode> <infile>..."
    echo "   or: $prog [-v] [-i] -a <awkcode> <infile>..."
    echo "   or: $prog [-v] [-i] [-P] -s <sedcode> <infile>..."
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
have() { type "$@" >/dev/null 2>&1 ; }

main() {
    if have getopt ; then
        e=0
        opts="$("$getopt" -n "$prog" -o "hvip:a:s:P" -- "$@")" || e=$?
        test $e -eq 0 || exit 1
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
            -h) help=1 ;;
            -v) verbose=$(( $verbose + 1 )) ;;
            -i) inplace=1 ;;
            -p) perlcode="$2" ; shift ;;
            -a) awkcode="$2" ; shift ;;
            -s) sedcode="$2" ; shift ;;
            -P) noprint=1 ;;
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
    test $# -ge 1 || { usage >&2 ; die "Must give at least one <infile>" ; }
    filter=""
    test -z "$perlcode" || filter="${filter}1"
    test -z "$awkcode" || filter="${filter}1"
    test -z "$sedcode" || filter="${filter}1"
    if test "$filter" != "1" ; then
        usage >&2
        die "Must give only one of -p <perlcode>, -a <awkcode>, -s <sedcode>"
    fi
    if test -z "$diff" ; then
        e=0
        diff="$(which diff 2>/dev/null)" || e=$?
        test $e -eq 0 || { usage >&2 ; die "Error trying to find a diff program using which" ; }
    fi
    test -n "$diff" || { usage >&2 ; die "Unable to find a diff program using which" ; }
    if test -n "$perlcode" ; then
        print="print;"
        if test -n "$noprint" ; then
            print=""
        fi
        if test -n "$inplace" ; then
            test "$verbose" -lt 1 || set -x
            for infile in "$@" ; do
                $perl -we "open F,\$ARGV[0] or die \$!;while(<F>){${perlcode};${print}}" "$infile" | $diff ${diffopts} -- "$infile" - | $patch -p0
            done
        else
            test "$verbose" -lt 1 || set -x
            for infile in "$@" ; do
                $perl -we "open F,\$ARGV[0] or die \$!;while(<F>){${perlcode};${print}}" "$infile" | $diff ${diffopts} -- "$infile" -
            done
        fi
    elif test -n "$awkcode" ; then
        if test -n "$inplace" ; then
            test "$verbose" -lt 1 || set -x
            for infile in "$@" ; do
                cat -- "$infile" | $awk "{${awkcode};}" | $diff ${diffopts} -- "$infile" | $patch -p0
            done
        else
            test "$verbose" -lt 1 || set -x
            for infile in "$@" ; do
                cat -- "$infile" | $awk "{${awkcode};}" | $diff ${diffopts} -- "$infile"
            done
        fi
    elif test -n "$sedcode" ; then
        opt=""
        if test -n "$noprint" ; then
            opt="-n"
        fi
        if test -n "$inplace" ; then
            test "$verbose" -lt 1 || set -x
            for infile in "$@" ; do
                cat -- "$infile" | $sed $opt -- "$sedcode" | $diff ${diffopts} -- "$infile" | $patch -p0
            done
        else
            test "$verbose" -lt 1 || set -x
            for infile in "$@" ; do
                cat -- "$infile" | $sed $opt -- "$sedcode" | $diff ${diffopts} -- "$infile"
            done
        fi
    else
        usage >&2
        die "Must give only one of -p <perlcode>, -a <awkcode>, -s <sedcode>"
    fi
}
main "$@"
