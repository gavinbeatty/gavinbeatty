#!/bin/sh
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
trap ' echo Unexpected exit >&2 ; exit 1 ; ' 0
prog="$(basename -- "$0")"
pax() { trap '' 0 ; exit "$@" ; }
usage() { echo "usage: $prog [-m <mod>] <absdash> <shellscript>... <destination>" ; }
die() { echo "error: $@" >&2 ; pax 1 ; }
udie() { usage >&2 ; die "$@" ; }
if test $# -gt 0 && test "$1" = "-m" ; then
    if test $# -eq 1 ; then udie "Option -m must have a <mod>." ; fi
    mod="$2"
    shift 2
fi
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
prevset=
for i in "$@" ; do
    # operate on prev so last is skipped
    if test -n "$prevset" ; then
        base="$(basename -- "$prev")"
        out="$dest"
        case "$dest" in */) out="${dest}$base" ;; esac
        if test "$(head -n 1 -- "$prev")" = "#!/bin/sh" ; then
            sed -e "1s!^#\!/bin/sh\$!#\!${absdash}!" "$prev" | tee -- "$out" >/dev/null
        else
            cat -- "$prev" | tee -- "$out" >/dev/null
        fi
        if test -n "$mod" ; then chmod "$mod" -- "$out" ; fi
    fi
    prev="$i"
    prevset=1
done
pax
