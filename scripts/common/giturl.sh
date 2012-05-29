#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
main() {
    test $# -ne 0 || set -- .
    if test $# -eq 2 ; then
        if test "$1" = "--" ; then
            shift
        fi
    fi
    if test $# -gt 1 ; then
        die "Must give zero or one <path> arguments."
    fi
    if isgitrepo.sh "$1" ; then
        (cd -- "$1" && git config remote.origin.url)
    else
        "$1 is not a git repository."
    fi
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
