#!/bin/sh
# vi: set ft=sh sw=2 ts=2 et:
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ' TERM
say() { printf %s\\n "$*" ; }

cat_without_bom() {
  # \xEF\xBB\xBF is the UTF-8 BOM. Bloody Microsoft.
  sed -e '1s/^\(\xEF\xBB\xBF\|\)//' "$1"
}
read_namespace() {
  cat_without_bom "$1" | sed -rn -e 's/^[[:space:]]*namespace[[:space:]]+([^{[:space:]]*).*/\1/p'
}
infer_namespace() {
  dirname "$1" | sed -e 's#^\./##' -e 's#/#.#g'
}
read_types() {
  sed -rne 's/^[[:space:]]*\b(public|internal)\b.*\b(interface|enum|class|struct)\b[[:space:]]+([[:alpha:][:digit:]_]*).*/\3/p' "$1"
}
infer_type() {
  local base="$(basename "$1")"
  local basenoext="${base%%.cs}"
  if test "$basenoext" != "$base" ; then
    say "$basenoext"
  fi
}

ret=0
for i in "$@" ; do
  actual_ns="$(read_namespace "$i")"
  inferred_ns="$(infer_namespace "$i")"
  if test -z "$actual_ns" ; then
    say "$i namespace not found but inferred ${inferred_ns}."
    ret=1
  elif test "$actual_ns" != "$inferred_ns" ; then
    say "$i namespace is $actual_ns but inferred ${inferred_ns}."
    ret=1
  fi
  types="$(read_types "$i")"
  inferred_type="$(infer_type "$i")"
  found=0
  for actual_type in $types ; do
    if test "$actual_type" = "$inferred_type" ; then
      found=1
    fi
  done
  if test "$found" -eq 0 ; then
    say "$i is missing type $inferred_type (found $(say $types | tr '\n' ' ' | sed '$s/ $//'))."
    ret=1
  fi
done
exit $ret
