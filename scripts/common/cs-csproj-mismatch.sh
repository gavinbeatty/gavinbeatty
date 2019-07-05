#!/bin/sh
# vi: set ft=sh sw=2 ts=2 et:
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ' TERM
say() { printf %s\\n "$*" ; }
die() { say "$*" >&2 ; exit 1 ; }
usage() { say "usage: cs-csproj-mismatch.sh <csproj>" ; }
csproj_listed() { sed -n 's/.*<Compile\s\s*Include="\([^"]*\.cs\)"[ \/]*>/\1/p' "$1" | sed -e 's#^#./#' -e 's#\\#/#g' | sort ; }
csproj_inferred() {
  local dir="$(dirname "$1")"
  (cd "$dir" && find . -name '*.cs' -a '!' -name 'TemporaryGeneratedFile_*.cs' | sort)
}

test $# -eq 1 || die "$(usage)"
csproj="$1"
listedpath="$(mktemp /tmp/cs-csproj-mismatch.listed.XXXXXX)"
inferredpath="$(mktemp /tmp/cs-csproj-mismatch.inferred.XXXXXX)"
cleanup() { rm -f "$listedpath" "$inferredpath" ; }
trap cleanup 0
csproj_listed "$csproj" > "$listedpath"
csproj_inferred "$csproj" > "$inferredpath"
${DIFF:-diff -u} --label "$csproj listed" --label "$csproj inferred" "$listedpath" "$inferredpath"
