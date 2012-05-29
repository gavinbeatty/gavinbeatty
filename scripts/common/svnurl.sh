#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
if test $# -eq 2 ; then
    if test x"$1" != x"--" ; then path="$1"
    elif test x"$2" != x"--" ; then path="$2"
    else path="$2" ; fi
elif test $# -eq 0 ; then path="."
elif test $# -eq 1 ; then path="$1"
elif test $# -gt 2 ; then
    echo "error: Expected zero or one <path> argument" >&2
    echo "usage: $(basename -- "$0") [--] [<path>]" >&2
    exit 1
fi
if info="$(svn info -- "$path" 2>/dev/null)" ; then
    echo "$info" | awk 'BEGIN {FS=": " } /^URL: / {print $2}'
else
    echo "error: $path is an invalid <path>" >&2
    exit 1
fi
