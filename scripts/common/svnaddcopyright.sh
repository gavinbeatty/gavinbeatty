#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM
prog=$(basename -- "$0")
who="${COPYRIGHT_WHO:-}"

die() { echo "error: $@" >&2 ; exit 1 ; }
findyear() {
    e=0
    local year="$(LC_ALL=C svn log -l 1 -r 1:HEAD -- "$f" | awk -F '|' '/\|/ {print $3}')" || e=$?
    echo "${year:1:4}"
    return $e
}
main() {
    if test $# -eq 0 ; then
        echo "usage: $prog <sourcefile>..." >&2
        die "Must give at least one <sourcefile>."
    fi
    if test -z "$who" ; then die "Please set COPYRIGHT_WHO." ; fi
    for f in "$@" ; do
        if ! head -n 30 -- "$f" | grep -iq '\<copyright\>' ; then
            e=0
            local year="$(findyear "$f")" || e=$?
            if test $e -eq 0 ; then
                printf "1i\n// Copyright (c) $year ${who}\n.\nw\nq\n" | ed -s -- "$f"
            fi
        fi
    done
}
main "$@"
