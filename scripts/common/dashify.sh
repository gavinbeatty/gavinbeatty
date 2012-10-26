#!/bin/sh
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
trap ' echo Unexpected exit >&2 ; exit 1 ; ' 0
prog="$(basename -- "$0")"
pax() { trap '' 0 ; exit 0 ; }
usage() { echo "usage: $prog <absdash> <shellscript>..." ; }
die() { trap '' 0 ; echo "error: $@" >&2 ; exit 1 ; }
udie() { trap '' 0 ; usage >&2 ; echo "error: $@" >&2 ; exit 1 ; }
test $# -gt 1 || udie "Not enough arguments."
absdash="$1"
shift
test -x "$absdash" || die "$absdash isn't executable."
case "$absdash" in
    /*) ;;
    *) die "$absdash isn't an absolute path." ;;
esac
case "$(uname | tr '[A-Z]' '[a-z]')" in
    *bsd*|darwin*) inplace="-i ''" ;;
    *) inplace="-i" ;;
esac
for i in "$@" ; do
    if test "$(head -n 1 -- "$i")" = "#!/bin/sh" ; then
        sed $inplace -e "1s!^#\!/bin/sh\$!#\!${absdash}!" "$i"
    fi
done
pax
