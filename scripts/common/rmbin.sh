#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap 'echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap 'echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
prog="$(basename -- "$0")"
getopt=${GETOPT-getopt}
xargs="${XARGS:-}"
help=${RMBIN_HELP:-}
quiet=${RMBIN_QUIET:-}
variant=${RMBIN_VARIANT:-}
symlinks="${RMBIN_SYMLINKS:--L}"
have() { type "$@" >/dev/null 2>&1 ; }
die() { echo "error: $@" ; exit 1 ; }
usage() {
    cat <<EOF
usage: $prog -h
   or: $prog [-b <variant>] [-q] [-L|-P|-H|-D] [<directory>]
EOF
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -a -b -c -c >/dev/null 2>&1
}
main() {
    if getopt_works ; then
        opts="$("$getopt" -n "$prog" -o "hqb:LPHD" -- "$@")"
        eval set -- "$opts"

        while test $# -gt 0 ; do
			case "$1" in
            -h) help=1 ;;
            -q) quiet=1 ;;
            -b) variant=$2 ; shift ;;
            -L) symlinks="-L" ;;
            -P) symlinks="-P" ;;
            -H) symlinks="-H" ;;
            -D) symlinks="" ;;
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
    if test -z "$xargs" ; then
        xargs=xargs
        ! have gxargs || xargs=gxargs
        have "$xargs" || die "Unable to find $xargs"
    fi
    if test "$symlinks" = "-D" ; then
        symlinks=""
    fi

    if test $# -eq 0 ; then
        set -- .
    fi
    sh='just() { "$@" ; } ; echodo() { echo "$@" ; "$@" ; } ; for i in "$@" ; do if ! echo "$i" | grep -q "/x_\(boost\|xerces\|google\|gmock\|gtest\|protobuf\)" ; then "${0:-just}" rm -r -- "$i" ; fi ; done'
    do=echodo
    test -z "$quiet" || do=just
    if test -z "$variant" ; then
        test -n "$quiet" || set -x
        find $symlinks "$@" -type d \( -name 'bin' -o -name 'bin.v2' -o -iname 'debug' -o -iname 'release' \) -prune -print0 | $xargs -r0 sh -c "$sh" "$do"
    else
        test -n "$quiet" || set -x
        find $symlinks "$@" -type d -name "$variant" -prune -print0 | $xargs -r0 sh -c "$sh" "$do"
    fi
}
main "$@"
