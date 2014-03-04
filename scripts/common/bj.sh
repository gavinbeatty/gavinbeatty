#!/usr/bin/env bash
# vi: set ft=sh et ts=2 sw=2:
bj() {
  local b2="${B2:-}"
  b2="${b2:-$BJAM}"
  b2="${b2:-b2}"
  local testfile="${TMPDIR:-/tmp}/${EUID:-$(id -u)}-bj${RANDOM:-$(uuidgen)}"
  $b2 "-j${JCONC:-1}" --verbose-test "$@" 2>&1 | tee "$testfile"
  local e="${PIPESTATUS[0]}"
  cat  <<EOF
XXXXXXXXXXXXXXXXXXX
XXX TEST OUTPUT XXX
XXXXXXXXXXXXXXXXXXX
EOF
  local ge=0
  ${GREP:-grep} '^\(\*\*passed\*\*\|\.\.\.failed\|testing\..*\.passed$\)' "$testfile" || ge=$?
  case $ge in
    0|1) ;;
    *) return $ge ;;
  esac;
  rm "$testfile" || return $?;
  return $e
}
if test "$(basename "$0")" = "bj.sh" ; then
  set -e
  set -u
  trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
  trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
  bj "$@"
fi
