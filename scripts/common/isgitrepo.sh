#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
git="${GIT:-git}"
if test $# -eq 2 ; then
    if test "$1" = "--" ; then
        shift
    fi
fi
test $# -ne 0 || set -- .
if test $# -gt 1 ; then
    echo "Must give zero or one <path> arguments." >&2 ; exit 1
fi
(if cd -- "$1" ; then exec $git log -1 >/dev/null 2>&1 ; else echo "$1 is inaccessible." >&2 ; fi)
exit 1
