#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -u
set -e
prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-z | -d] [--] <archive>"
}
die() { echo "error: $@" >&2 ; exit 1 ; }
trap "die 'Caught SIGINT'" INT
trap "die 'Caught SIGTERM'" TERM
have() { type -- "$@" >/dev/null 2>&1 ; }
getopt_impl__=""
get_getopt() {
    if test -z "$getopt_impl__" ; then
        if have getopt ; then
            e=0
            getopt -T >/dev/null 2>&1 || e=$?
            if test "$e" -eq 4 ; then
                echo "getopt"
            fi
        elif have getopt-enhanced ; then
            e=0
            getopt-enhanced -T >/dev/null 2>&1 || e=$?
            if test "$e" -eq 4 ; then
                echo "getopt-enhanced"
            fi
        fi
    else
        echo "$getopt_impl__"
    fi
}
do_getopt() {
    impl="$(get_getopt)"
    if test -n "$impl" ; then
        local e=0
        "$impl" "$@" || e=$?
        return $e
    else
        die "Please install getopt (enhanced) or getopt-enhanced"
    fi
}
for z7 in "7zr" "7za" ; do
    if type "$z7" >/dev/null 2>&1 ; then
        break
    fi
done
test -z "$z7" && die "7zip not installed."

opts="$(do_getopt -l "decompress,compress,help,version" -o "dzhv" -- "$@")"
eval set -- "$opts"
cmd="z"

while test $# -gt 0 ; do
    case "$1" in
    -z|--compress) cmd="z" ;;
    -d|--decompress) cmd="d" ;;
    -h|--help) usage ; exit 0 ;;
    --version) version ; exit 0 ;;
    --) shift ; break ;;
    *) usage >&2 ; exit 1 ;;
    esac
    shift
done
if test $# -ne 1 ; then
    usage >&2
    exit 1
fi

set -x
archive="$1"
case "$cmd" in
z)
    "$z7" a -bd -si -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$archive"
    exit $? ;;
d)
    "$z7" x -so "$archive"
    exit $? ;;
*)
    die "internal error: unknown \$cmd" ;;
esac
