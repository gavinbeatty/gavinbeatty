#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
DIFF="${DIFF-colordiff}"
DIFFCTX="${DIFFCTX:-10}"
DIFFOPTS="${DIFFOPTS:--U$DIFFCTX -p}"
exec $DIFF $DIFFOPTS "$@"
