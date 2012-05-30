#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

prog="$(basename -- "$0")"
help=${help-}
default_datefmt="%Y%m%d-%H%M"
usage() { echo "usage: $prog [<date_fmt>]" ; }

if test -n "$help" ; then
    usage
    exit 0
fi

if test $# -eq 0 ; then
    set -- "$default_datefmt"
elif test $# -gt 1 ; then
    usage >&2
    exit 1
fi
exec date "+$1"
