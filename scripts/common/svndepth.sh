#!/bin/sh
# vi: set ft=sh et sw=2 ts=2:
set -e
set -u
die() { printf "%s\n" "$*" >&2 ; exit 1 ; }
usage() { printf "usage: %s [-0] <depth> [<directory>...]\n" "$(basename "$0")" ; }
SVN_EXE="${SVN_EXE:-svn}"
depth="$1" ; shift
case "$depth" in
  a|all|full|inf|infinite|infinity) depth=infinity ;;
  e|empty|none|no) depth=empty ;;
  f|files) depth=files ;;
  im|imm|immediate|immediates) depth=immediates ;;
  *) die "Invalid <depth>, $depth" ;;
esac
$SVN_EXE update --set-depth "$depth" "$@"
