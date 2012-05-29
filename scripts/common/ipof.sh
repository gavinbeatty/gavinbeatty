#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
prog="$(basename -- "$0")"
have() { type -- "$@" >/dev/null 2>&1 ; }
usage() { echo "usage: ${prog} [--] <iface>" ; }
main() {
    missing=
    sep=
    for i in "isiface.sh" "awk" "grep" ; do
        have "$i" || { missing="${missing}${sep}$i" ; sep=", " ; }
    done
    if test -n "$missing" ; then
        echo "error: Please install: $missing" >&2
        exit 1
    fi
    if test $# -eq 2 ; then
        if test x"$1" != x"--" ; then iface="$1"
        elif test x"$2" != x"--" ; then iface="$2"
        else iface="$2" ; fi
    elif test $# -ne 1 ; then
        echo "error: Must give exactly one <iface> argument" >&2
        usage >&2
        exit 1
    else
        iface="$1"
    fi
    if isiface.sh -- "$iface" ; then
        if have ip ; then
            ip addr show dev "$iface" scope global \
              | grep 'inet[[:space:]]' \
              | awk ' { print $2} ' \
              | awk ' BEGIN { FS="/" ; } { print $1} '
        elif have ifconfig ; then
            ifconfig "$iface" \
              | grep 'inet[[:space:]]' \
              | awk ' { print $2} '
        else
            echo "error: No implementation found" >&2
            exit 127
        fi
    else
        echo "error: $iface is not an <iface>" >&2
        exit 1
    fi
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
