#!/bin/sh
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
trap ' echo Unexpected exit >&2 ; exit 1 ; ' 0
prog="$(basename -- "$0")"
pax() { trap '' 0 ; exit 0 ; }
usage() { echo "usage: $prog <absdash> <shellscript>... <destination>" ; }
die() { trap '' 0 ; echo "error: $@" >&2 ; exit 1 ; }
udie() { trap '' 0 ; usage >&2 ; echo "error: $@" >&2 ; exit 1 ; }
test $# -gt 2 || udie "Not enough arguments."
absdash="$1"
shift
test -x "$absdash" || die "$absdash isn't executable."
case "$absdash" in
    /*) ;;
    *) die "$absdash isn't an absolute path." ;;
esac
last() { local i= ; local f= ; for i in "$@" ; do f="$i" ; done ; echo "$f" ; }
dest="$(last "$@")"
if test "$dest" != "/" && test "$dest" != "//" ; then dest="${dest%%/}" ; fi
prevset=
for i in "$@" ; do
    # operate on prev so last is skipped
    if test -n "$prevset" ; then
        base="$(basename -- "$prev")"
        if test "$(head -n 1 -- "$prev")" = "#!/bin/sh" ; then
            sed -e "1s!^#\!/bin/sh\$!#\!${absdash}!" "$prev" | tee -- "${dest}/$base" >/dev/null
        else
            cat -- "$prev" | tee -- "${dest}/$base" >/dev/null
        fi
    fi
    prev="$i"
    prevset=1
done
pax
