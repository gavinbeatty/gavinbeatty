#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
plat="${plat:-}"
if test -z "$plat" ; then plat="$(uname -s | tr '[A-Z]' '[a-z]')" ; fi
case "$plat" in
    darwin) MAKE=gmake ;;
    *) MAKE=make ;;
esac

dirname="$(dirname -- "$0")"
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
PREFIX="${PREFIX:-${HOME}/.local/usr}"
if test $# -gt 0 ; then
    PREFIX="$1"
fi
export PREFIX
set -x
cd -- "$dirname"
$MAKE -C configs install
$MAKE -C scripts/common install
if test -d "scripts/$plat" ; then
    $MAKE -C "scripts/$plat" install
fi
$MAKE -C tools/fallback_eval_gettext install
