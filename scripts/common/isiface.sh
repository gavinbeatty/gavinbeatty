#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
prog="$(basename -- "$0")"
have() { type -- "$@" >/dev/null 2>&1 ; }
usage() { echo "usage: ${prog} [--] <iface>" ; }
main() {
    if test $# -eq 2 ; then
        if test x"$1" != x"--" ; then iface="$1"
        elif test x"$2" != x"--" ; then iface="$2"
        else iface="$2" ; fi
    elif test $# -ne 1 ; then
        echo "error: Exactly one <iface> argument expected" >&2
        usage >&2
        exit 1
    else
        iface="$1"
    fi

    e=0
    if have ip ; then
        ip addr show dev "$iface" >/dev/null 2>&1 || e=$?
        exit $e
    elif have ifconfig ; then
        ifconfig -- "$iface" >/dev/null 2>&1 || e=$?
        exit $e
    else
        echo "error: No implementation found" >&2
        exit 127
    fi
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
