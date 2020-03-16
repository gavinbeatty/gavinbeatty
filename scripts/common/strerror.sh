#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
trap ' test "${out:-}" = "" || rm -f "$out" ; ' 0
CC="${CC:-gcc}"
TMP="${TMP:-/tmp}"
say() { printf %s\\n "$*" ; }
warn() { say "warn: $*" >&2 ; }
die() { say "error: $*" >&2 ; exit 1 ; }
prog="$(basename -- "$0")"
usage() { say "usage: $prog <errno>" ; }
test $# -eq 1 || die "$(usage)"
case "$1" in
    -h|--help|-\?) usage ; exit 0 ;;
esac
say "$1" | grep -q '^[0-9][0-9]*$' || die "$(usage)"
errno="$1"
case "$CC" in
    cc*|-cc*|c++*|-c++*|gcc*|*-gcc*|g++*|*-g++*|clang*|*-clang*|clang++*|*-clang++*) ;;
    *) say "warn: unrecognized CC=$CC." >&2 ;;
esac
out="$(abspath.py "$(mktemp "$TMP/XXXXXXXX.out" || die "mktemp failed")" || die "abspath.py failed")"
"$CC" -x c -ansi -Wall -Wextra -Wpedantic -Werror -o "$out" - <<EOF
extern char* strerror(int);
extern int printf(const char* format, ...);
int main(void) { printf("%d: %s\n", $errno, strerror($errno)); return 0; }
EOF
test "$?" -eq 0 || die "error running CC=$CC."
"$out"
