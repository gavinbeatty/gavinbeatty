#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap "echo Caught SIGTERM >&2 ; exit 1 ; " TERM
trap "echo Caught SIGINT >&2 ; exit 1 ; " INT
prog="$(basename -- "$0")"

getopt=${getopt-}
help=${help-}
types=${types-}
absolute=${absolute-}
files=${files-}
type=${type-}
zero=${zero-}
debug=${debug-}

have() { type "$@" >/dev/null 2>&1 ; }
die() { echo "error: $@" >&2 ; exit 1 ; }
warn() { echo "warning: $@" >&2 ; }
getopt_works() {
    eval set -- "$("$getopt" -n "test" -o "ab:c" -- -ab -c "s pace" "a rg" -b "o arg" 2>&1)"
    test $# -eq 8 && test "$1" = "-a" && test "$2" = "-b" && test "$3" = "-c" \
        && test "$4" = "-b" && test "$5" = "o arg" && test "$6" = "--" \
        && test "$7" = "s pace" && test "$8" = "a rg"
}
if test -z "$getopt" ; then
    for getopt in getopt /usr/local/bin/getopt /opt/local/bin/getopt getopt-enhanced getopt-enhanced.py ; do
        if type "$getopt" >/dev/null 2>&1 ; then
            if getopt_works ; then break ; fi
        fi
    done
fi

usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-T]
   or: $prog [-0] [-a] [-f|-c|-t <type>] [<find_dir> [-- <find_args>...]]
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
  Extra options that can be given directly to find.
EOF
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
    if test -z "${NO_GETOPT:-}" ; then
        if getopt_works ; then
            opts="$("$getopt" -n "$prog" -o "hTafct:0d" -- "$@")"
            eval set -- "$opts"
            while test $# -gt 0 ; do
                case "$1" in
                -h) help=1 ;;
                -T) types=1 ;;
                -a) absolute=1 ;;
                -f) files=1 ;;
                -c) type="cppc" ;;
                -t) type="$2" ; shift ;;
                -0) zero=1 ;;
                -d) debug=1 ;;
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
        else
            die "No suitable getopt found. export getopt=..."
        fi
    else
        warn "Not using getopt for options."
    fi

    if test -n "$help" ; then
        usage
        echo
        help
        exit 0
    fi
    if test -n "$types" ; then
        echo "all c cpp cppc cs py python pl perl lua sh bash java"
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
    all|c|cpp|cppc|cs|py|python|pl|perl|lua|sh|bash|java) files=1 ;;
    esac

    findfiles=""
    if test -n "$files" ; then
        findfiles="-a -type f"
    fi
    forcedir=""
    if find -f . -maxdepth 0 >/dev/null 2>&1 ; then
        forcedir="-f"
    fi

    if test -z "$type" ; then type="all" ; fi
    for t in $(echo "$type" | tr '[A-Z]' '[a-z]' | sed -e 's/[:,;]/ /g') ; do
        case "$t" in
        all)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                "$printer"
            ;;
        c)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.c' -o -name '*.h' \) \
                "$printer"
            ;;
        cpp)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.cc' -o -name '*.C' -o -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) \
                "$printer"
            ;;
        cppc)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.cc' -o -name '*.cpp' -o -iname '*.c' -o -name '*.hpp' -o -name '*.h' \) \
                "$printer"
            ;;
        cs)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.cs' \) \
                "$printer"
            ;;
        py|python)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.py' \) \
                "$printer"
            ;;
        pl|perl)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.pl' \) \
                "$printer"
            ;;
        lua)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.lua' \) \
                "$printer"
            ;;
        sh)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.sh' \) \
                "$printer"
            ;;
        bash)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.sh' -o -name '*.bash' \) \
                "$printer"
            ;;
        java)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -name '*.java' \) \
                "$printer"
            ;;
        esac
    done
}
( main "$@" )
