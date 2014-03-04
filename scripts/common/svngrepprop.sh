#!/bin/sh
# vi: set ft=sh et sw=2 ts=2:
set -e
set -u
usage() { printf "usage: %s [-m|-0|-q] [--] <property> <path|url> <grepargs>...\n" "$(basename "$0")" ; }
SVN_EXE="${SVN_EXE:-svn}"
GREP_EXE="${GREP_EXE:-grep}"
lf=
quiet=
if test $# -gt 0 ; then
  if test "$1" = "--" ; then shift
  elif test "$1" = "-m" ; then lf="\n" ; shift
  elif test "$1" = "-0" ; then lf="\0" ; shift
  elif test "$1" = "-q" ; then quiet=1 ; shift
  fi
fi
if test $# -lt 3 ; then usage >&2 ; exit 1 ; fi
prop="$1"
path="$2"
shift 2
e=0
matches="$($SVN_EXE pg "$prop" "$path" | $GREP_EXE "$@")" || e=$?
if test -n "$quiet" ; then exit $e ; fi
if test -n "$matches" ; then
  if test -n "$lf" ; then printf "%s%s" "$path" "$lf"
  else printf "%s\n" "$matches" ; fi
fi
