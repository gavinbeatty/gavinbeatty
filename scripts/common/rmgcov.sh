#!/bin/sh
# vi: set expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}

help=${help-}
verbose=${verbose-0}
symlinks="${symlinks--L}"

prog=$(basename -- "$0")
usage() {
   echo "$prog [-v] [-L|-H|-P|-D] [<directory>...]"
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
getopt_works() {
    eval set -- "$("$getopt" -n "test" -o "ab:c" -- -a yah -b -c -b \'\  -c nay 2>&1)"
    if test $# -ne 9 ; then return 1
    else
        if test "$1" != "-a" ; then return 1
        elif test "$2" != "-b" ; then return 1
        elif test "$3" != "-c" ; then return 1
        elif test "$4" != "-b" ; then return 1
        elif test "$5" != "' " ; then return 1
        elif test "$6" != "-c" ; then return 1
        elif test "$7" != "--" ; then return 1
        elif test "$8" != "yah" ; then return 1
        elif test "$9" != "nay" ; then return 1
        else return 0 ; fi
    fi
}
get_xargs() {
    if test -z "$xargs" ; then
        xargs=xargs
        ! have gxargs || xargs=gxargs
        have "$xargs" || die "Unable to find $xargs"
    fi
}

main() {
    if getopt_works ; then
        opts="$("$getopt" -n "$prog" -o "hvb:LHPD" -- "$@")"
        eval set -- "$opts"

        while test $# -gt 0 ; do
			case "$1" in
            -h) help=1 ; ;;
            -v) verbose=$(( $verbose + 1 )) ; ;;
            -L) symlinks="-L" ; ;;
            -P) symlinks="-P" ; ;;
            -H) symlinks="-H" ; ;;
            -D) symlinks="" ; ;;
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
        eval set -- .
    fi
    get_xargs
    set -x
    find $symlinks "$@" \( -type f -a \( -name '*.gcda' -o -name 'tracefile' \) \) -print0 | $xargs -r0 rm --
    exit 0
}
main "$@"
