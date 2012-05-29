#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
prog="$(basename -- "$0")"
usage() { echo "${prog} <keyid>" ; }
die() { echo "error: $@" >&2 ; exit 1 ; }
main() {
    if test $# -ne 1 ; then
        die "Must give one <keyid>."
    fi
    echo | gpg --use-agent --no-tty --sign --local-user -- "$1"

}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
