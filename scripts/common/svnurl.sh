#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
SVN_EXE="${SVN_EXE:-svn}"
AWK="${AWK:-awk}"
if test $# -gt 0 ; then
    if test "$1" = "--" ; then
        shift
    fi
fi
if test $# -eq 0 ; then set -- . ; fi
if test $# -gt 1 ; then
    echo "error: Expected zero or one <path> argument(s)." >&2
    echo "usage: $(basename -- "$0") [--] [<path>]" >&2
    exit 1
fi
if info="$(LC_ALL=C ${SVN_EXE} info -- "$1" 2>/dev/null)" ; then
    echo "$info" | LC_ALL=C ${AWK} 'BEGIN {FS=": " } /^URL: / {print $2}'
else
    echo "error: $1 is an invalid <path>" >&2
    echo "usage: $(basename -- "$0") [--] [<path>]" >&2
    exit 1
fi
