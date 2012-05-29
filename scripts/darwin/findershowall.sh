#!/bin/sh
# tell Finder to show/or hide all files.
set -e
set -u
prog="$(basename -- "$0")"
die() { echo "error: $@" >&2 ; exit 1 ; }
usage() {
    echo "${prog} [<true_or_false>]"
}
to_bool() {
    case "$(echo "$1" | tr '[A-Z]' '[a-z]')" in
    0|false|no|off) return 0 ;;
    1|true|yes|on) echo 1 ; return 0 ;;
    esac
    return 1
}
main() {
    if test $# -gt 1 ; then
        usage >&2
        exit 1
    fi
    if test $# -eq 0 ; then
        defaults read com.apple.Finder AppleShowAllFiles
        return $?
    else
        boolarg="$1"
        # argument to true/false format
        e=0
        bool="$(to_bool "$boolarg" || e=$?)"
        if test $e -ne 0 ; then
            die "<true_or_false> is not boolean"
        fi
        arg="true"
        test -n "$bool" || arg="false"
        defaults write com.apple.Finder AppleShowAllFiles "$arg"
        return $?
    fi
    return 0
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
