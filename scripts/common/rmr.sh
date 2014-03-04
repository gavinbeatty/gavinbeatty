#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap 'echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap 'echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
prog="$(basename -- "$0")"
xargs="${XARGS:-}"
help=${RMR_HELP:-}
quiet=${RMR_QUIET:-}
dir="${RMR_DIRECTORY:-.}"
type="${RMR_TYPE:-f}"
pred="${RMR_PREDICATE:-name}"
symlinks="${RMR_SYMLINKS:--L}"
force="${RMR_FORCE:-}"
dryrun="${RMR_DRYRUN:-}"
have() { type "$@" >/dev/null 2>&1 ; }
die() { echo "error: $@" ; exit 1 ; }
udie() { usage >&2 ; exit 1 ; }
warning() { echo "warning: $@" >&2 ; }
usage() {
    cat <<EOF
usage: $prog -h
   or: $prog [-L|-P|-H|-D] [-f|-F -d <directory> -p <predicate> -t <type> <pattern>]..

Note: Options take effect in the order they are given. If you pass a pattern
      and then -n (for a dry-run), then the dry-run will only apply to the
      _following_ patterns.

Example:
  $prog -d . -p iname -t d 'release' 'debug' 'bin' -t f '*.persistent'
EOF
}

find_arg() {
    test $# -eq 1 || die "find_dir: unexpected argument count=$#"
    prune=""
    test "$type" != "d" || prune="-prune"
    test -z "$force" || force="f"
    if test -n "$dryrun" ; then
        echo find $symlinks "$dir" -type "$type" -"$pred" "$1" $prune -print0 \| $xargs -r0 rm -r$force --
    else
        test -n "$quiet" || set -x
        find $symlinks "$dir" -type "$type" -"$pred" "$1" $prune -print0 | $xargs -r0 rm -r$force --
        test -n "$quiet" || set +x
    fi
    did_find=1
}

main() {
    if test -n "$help" ; then
        usage
        exit 0
    fi
    if test -z "$xargs" ; then
        xargs=xargs
        ! have gxargs || xargs=gxargs
        have "$xargs" || die "Unable to find $xargs"
    fi
    if test $# -eq 0 ; then
        udie
    fi
    expect=""
    break=""
    did_find=""
    test -z "${RMR_DEBUG:-}" || set -x
    for arg in "$@" ; do
        case "$arg" in
        -h) test -z "$expect" || udie
            if test -z "$break" ; then
                usage ; exit 0
            else
                find_arg "$arg"
            fi
            ;;
        -L|-P|-H|-D)
            test -z "$expect" || udie
            if test -z "$break" ; then
                symlinks="$arg"
            else
                find_arg "$arg"
            fi
            ;;
        -f) test -z "$expect" || udie
            if test -z "$break" ; then
                force=f
            else
                find_arg "$arg"
            fi
            ;;
        -F) test -z "$expect" || udie
            if test -z "$break" ; then
                force=""
            else
                find_arg "$arg"
            fi
            ;;
        -n) test -z "$expect" || udie
            if test -z "$break" ; then
                dryrun=1
            else
                find_arg "$arg"
            fi
            ;;
        -t) test -z "$expect" || udie
            if test -z "$break" ; then
                test -z "$expect" || udie
                expect=t
            else
                find_arg "$arg"
            fi
            ;;
        -p) test -z "$expect" || udie
            if test -z "$break" ; then
                test -z "$expect" || udie
                expect=p
            else
                find_arg "$arg"
            fi
            ;;
        -d) test -z "$expect" || udie
            if test -z "$break" ; then
                test -z "$expect" || udie
                expect=d
            else
                find_arg "$arg"
            fi
            ;;
        --) test -z "$expect" || udie
            if test -n "$break" ; then
                find_arg "$arg"
            else
                break=1
            fi
            ;;
        -*) if test -n "$expect" ; then
                case "$expect" in
                t) type="$arg" ;;
                p) pred="$arg" ;;
                d) dir="$arg" ;;
                *) die "unknown value for \$expect=$expect" ;;
                esac
                expect=""
            else
                if test -z "$break" ; then
                    warning "found <pattern> argument before '--' which begins with '-'"
                fi
                find_arg "$arg"
            fi
            ;;
        *)  if test -n "$expect" ; then
                case "$expect" in
                t) type="$arg" ;;
                p) pred="$arg" ;;
                d) dir="$arg" ;;
                *) die "unknown value for \$expect=$expect" ;;
                esac
                expect=""
            else
                find_arg "$arg"
            fi
            ;;
        esac
    done
    test -n "$did_find" || udie
}
main "$@"
