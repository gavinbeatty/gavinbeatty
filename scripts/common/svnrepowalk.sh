#!/bin/sh
# vi: set ft=sh et ts=2 sw=2:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
say() { printf "%s\n" "$*" ; }
usage() { printf "usage: %s [-d] [<url|path>] <command>...\n" "$(basename "$0")" >&2 ; }
SVN_EXE="${SVN_EXE:-svn}"
svnurl() {
  local info=
  if info="$(LC_ALL=C $SVN_EXE info -- "$1" 2>/dev/null)" ; then
    echo "$info" | LC_ALL=C awk 'BEGIN {FS=": " } /^URL: / {print $2}'
  else
    printf "error: %s is an invalid <url|path>\n" "$1" >&2
    usage >&2
    exit 1
  fi
}
explore() {
  local url="$1" ; shift
  local u=
  debug "${url%%/}"
  $SVN_EXE ls "$url" | while read u ; do
    if "$@" "${url}/${u%%/}" && say "$u" | grep -q '/$' ; then
      explore "${url}/${u%%/}" "$@"
    fi
  done
}
debug() { true ; }
if test $# -gt 0 && test "$1" = "-d" ; then
  debug() { say "$@" >> "$(basename "$0").log" ; }
  shift
fi
if test $# -eq 0 ; then
  set -- . say
elif test $# -eq 1 ; then
  set -- "$1" say
fi
url="$(svnurl "$1")"
shift
if "$@" "${url%%/}" ; then
  explore "$url" "$@"
fi
