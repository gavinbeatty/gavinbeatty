#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap "echo Caught SIGTERM >&2 ; exit 1 ; " TERM
trap "echo Caught SIGINT >&2 ; exit 1 ; " INT

getopt=${getopt-getopt}
help=${help-}
types=${types-}
absolute=${all-}
files=${files-}
type=${type-}
zero=${zero-}
debug=${debug-}

have() {
    type -- "$@" >/dev/null 2>&1
}
die() {
    echo "$@" >&2
    exit 1
}

if ! have basename ; then
    prog="find-src.sh"
else
    e=0
    tryprog="$(basename -- "$0")" || e=$?
    if test $e -ne 0 ; then
        e=0
        tryprog="$(basename "$0")" || e=$?
    fi
    if test $e -eq 0 ; then
        prog="$tryprog"
    fi
    unset tryprog
fi

usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-T]
   or: $prog [-0] [-a] [-f|-c|-t <type>] [<find_dir> [<find_args>...]]
EOF
}
help() {
    cat <<EOF
Options:
 -h:
  Print this help message and exit.
 -T:
  Print the list of <type>s supported and exit.
 -0:
  Use -print0 with find, instead of -print.
 -a:
  Give absolute paths (non-normalized).
 -f:
  Find only files.
 -c:
  Find only C/C++ files. Equivalent to \`-t cppc'.
 -t <type>:
  Find only files of the given <type>.
 -d:
  Print some debugging of the find command.

Arguments:
 <find_dir>:
  The directory to search in. If not given, the current directory is used.
 <find_args>:
  XXX
EOF
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -ab -c -c >/dev/null 2>&1
}

abspath() {
    if ! test $# -eq 1; then
        echo "abspath: assert(\$# -eq 1) failed."
        exit 1
    fi
    case "$1" in
    /*);;
    *)
        echo "$(pwd)/$1"
        return 0
        ;;
    esac
    echo "$1"
}

main() {
    if getopt_works ; then
        opts="$("$getopt" -n "$prog" -o "hTafct:0d" -- "$@")"
        eval set -- $opts
        while test $# -gt 0 ; do
            case "$1" in
            -h) help=1 ; ;;
            -T) types=1 ; ;;
            -a) absolute=1 ; ;;
            -f) files=1 ; ;;
            -c) type="cppc" ; ;;
            -t) type="$2" ; shift ; ;;
            -0) zero=1 ; ;;
            -d) debug=1 ; ;;
            --)
                shift
                break
                ;;
            *)
                die "Unknown option: $1"
                ;;
            esac
            shift
        done
    fi

    if test -n "$help" ; then
        usage
        echo
        help
        exit 0
    fi
    if test -n "$types" ; then
        echo "c cpp cppc python perl lua sh bash java"
        exit 0
    fi

    if test $# -eq 0 ; then
        eval set -- "."
    fi

    if test -n "$zero" ; then
        printer="-print0"
    else
        printer="-print"
    fi

    if test -n "$absolute" ; then
        srcdir="$(abspath "$1")"
        cd /
    else
        srcdir="."
        cd -- "$1"
    fi
    shift

    case "$type" in
    c|cpp|cppc|python|perl|lua|sh|bash|java) files=1 ; ;;
    esac

    findfiles=""
    if test -n "$files" ; then
        findfiles="-a -type f"
    fi

    if test -z "$type" ; then
        test -z "$debug" || set -x
        find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
            -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
            "$printer"
    else
        case "$type" in
        c)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.c' -o -name '*.h' \) \
                "$printer"
            ;;
        cpp)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.cc' -o -name '*.C' -o -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) \
                "$printer"
            ;;
        cppc)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.cc' -o -name '*.cpp' -o -iname '*.c' -o -name '*.hpp' -o -name '*.h' \) \
                "$printer"
            ;;
        python)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.py' \) \
                "$printer"
            ;;
        perl)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.pl' \) \
                "$printer"
            ;;
        lua)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.lua' \) \
                "$printer"
            ;;
        sh)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.sh' \) \
                "$printer"
            ;;
        bash)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.sh' -o -name '*.bash' \) \
                "$printer"
            ;;
        java)
            test -z "$debug" || set -x
            find "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune \
                -o -name 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.java' \) \
                "$printer"
            ;;
        esac
    fi
}
main "$@"
