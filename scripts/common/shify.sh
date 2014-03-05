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
replacesh() { perl -e 'my $sh=$ARGV[0];my $i=0;while(<STDIN>){if($i==0){s#^\#!.*/(env |)(da|)sh(| .*)$#\#!$sh$4#;}print;$i=$i+1;}' "$1" ; }
for i in "$@" ; do
    replacesh "$abssh" < "$i" > "$i".shify
    cat "$i".shify > "$i" # cat into it, rather than move into it, so we don't modify file attributes
    rm "$i".shify
done
peace
