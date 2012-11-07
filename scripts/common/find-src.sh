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
complete="${complete:-}"
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
    for getopt in getopt /usr/local/bin/getopt /opt/local/bin/getopt getopt-enhanced getopt-enhanced.py \
            "${HOME}/.local/usr/bin/getopt" "${HOME}/bin/getopt" ; do
        if type "$getopt" >/dev/null 2>&1 ; then
            if getopt_works ; then break ; fi
        fi
    done
fi

usage() {
    cat <<EOF
usage: $prog -h
   or: $prog -T
   or: $prog [options] -C <complete> [-- <find_args>...]
   or: $prog [options] [<find_dir> [-- <find_args>...]]
EOF
}
help() {
    cat <<EOF
    -h              print this help message and exit
    -T              print the list of <type>s supported and exit
    -C <complete>   use the given clang_complete file for additional directories

Options
    -0          use -print0 with find, instead of -print
    -a          give absolute paths (non-normalized)
    -f          find only files
    -c          find only C/C++ files -- equivalent to \`-t cppc'
    -t <type>   find only files of the given <type>
    -d          print some debugging of the find command

Arguments
    <find_dir>  the directory to search in -- if not given, the current directory is used
    <find_args> extra options that can be given directly to find
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
find_src() {
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
        jam)
            test -z "$debug" || set -x
            find $forcedir "$srcdir" "$@" \! \( -name '.git' -prune -o -path '*/.svn' -prune -o -name '.bzr' -prune -o -name '.hg' -prune -o -name '_darcs' -prune \
                -o -iname 'tags' -o -name 'cscope.*' -o -name '.src.files' \) $findfiles \
                -a \( -iname '*.jam' -o -name 'project-root.jam' -o -iname 'Jamfile' -o -iname 'Jamroot' \) \
                "$printer"
            ;;
        esac
    done
}
find_src_complete() {
    complete="$1"
    shift
    cat "$complete" | while read c ; do
        c="$(echo "$c" | sed -n 's/^-\(I\|include \)//p')"
        if test -n "$c" ; then
            if test -n "$absolute" ; then
                srcdir="$(abspath "$c")"
                (cd / && find_src "$@")
            else
                srcdir="."
                (cd -- "$c" && find_src "$@")
            fi
        fi
    done
}

main() {
    if test -z "${NO_GETOPT:-}" ; then
        if getopt_works ; then
            getopts="hTafct:0C:d"
            opts="$("$getopt" -n "$prog" -o "$getopts" -- "$@")"
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
                -C) complete="$2" ; shift ;;
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
        echo "all c cpp cppc cs py python pl perl lua sh bash java jam"
        exit 0
    fi

    if test -z "$complete" && test $# -eq 0 ; then
        set -- .
    fi

    if test -n "$zero" ; then
        printer="-print0"
    else
        printer="-print"
    fi

    if test -z "$complete" ; then
        if test -n "$absolute" ; then
            srcdir="$(abspath "$1")"
            cd /
        else
            srcdir="."
            cd -- "$1"
        fi
        shift
    fi

    case "$type" in
    all|c|cpp|cppc|cs|py|python|pl|perl|lua|sh|bash|java|jam) files=1 ;;
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
    if test -n "$complete" ; then
        find_src_complete "$complete" "$@"
    else
        find_src "$@"
    fi
}
( main "$@" )
