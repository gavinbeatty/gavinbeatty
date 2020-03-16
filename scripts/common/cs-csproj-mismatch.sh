#!/bin/sh
# vi: set ft=sh sw=2 ts=2 et:
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ' TERM
say() { printf %s\\n "$*" ; }
die() { say "$*" >&2 ; exit 1 ; }
usage() { say "usage: cs-csproj-mismatch.sh <csproj>..." ; }
csproj_listed() {
  if git ls-files -- "$1" >/dev/null 2>/dev/null ; then
    sed -n 's/.*<Compile\s\s*Include="\([^"]*\.cs\)"[ \/]*>/\1/p' "$1" | sed -e 's#\\#/#g' | sort
  else
    sed -n 's/.*<Compile\s\s*Include="\([^"]*\.cs\)"[ \/]*>/\1/p' "$1" | sed -e 's#^#./#' -e 's#\\#/#g' | sort
  fi
}
csproj_inferred() {
  local dir="$(dirname "$1")"
  if git ls-files -- "$1" >/dev/null 2>/dev/null ; then
    (cd "$dir" && git grep --untracked --no-exclude-standard -Fle '' | grep '\.cs$' | sort)
  else
    (cd "$dir" && find . -name '*.cs' -a '!' -name 'TemporaryGeneratedFile_*.cs' | sort)
  fi
}
csproj_go() {
  listedpath="$(mktemp /tmp/cs-csproj-mismatch.listed.XXXXXX)"
  inferredpath="$(mktemp /tmp/cs-csproj-mismatch.inferred.XXXXXX)"
  diecleanup() { rm -f "$listedpath" "$inferredpath" ; die "died on $csproj" ; }
  trap diecleanup 0
  csproj_listed "$csproj" > "$listedpath"
  csproj_inferred "$csproj" > "$inferredpath"
  ${DIFF:-diff -u} --label "$csproj listed" --label "$csproj inferred" "$listedpath" "$inferredpath" || true
  rm -f "$listedpath" "$inferredpath"
  trap '' 0
}
main() {
  test $# -gt 0 || die "$(usage)"
  if test $# -eq 1 && test "$1" = . ; then
    git grep -Fle '<Compile Include='
  else
    for csproj in "$@" ; do
      csproj_go "$csproj"
    done
  fi
}
main "$@"
