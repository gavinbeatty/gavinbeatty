#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
warn() { echo "warn: $@" >&2 ; }
die() { echo "error: $@" >&2 ; exit 1 ; }
prog="$(basename -- "$0")"
if test $# -gt 2 ; then usage >&2 ; die "too many arguments."
elif test $# -eq 0 ; then
    case "$prog" in
        cc-inc*) ;;
        gcc-inc*) CC="${CC:-gcc}" ;;
        g++-inc*) CC="${CC:-g++}" ;;
        clang-inc*) CC="${CC:-clang}" ;;
        clang++-inc*) CC="${CC:-clang++}" ;;
        *) warn "unknown program name." >&2 ;;
    esac
    if type cc >/dev/null 2>&1 ; then CC=cc ; fi
elif test $# -ge 1 ; then CC="$1" ; SRC="${2:-}"
fi
CC="${CC:-gcc}"
s="${CC%%++}"
if test -n "$CC" && test "$CC" != "$s" ; then SRC="${SRC:-c++}" ; fi
case "$CC" in
    cc*|-cc*|c++*|-c++*|gcc*|*-gcc*|g++*|*-g++*|clang*|*-clang*|clang++*|*-clang++*) ;;
    *) echo "warn: unrecognized CC=$CC." >&2 ;;
esac
e="$(echo | "$CC" -v -x "${SRC:-c}" -c - 2>&1 >/dev/null)" || die "error running CC=$CC."
echo "$e" | perl -we 'my $i=0;while(<STDIN>){if($i){if(/^End of search list\.$/){$i=0;}else{s/^\s*/-I/;print;}}elsif(/^#include </){$i=1;}}'
