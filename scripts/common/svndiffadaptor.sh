#!/bin/sh
# vi: set ft=sh et sw=2 ts=2:
set -e
set -u
exec ${DIFF:-diff -U10 -p -b} "$@"
