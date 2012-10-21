#!/bin/sh
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
EXITN="${EXITN:-0}"
die() { echo "error: $@" >&2 ; exit 1 ; }
usage() {
    echo "usage: ifnargs.sh <ncom> <narg> <command>..."
}
if test $# -lt 3 ; then
    usage >&2
    die "Must give at least three arguments."
fi
ncom="$1"
narg="$2"
shift 2
if test "$ncom" -gt $# ; then
    usage >&2
    die "ncom=$1 but only received $# total arguments."
fi
check_narg() {
    shift "$ncom"
    test $# -ge "$narg" # return value
}
if check_narg "$@" ; then
    "$@"
else
    exit "$EXITN"
fi
