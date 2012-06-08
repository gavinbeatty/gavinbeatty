#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
# Unknown License - found without attached License information
# Unknown Author - found without attached Author or Copyright information
# Modified by Gavin Beatty <gavinbeatty@gmail.com>
## Runs ./configure and calculates dependencies for deb packaging.
set -e
set -u

prog="$(basename -- "$0")"
getopt="${getopt-getopt}"
have() { type "$@" >/dev/null 2>&1 ; }

sep=
missing=
for i in strace tmpfile.sh perl dpkg ; do
    have "$i" || { missing="${missing}${sep}$i" ; sep=", " ; }
done
if test -n "$missing" ; then
    echo "error: Please install: $missing" >&2
    exit 1
fi

tmpfile=

cleanup() {
    if test -f "${tmpfile-}" ; then rm -- "$tmpfile" ; fi
    return 0
}


main() {
    if have "$getopt" ; then
        opts="$("$getopt" -n "${prog}" -o "hv" -- "$@")"
        eval set -- "$opts"

        while true ; do
            case "$1" in
            -h) help ; exit 0 ; ;;
            --) shift ; break ; ;;
            *) echo "error: Unknown option $1" >&2 ; exit 1 ; ;;
            esac
            shift
        done
    else
        if test $# -eq 2 ; then
            if test x"$1" != x"--" ; then configure="$1"
            elif test x"$2" != x"--" ; then configure="$2"
            else configure="$2" ; fi
        elif test $# -eq 0 ; then configure="./configure"
        elif test $# -eq 1 ; then configure="$1"
        elif test $# -gt 2 ; then
            echo "error: Expected zero or one <configure> argument" >&2
            echo "usage: $(basename -- "$0") [--] [<configure>]" >&2
            exit 1
        fi
    fi
    if test $# -eq 0 ; then configure="./configure" ; fi

    tmpfile="$(tmpfile.sh -p "${TMPDIR-/tmp}/log-")"
    strace -f -o "$tmpfile" -- "$configure"
    # or make instead of ./configure, if the package doesn't use autoconf
    for x in $(dpkg -S $(grep open "$tmpfile" \
      | perl -pe 's!.* open\(\"([^\"]*).*!$1!' \
      | grep "^/"| sort | uniq \
      | grep -v "^\(/tmp\|/dev\|/proc\)" ) 2>/dev/null \
      | cut -f1 -d":"| sort -u) ; do
        printf "$x (>=" $(dpkg -s $x|grep ^Version|cut -f2 -d":") "), "
    done
    echo
}
trap " echo Caught SIGINT >&2 ; exit 1 " INT
trap " echo Caught SIGTERM >&2 ; exit 1 " TERM
trap "cleanup" 0
main "$@"
