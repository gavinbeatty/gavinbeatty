#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

kernel="${kernel:-}"
os="${os:-}"
is_msys2=
if test -z "$kernel" ; then kernel="$(uname -s | tr 'A-Z' 'a-z')" ; fi
if test -z "$os" ; then os="$(uname -o | tr 'A-Z' 'a-z')" ; fi
case "${kernel}---${os}" in
    msys_nt*---msys) is_msys2=1 ;;
esac
MAKE="${MAKE:-}"
if test -z "$MAKE" ; then
    case "$kernel" in
        darwin) MAKE=gmake ;;
        *) MAKE=make ;;
    esac
fi
HOST="$(hostname -f 2>/dev/null || true)"
if test -z "$HOST" ; then HOST="$(hostname 2>/dev/null || true)" ; fi

dirname="$(dirname -- "$0")"
PREFIX="${PREFIX:-${HOME}/.local}"
if test $# -gt 0 ; then
    PREFIX="$1"
fi
export PREFIX
set -x
cd -- "$dirname"
$MAKE -C configs/common install
if test -n "$is_msys2" ; then
    $MAKE -C configs/common install-vimrc HOME="$(cygpath -u "$HOMEDRIVE")" VIMUNDER=.
    $MAKE -C configs/common install-vimrc HOME="$(cygpath -u "$HOMEDRIVE")" VIMUNDER=_
    $MAKE -C configs/msys2 install
fi
$MAKE -C configs/external install
case "$HOST" in
    *.maths.tcd.ie) $MAKE -C configs/maths install ;;
esac
$MAKE -C scripts/common install
$MAKE -C scripts/external install
if test -d "scripts/$kernel" ; then
    $MAKE -C "scripts/$kernel" install
fi
