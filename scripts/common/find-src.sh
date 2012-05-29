#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u

getopt="${getopt:-getopt}"
prog="$(basename -- "$0")"
zero="${zero:-}"
type="${type:-c++}"

usage() {
    echo "usage: $prog [-0] [-a | -t <type>] <directory>..."
}
do_find() {
    for t in $(echo "$type" | sed 's/:/ /g') ; do
        case "$t" in
        all)
            find "$@" -- -type f \
                -not '(' -wholename '*/.svn/*' -o -wholename '*/.git/*' -o -wholename '*/.bzr/*' -o -wholename '*/.hg/*' ')' \
                "$print"
            ;;
        c|c++|cpp|cxx)
            find "$@" -- -type f \
                '(' -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.hh' -o -name '*.hpp' ')' \
                -not '(' -wholename '*/.svn/*' -o -wholename '*/.git/*' -o -wholename '*/.bzr/*' -o -wholename '*/.hg/*' ')' \
                "$print"
            ;;
        c-only)
            find "$@" -- -type f \
                '(' -name '*.c' -o -name '*.h' ')' \
                -not '(' -wholename '*/.svn/*' -o -wholename '*/.git/*' -o -wholename '*/.bzr/*' -o -wholename '*/.hg/*' ')' \
                "$print"
            ;;
        c++-only|cpp-only|cxx-only)
            find "$@" -- -type f \
                '(' -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.hh' -o -name '*.hpp' ')' \
                -not '(' -wholename '*/.svn/*' -o -wholename '*/.git/*' -o -wholename '*/.bzr/*' -o -wholename '*/.hg/*' ')' \
                "$print"
            ;;
        perl|pl)
            find "$@" -- -type f \
                '(' -name '*.pl' ')' \
                -not '(' -wholename '*/.svn/*' -o -wholename '*/.git/*' -o -wholename '*/.bzr/*' -o -wholename '*/.hg/*' ')' \
                "$print"
            ;;
        python|py)
            find "$@" -- -type f \
                '(' -name '*.py' ')' \
                -not '(' -wholename '*/.svn/*' -o -wholename '*/.git/*' -o -wholename '*/.bzr/*' -o -wholename '*/.hg/*' ')' \
                "$print"
            ;;
        *)
            echo "warning: unknown <type> $type: defaulting to c++" >&2
            type="c++" do_find "$@"
            ;;
        esac
    done
}
main() {
    opts="$("$getopt" -n "$prog" -o 'hz0at:' -- "$@")"
    eval set -- "$opts"
    while true ; do
        case "$1" in
        -h) usage ; exit 0 ; ;;
        -z|-0) zero=1 ; ;;
        -a) type=all ; ;;
        -t) type="$2" ; shift ; ;;
        --) shift ; break ;;
        *) echo "error: unknown option $1" >&2 ; exit 1 ; ;;
        esac
        shift
    done
    if test $# -eq 0 ; then
        set -- .
    fi
    type="$(echo "$type" | tr '[A-Z]' '[a-z]')"
    print="-print"
    if test -n "$zero" ; then
        print="-print0"
    fi
    # use -f to always interpret the first arg as a path
    do_find -f "$@"
}
trap ' echo Caught SIGINT ; exit 1 ; ' INT
trap ' echo Caught SIGTERM ; exit 1 ; ' TERM
main "$@"
