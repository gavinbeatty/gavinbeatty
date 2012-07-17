#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
if test $# -ne 0 ; then
    if test "$1" = "--" ; then shift ; fi
fi
if test $# -eq 0 ; then set -- .
elif test $# -gt 1 ; then
    echo "error: Must give one or zero path arguments." >&2
    exit 1
fi
(cd -- "$1" && git log -1  >/dev/null 2>&1)
