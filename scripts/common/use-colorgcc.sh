#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}
help=${help-}
verbose=${verbose-1}
bindir=""

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-h]"
    echo "   or: $prog [-q] [-v] [-b <bindir>] <onoff>"
}
error() { echo "error: $@" >&2 ; }
warn() { echo "warn: $@" >&2 ; }
#usage: verbose <level> <msg>...
verbose() {
    if test $verbose -ge "$1" ; then
        shift
        echo "verbose: $@" >&2
    fi
}
die() { error "$@" ; exit 1 ; }
have() { type "$@" >/dev/null 2>&1 ; }

enable_symlink() {
    anyway=""
    if test -f "$1" ; then
        if ! test -L "$1" ; then
            die "Cannot overwrite $1 because it's not a symlink"
        fi
        anyway=" anyway"
    fi
    verbose 1 "writing redirect symlink$anyway, $1"
    ln -sf "$2" "$1"
    verbose 2 "chmod +x $1"
    chmod +x "$1"
}
disable_symlink() {
    if test -f "$1" ; then
        if ! test -L "$1" ; then
            die "Cannot delete $1 because it's not a symlink"
        fi
        verbose 1 "removing redirect symlink, $1"
        rm -f -- "$1"
    else
        verbose 2 "no redirect symlink, $1"
    fi
}

enable_colorgcc() {
    enable_symlink "${bindir}/gcc" "colorgcc.pl"
    enable_symlink "${bindir}/g++" "colorgcc.pl"
}
disable_colorgcc() {
    disable_symlink "${bindir}/gcc"
    disable_symlink "${bindir}/g++"
}

main() {
    if have getopt ; then
        local e=0
        local opts="$("$getopt" -n "$prog" -o "hvqb:" -- "$@")" || e=$?
        test $e -eq 0 || exit 1
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
            -h) help=1 ;;
            -v) verbose=$(( verbose + 1 )) ;;
            -q) verbose=0 ;;
            -b) bindir="$2" ;;
            --) shift ; break ;;
            *) die "Unknown option: $1" ;;
            esac
            shift
        done
    fi
    if test -n "$help" ; then
        usage
        exit 0
    fi
    if test $# -ne 1 ; then
        usage >&2
        die "Must give a <onoff> argument."
    fi
    if test -z "$bindir" ; then
        bindir="${PREFIX:-${HOME}/.local}/bin"
    fi
    local onoff="$(echo "$1" | tr "[:upper:]" "[:lower:]")"
    case "$onoff" in
    yes|on|true|1|enable) enable_colorgcc ;;
    no|off|false|0|disable) disable_colorgcc ;;
    *) die "Invalid <onoff> argument." ;;
    esac
}
main "$@"
