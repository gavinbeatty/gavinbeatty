#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
DIFF="${DIFF-colordiff}"
exec $DIFF -U10 -p "$@"
