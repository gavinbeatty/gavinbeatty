#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
trap ' echo Unexpected exit >&2 ; exit 1 ; ' 0
prog="$(basename -- "$0")"
subprog="${prog##git-}"
niceprog="git $subprog"
test "$prog" != "$subprog" || niceprog="$prog"
die() { trap '' 0 ; echo "error: $@" >&2 ; exit 1 ; }
udie() { trap '' 0 ; usage >&2 ; echo "error: $@" >&2 ; exit 1 ; }
pax() { trap '' 0 ; exit 0 ; }
usage() {
    cat <<EOF
usage: $niceprog [options] -- [<dir>]
    -n, --dry-run   print only the final command, but don't execute it
EOF
}
dirset=
args=0
odone=
testrun=
arg() {
    if test "$args" -eq 0 ; then args=1 ; dirset=1 ; dir="$1"
    else udie "Too many arguments." ; fi
}
while test $# -gt 0 ; do
    if test -z "$odone" ; then
        case "$1" in
            -n|--dry-run) testrun=1 ;;
            -h|-\?|--help) usage ; pax ;; # not much point in --help since git catches it
            --) odone=1 ;;
            -[a-z][a-z]*) os="$(echo "${1##-}" | sed 's/./-& /g')" ; shift ; set -- $os "$@" ;;
            -) arg "$1" ;;
            -*) udie "Unrecognized option, $1." ;;
            *) arg "$1" ;;
        esac
    elif test "$args" -eq 0 ; then args=1 ; dirset=1 ; dir="$1"
    else udie "Too many arguments." ; fi
    if test -n "${os:-}" ; then os=
    else shift ; fi
done
go() {
    if test -n "$testrun" ; then
        if test -n "$dirset" ; then echo "(cd -- $dir && $@)"
        else echo "$*" ; fi
        pax
    else
        test -z "$dirset" || cd -- "$dir"
        "$@"
    fi
}
br="$(go git rev-parse --abbrev-ref HEAD)"
if test "$br" = HEAD ; then
    die "Not on any branch."
fi
echo "$br"
pax
