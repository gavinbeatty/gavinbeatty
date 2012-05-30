#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -u
set -e
trap " echo 'Caught SIGINT' ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' ; exit 1 ; " TERM

prog="$(basename -- "$0")"

usage() {
    echo "usage: $prog [-l <files_file>] [<dir>]"
}
die() {
    echo "$@" >&2
    exit 1
}

opt_list="${cscope_opt_list-}"

main() {
    opts="$(getopt -n "$prog" -o "hl:" -- "$@")"
    eval set -- $opts

    while test $# -gt 0 ; do
        case "$1" in
        -h)
            usage
            exit 0
            ;;
        -l)
            opt_list="$2"
            shift
            ;;
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

    if test $# -eq 0 ; then
        eval set -- "."
    fi

    dir="$1"
    shift

    rm -- "${dir}/cscope.files" "${dir}/cscope.out" >/dev/null 2>&1 || true
    if test -z "$opt_list" ; then
        opt_list="${dir}/.src.files"
        set -x
        find-src.sh -ac "$dir" > "$opt_list"
    fi
    set -x
    (cd -- "$dir" && cscope -b -i "$opt_list")
}
main "$@"
