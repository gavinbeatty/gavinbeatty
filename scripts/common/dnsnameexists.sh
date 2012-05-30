#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
progname="$(basename -- "$0")"

usage() {
    echo "usage: ${progname} <hostname>"
    echo "   or: ${progname} <hostname_printf_format> <list>..."
}


if test $# -eq 0 ; then
    usage >&2
    exit 1
fi
if type host >/dev/null 2>&1 ; then
    lookup() {
        host "$@" >/dev/null 2>&1
    }
elif type nslookup >/dev/null 2>&1 ; then
    lookup() {
        nslookup "$@" 2>/dev/null | grep -q "^Name:"
    }
else
    echo "Please install host or nslookup." >&2
    exit 1
fi

if test $# -eq 1 ; then
    if lookup "$1" ; then
        echo "$1"
    fi
    exit 0
fi

fmt="$1"
shift
for i in "$@" ; do
    host="$(printf "$fmt" "$i")"
    if lookup "$host" ; then
        echo "$host"
    fi
done
