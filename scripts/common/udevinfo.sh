#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
prog="$(basename -- "$0")"
have() { type -- "$@" >/dev/null 2>&1 ; }
die() { echo "error: $@" >&2 ; exit 1 ; }

if test $# -ne 1 ; then
    die "usage: ${prog} <device>"
fi
if have "udevinfo" ; then
    udevinfo --attribute-walk --path "$(udevinfo --query path --name "$1")"
elif have "udevadm" ; then
    udevadm info --attribute-walk --path "$(udevadm info --query path --name "$1")"
else
    die "error: Install udev (neither udevinfo nor udevadm found)."
fi
