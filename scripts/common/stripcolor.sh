#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

prog="$(basename -- "$0")"
usage() {
	echo "usage: $prog [<file>]"
}
die() { echo "error: $@" >&2 ; exit 1 ; }

main() {
    f="-"
    if test $# -eq 1 ; then
        f="$1"
    elif test $# -gt 1 ; then
        usage >&2
        die "Must give one or zero arguments."
    fi
    cat -- "$f" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}
main "$@"
