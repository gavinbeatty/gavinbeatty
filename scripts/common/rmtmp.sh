#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
# Remove all the temporary files only in the specified
# directory, or if none specified, the current directory.
set -e
set -u
prog="$(basename -- "$0")"

have() { type -- "$@" >/dev/null 2>&1 ; }

getopt="${getopt-getopt}"
echodo="${echodo-}"
recursive="${recursive-}"

usage() { echo "usage: $prog [-h] [-v] [-n] [-r] [<dir>...]" ; }
main() {
    sep=
    missing=
    for i in xargscheck.sh find ; do
        if ! have "$i" ; then missing="${missing}${sep}$i" ; sep=", " ; fi
    done
    if test -n "$missing" ; then
        echo "error: Please install: $missing" >&2
        exit 1
    fi
    local xargsi=
    if xargscheck.sh -I 2>/dev/null ; then
        xargsi="-I{}"
    elif xargscheck.sh -i 2>/dev/null ; then
        xargsi="-i"
    else
        echo "error: Need a version of xargs that supports -i or -I{}" >&2
        exit 1
    fi
    local xargs0=
    if xargscheck.sh -0 2>/dev/null ; then
        xargs0="0" # tested with test -n, so it's true
    fi
    local xargsr=
    if xargscheck.sh -r 2>/dev/null ; then
        xargsr="-r"
    fi
    echodo=
    if have "$getopt" ; then
        opts="$("$getopt" -n "$prog" -o "hvnr" -- "$@")"
        eval set -- "$opts"

        while true ; do
            case "$1" in
            -h) usage ; exit 0 ; ;;
            -v) echodo="echodo.sh" ; ;;
            -n) echodo="shellquote" ; ;;
            -r) recursive=1 ; ;;
            --) shift ; break ; ;;
            *) error_unknownOpt "$1" ; ;;
            esac
            shift
        done
    fi
    if (test -n "$echodo") && (! have "$echodo") ; then
        echodo=
    fi
    depth="-maxdepth 1"
    if test -n "$recursive" ; then
        depth=
    fi

    if test $# -eq 0 ; then
        set -- .
    fi
    find "$@" $depth -name '*~' -print"$xargs0" 2>/dev/null \
      | xargs ${xargs0:+-0} ${xargsr} "$xargsi" $echodo rm -- '{}'
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
