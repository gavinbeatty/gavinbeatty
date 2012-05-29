#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
prog="$(basename -- "$0")"
usage() { echo "$prog [<makefile>]" ; }
die() { echo "error: $@" >&2 ; exit 1 ; }
main() {
    if test $# -eq 0 ; then
        set -- Makefile
    elif test $# -ne 1 ; then
        die "Must give zero or one <makefile> arguments."
    fi
    if ! test -r "$1" ; then
        die "<makefile> argument, $1 is not readable."
    fi
    if ! test -f "$1" ; then
        die "<makefile> argument, $1 is not a file."
    fi
    grep -hE -- '^[^#%=$[:space:]][^#%=$]*:([^=]|$)' "$1" \
      | cut -d ":" -f 1 \
      | sed -e 's/^ *//;s/ *$//;s/  */\n/g' \
      | grep -v '^\.PHONY$' \
      | grep -v '^\.SUFFIXES$' \
        2>/dev/null
}
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
main "$@"
