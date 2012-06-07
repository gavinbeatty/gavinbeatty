#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -u
set -e
trap " echo Caught SIGINT ; exit 1 ; " INT
trap " echo Caught SIGTERM ; exit 1 ; " TERM

getopt=${GETOPT:-getopt}
help=${EXPORT_GIT_HELP:-}
basedir=${EXPORT_GIT_BASEDIR:-$HOME}
what=${EXPORT_GIT_WHAT:-}
host=${EXPORT_GIT_HOST:-}
xargs=${XARGS:-}
ssh=${SSH:-ssh}
tar=${TAR:-tar}
git=${GIT:-git}
prog="$(basename -- "$0")"

longopts=
e=0
"$getopt" -T >/dev/null 2>&1 || e=$?
test "$e" -ne 4 || longopts=1
unset e

usage() {
   echo "$prog [-b <basedir>] [-w <what>] [-H <host>]"
}
help() {
    cat <<EOF
Options:
 -h${longopts:+|--help}:
  Print this help message and exit.
 -b${longopts:+|--basedir}:
  The base directory to use for exporting <what>. Defaults to \${HOME}.
 -w${longopts:+|--what}:
  Export the given <what> directory (relative to <basedir>).
 -H${longopts:+|--host}:
  Export to the given <host>.
EOF
}
warning() { echo "warning: $@" >&2 ; }
error() { echo "error: $@" >&2 ; }
die() { error "$@" ; exit 1 ; }
have() { type -- "$@" >/dev/null 2>&1 ; }
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -ab -c -c >/dev/null 2>&1
}
get_xargs() {
    if test -z "$xargs" ; then
        xargs=xargs
        ! have gxargs || xargs=gxargs
    fi
}
get_tar() {
    if test -z "$tar" ; then
        tar=tar
        ! have gtar || xargs=gtar
    fi
}

main() {
    if getopt_works ; then
        long=
        if test -n "$longopts" ; then
            long="-l help,basedir:,what:,host:"
        fi
        e=0
        opts="$("$getopt" -n "$prog" -o "hb:w:H:" $long -- "$@")" || e=$?
        test $e -eq 0 || die "$getopt error"
        eval set -- "$opts"

        while test $# -ne 0 ; do
            case "$1" in
            -h|--help) help=1 ; ;;
            -b|--basedir)
                basedir="$2"
                shift
                ;;
            -w|--what)
                what="$2"
                shift
                ;;
            -H|--host)
                host="$2"
                shift
                ;;
            --) shift ; break ; ;;
            *)
                usage >&2
                die "Unknown argument: $1"
                ;;
            esac
            shift
        done
    else
        warning "Taking options from the environment."
    fi
    if test -n "$help" ; then
        usage
        echo
        help
        exit 0
    fi

    if test $# -ne 0 ; then
        usage >&2
        exit 1
    fi
    if test -z "$what" ; then
        die "Must give -w <what> optarg."
    fi
    if test -z "$host" ; then
        die "Must give -H <host> optarg."
    fi

    get_xargs
    get_tar
    set -x
    ( cd -- "${basedir}/$what" && \
      $git archive --format=tar --prefix="$what"/ 'HEAD^{tree}' \
        | $ssh "$host" \( test -d "$what" '&&' rm -rf -- "$what" \; $tar xv \) '&&' find "$what" -type f -print0 \| $xargs -r0 chmod a-w --
    )
}
main "$@"
