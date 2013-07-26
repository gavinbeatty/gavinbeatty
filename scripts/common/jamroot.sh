#!/bin/sh
# vi: set ft=sh et sw=4 ts=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM
die() { echo "error: $@" >&2 ; exit 1 ; }
isroot() { 
    ls Jamroot* >/dev/null 2>&1 || test -f project-root.jam
}
while test "$(pwd)" != / ; do
    if isroot ; then pwd ; exit 0
    else cd .. ; fi
done
if isroot ; then pwd ; else die "jam root not found" ; fi
