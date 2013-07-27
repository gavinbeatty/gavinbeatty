#!/bin/sh
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
trap ' echo Unexpected exit >&2 ; exit 1 ; ' 0
prog="$(basename -- "$0")"
peace() { trap '' 0 ; exit 0 ; }
usage() { echo "usage: $prog <abssh> <shellscript>..." ; }
die() { trap '' 0 ; echo "error: $@" >&2 ; exit 1 ; }
udie() { trap '' 0 ; usage >&2 ; exit 1 ; }
test $# -gt 1 || udie
abssh="$1"
shift
test -x "$abssh" || die "$abssh isn't executable."
case "$abssh" in
    /*) ;;
    *) die "$abssh isn't an absolute path." ;;
esac
case "$(uname | tr '[A-Z]' '[a-z]')" in
    *bsd*|darwin*) sedi() { sed -i '' "$@" ; } ;;
    *) sedi() { sed -i "$@" ; } ;;
esac
for i in "$@" ; do
    h="$(head -n 1 -- "$i")"
    case "$h" in
    \#!/*sh*) sedi -e "1s!^#\!/.*sh\$!#\!${abssh}!" "$i" ;;
    \#!/*sh\ *) sedi -e "1s!^#\!/.*sh \(.*\)\$!#\!${abssh} \1!" "$i" ;;
    esac
done
peace
