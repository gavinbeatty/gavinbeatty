#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -u
set -e
trap " echo Caught SIGINT ; exit 1 ; " INT
trap " echo Caught SIGTERM ; exit 1 ; " TERM
tar=${TAR:-tar}
git=${GIT:-git}
v=${VERBOSE:+-v}
prog="$(basename "$0")"
subprog="${prog#git-}"
niceprog="$git $subprog"
test "$prog" != "$subprog" || niceprog="$prog"

die() { printf %s\\n "$*" >&2 ; exit 1 ; }

test $# -eq 4 || die "usage: $prog <url> <tree-ish> <sub-tree> <out-path>"
url="${1:-.}"
treeish="${2:-HEAD}"
subtree="${3:-.}"
outpath="${4:-.}"
shift 4

"$git" archive --format=tar --remote="$url" "$treeish" "$subtree" | tar -x ${v} -C "${outpath%/}/"
