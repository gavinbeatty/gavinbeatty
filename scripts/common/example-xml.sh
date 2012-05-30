#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
test $# -ne 0 || set -- *example*.xml
for i in "$@" ; do
    set -x
    cp -- "$i" "$(echo $i | sed -e 's/[-_]example//g' -e 's/^example-//')"
done
