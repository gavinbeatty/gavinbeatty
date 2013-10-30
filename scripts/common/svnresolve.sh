#!/bin/sh
# vi: set ft=sh et sw=2 ts=2:
set -e
set -u
die() { printf "%s\n" "$*" >&2 ; exit 1 ; }
usage() { printf "usage: %s <accept> [<path>...]\n" "$(basename "$0")" ; }
SVN_EXE="${SVN_EXE:-svn}"
accept="$1" ; shift
case "$accept" in
  w|work|wk|wkd|working) accept=working ;;
  b|base) accept=base ;;
  mc|minec|mconflict|mine-conflict) accept=mine-conflict ;;
  tc|theirsc|tconflict|theirs-conflict) accept=theirs-conflict ;;
  mf|minef|mfull|mine-full) accept=mine-full ;;
  tf|theirsf|tfull|theirs-full) accept=theirs-full ;;
  *) die "Invalid <accept>, $accept" ;;
esac
$SVN_EXE resolve --accept "$accept" "$@"
