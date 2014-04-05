#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
say() { printf %s\\n "$*" ; }
warn() { say "warn: $*" >&2 ; }
die() { say "error: $*" >&2 ; exit 1 ; }
prog="$(basename -- "$0")"
if test $# -gt 2 ; then usage >&2 ; die "too many arguments."
elif test $# -eq 0 ; then
    case "$prog" in
        cc-def*) ;;
        gcc-def*) CC="${CC:-gcc}" ;;
        g++-def*) CC="${CC:-g++}" ;;
        clang-def*) CC="${CC:-clang}" ;;
        clang++-def*) CC="${CC:-clang++}" ;;
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
    *) say "warn: unrecognized CC=$CC." >&2 ;;
esac
e="$("$CC" -dM -E -x "${SRC:-c}" - 2>/dev/null </dev/null)" || die "error running CC=$CC."
say "$e" | sed "s/^#define /-D/;s/ /=/"
