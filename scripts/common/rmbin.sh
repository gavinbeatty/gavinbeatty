#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap 'echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap 'echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
if test $# -eq 0 ; then
    set -- .
fi
set -x
find "$@" -type d \( -name 'bin' -o -iname 'debug' -o -iname 'release' \) -prune -print0 | xargs -0 rm -r --
