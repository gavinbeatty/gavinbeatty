#!/bin/sh
# vi: set ft=sh et sw=2 ts=2:
set -e
set -u
usage() { printf "usage: %s [-0] <property> <file>...\n" "$(basename "$0")" ; }
SVN_EXE="${SVN_EXE:-svn}"
lf="\n"
if test $# -gt 0 && test "$1" = "-0" ; then lf="\0" ; fi
if test $# -lt 2 ; then usage >&2 ; exit 1 ; fi
prop="$1" ; shift
for i in "$@" ; do
  if $SVN_EXE pl "$i" 2>/dev/null | grep -Fq "$prop" ; then
    printf "%s$lf" "$i"
  fi
done
