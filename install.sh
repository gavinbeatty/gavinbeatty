#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

plat="${plat:-}"
if test -z "$plat" ; then plat="$(uname -s | tr '[A-Z]' '[a-z]')" ; fi
case "$plat" in
    darwin) MAKE=gmake ;;
    *) MAKE=make ;;
esac
HOST="$(hostname -f 2>/dev/null || true)"
if test -z "$HOST" ; then HOST="$(hostname 2>/dev/null || true)" ; fi

dirname="$(dirname -- "$0")"
PREFIX="${PREFIX:-${HOME}/.local/usr}"
if test $# -gt 0 ; then
    PREFIX="$1"
fi
export PREFIX
set -x
cd -- "$dirname"
$MAKE -C configs/common install
case "$HOST" in
    *.maths.tcd.ie) $MAKE -C configs/maths install ;;
esac
$MAKE -C scripts/common install
$MAKE -C scripts/external install
if test -d "scripts/$plat" ; then
    $MAKE -C "scripts/$plat" install
fi
