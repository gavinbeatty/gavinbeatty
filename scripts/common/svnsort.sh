#!/bin/sh
# vi: set ft=sh et ts=2 sw=2:
# Like svnlist.sh, except it sorts everything, youngest URL to oldest.
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
prog="$(basename "$0")"
say() { printf "%s\n" "$*" ; }
usage() { say "usage: $prog [<svnlist-options>] [<svnlist-arguments>]" ; }
ishelp() { case "$1" in -h|-\?|--help) return 0 ;; esac ; return 1 ; }
if test $# -ne 0 && ishelp "$1" ; then
  usage
  exit 0
fi
svnlist.sh -f "$@" | xargs -L1 sh -c 'printf "%d %s\n" "$(svnlastcommit.sh "$0")" "$0"' | sort -n | cut -d' ' -f2-
