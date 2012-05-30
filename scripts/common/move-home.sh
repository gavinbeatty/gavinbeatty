#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

TAR_OPTS="${TAR_OPTS-}"

main() {
    if (test $# -lt 2) || (test $# -gt 3) ; then
        echo 'usage: move-home.sh <command> <tar-file> [<home-dir>]' >&2
        exit 1
    fi
    homedir="${3-$HOME}"
    case "$2" in
    /*)
        ;;
    *)
        echo 'error: <tar-file> must be an absolute path' >&2
        exit 1
        ;;
    esac

    case "$1" in
    tar)
        cd -- "$homedir" && tar -cv --preserve-permissions --xattrs --recursion --sparse $TAR_OPTS -f "$2" .
        ;;
    untar)
        cd -- "$homedir" && tar -xv --preserve-permissions --owner gavinbeatty $TAR_OPTS -f "$2"
        ;;
    *)
        echo 'usage: unrecognized <command>: valid commands: tar untar' >&2
        exit 1
        ;;
    esac
}
main "$@"
