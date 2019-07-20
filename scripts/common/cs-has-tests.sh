#!/bin/sh
# vi: set ft=sh sw=2 ts=2 et:
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ' TERM
say() { printf %s\\n "$*" ; }

is_interface_only() {
  local dir="$(dirname "$1")"
  local baseofdir="$(basename "${dir:-.}")"
  test "$baseofdir" = Interfaces
}
is_tests() {
  local dir="$(dirname "$1")"
  local baseofdir="$(basename "${dir:-.}")"
  if test "$baseofdir" = Tests ; then
    return 0
  fi
  basename "$1" | grep -q 'Tests\.cs$'
}
cs_has_tests() {
  local base="$(basename "$1")"
  local dir="$(dirname "$1")"
  dir="${dir:-.}"
  local basenoext="${base%%.cs}"
  local expected="${dir}/Tests/${basenoext}Tests.cs"
  if test -r "$expected" ; then
    return 0
  fi
  say "$expected"
  if test "$basenoext" = "$base" ; then
    return 2
  fi
  return 1
}

ret=0
for i in "$@" ; do
  if is_interface_only "$i" || is_tests "$i" ; then
    continue
  fi
  if ! expected="$(cs_has_tests "$i")" ; then
    say "$i does not have tests in ${expected}."
    ret=1
  fi
done
exit $ret
