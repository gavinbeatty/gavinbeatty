#!/bin/sh
# vi: set expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}

help=${help-}
verbose=${verbose-0}
variant=${variant-}
symlinks="${symlinks--L}"

prog=$(basename -- "$0")
usage() {
    cat <<EOF
usage: $prog -h
   or: $prog [-b <variant>] [-v] [<directory>]
EOF
}
help() {
    cat <<EOF
EOF
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
    type -- "$@" >/dev/null 2>&1
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -a -b -c -c >/dev/null 2>&1
}

main() {
    if getopt_works ; then
        opts="$("$getopt" -n "$prog" -o "hvb:LPHD" -- "$@")"
        eval set -- "$opts"

        while test $# -gt 0 ; do
			case "$1" in
            -h) help=1 ; ;;
            -v) verbose=$(($verbose + 1)) ; ;;
            -b) variant=$2 ; shift ; ;;
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
    if test -z "$variant" ; then
        set -x
        find $symlinks "$@" \( -name 'bin' -o -iname 'release' -o -iname 'debug' \) -prune | $xargs -0r rm -r --
        exit 0
    else
        set -x
        find $symlinks "$@" -name "$variant" -prune | $xargs -r rm -r --
        exit 0
    fi
}
main "$@"
