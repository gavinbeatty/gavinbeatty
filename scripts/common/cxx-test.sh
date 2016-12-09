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
usage() { say "usage: $prog <limits|collapse> [<cxx> [<args>...]]" ; }
case "${1:-}" in
    -h|--help|-\?) usage ; exit 0 ;;
esac
case "${1:-}" in
    limits|collapse) op="$1" ; shift ;;
    *) usage >&2 ; die "must give <limits|collapse> argument" ;;
esac
if test $# -eq 0 ; then
    case "$prog" in
        cxx-*) CXX="${CXX:-c++}" ;;
        c++-*) CXX="${CXX:-c++}" ;;
        g++-*) CXX="${CXX:-g++}" ;;
        clang++-*) CXX="${CXX:-clang++}" ;;
        *) warn "unknown program name: $prog" >&2 ;;
    esac
fi
if test $# -ge 1 ; then CXX="$1" ; shift ; fi
CXX="${CXX:-c++}"
case "$CXX" in
    c++*|-c++*|g++*|*-g++*|clang++*|*-clang++*) ;;
    *) say "warn: unrecognized CXX=$CXX." >&2 ;;
esac
limits() {
    cat <<EOF-LIMITS
#include <cinttypes>
#include <cstdint>
#include <iostream>
#include <limits>
template <class T, class MaxT = T> void limit(const char *type, const char* pfmt, const char* sfmt, const char* literalSuffix = "")
{
using L = std::numeric_limits<T>;
std::cout << type << " min max printf scanf = " << static_cast<MaxT>(L::min()) << literalSuffix << ' ' << static_cast<MaxT>(L::max()) << literalSuffix << ' ' << pfmt << ' ' << sfmt << std::endl;
}
int main()
{
    limit<char, int>("char", PRId8, SCNd8);
    limit<unsigned char, unsigned>("unsigned char", "hhu", "hhu");
    limit<signed char, int>("signed char", "hhd", "hhd");
    limit<unsigned short>("unsigned short", "hu", "hu");
    limit<short>("short", "hd", "hd");
    limit<unsigned int>("unsigned int", "u", "u");
    limit<int>("int", "d", "d");
    limit<unsigned long>("unsigned long", "lu", "lu");
    limit<long>("long", "ld", "ld");
    limit<unsigned long long>("unsigned long long", "llu", "llu");
    limit<long long>("long long", "lld", "lld");
    limit<std::size_t>("size_t", "z", "z");
    limit<std::ptrdiff_t>("ptrdiff_t", "t", "t");
    limit<std::uint8_t, std::uint16_t>("uint8", PRIu8, SCNu8, "u");
    limit<std::int8_t, std::int16_t>("int8", PRId8, SCNd8);
    limit<std::uint16_t>("uint16", PRIu16, SCNu16, "u");
    limit<std::int16_t>("int16", PRId16, SCNd16);
    limit<std::uint32_t>("uint32", PRIu32, SCNu32, "U");
    limit<std::int32_t>("int32", PRId32, SCNd32);
    limit<std::uint64_t>("uint64", PRIu64, SCNu64, "ULL");
    limit<std::int64_t>("int64", PRId64, SCNd64);
    limit<float>("float", "f", "f", "f");
    limit<double>("double", "f", "lf");
    return 0;
}
EOF-LIMITS
}
collapse() {
    cat <<EOF-LIMITS
#include <iostream>
#include <string>
template <class T> void collapseT(T t, const char* e) { std::cout << "f(T t) given " << e << ": " << __PRETTY_FUNCTION__ << std::endl; }
template <class T> void collapseRefT(T& t, const char* e) { std::cout << "f(T& t) given " << e << ": " << __PRETTY_FUNCTION__ << std::endl; }
template <class T> void collapseConstT(const T t, const char* e) { std::cout << "f(const T t) given " << e << ": " << __PRETTY_FUNCTION__ << std::endl; }
template <class T> void collapseConstRefT(const T& t, const char* e) { std::cout << "f(const T& t) given " << e << ": " << __PRETTY_FUNCTION__ << std::endl; }
template <class T> void collapseRefRefT(T&& t, const char* e) { std::cout << "f(T&& t) given " << e << ": " << __PRETTY_FUNCTION__ << std::endl; }
int main()
{
    std::string i = "i";
    std::string& ri = i;
    const std::string ci = "ci";
    const std::string& cri = i;
#define COLLAPSE(f) do { f(i, "i (std::string)"); f(ri, "ri (std::string&)"); f(ci, "ci (const std::string)"); f(cri, "cri (const std::string&)"); f(std::string("1"), "std::string(\"1\")"); } while(0)
    COLLAPSE(collapseT);
    collapseRefT(i, "i (std::string)"); collapseRefT(ci, "ci (const std::string)"); collapseRefT(cri, "cri (const std::string&)");
    COLLAPSE(collapseConstT);
    COLLAPSE(collapseConstRefT);
    COLLAPSE(collapseRefRefT);
    return 0;
}
EOF-LIMITS
}
cxx() { local in="$1" ; out="$2" ; shift 2 ; "$CXX" -std=c++11 -x c++ "$@" -o "$out" "$in" ; }
out="$(mktemp "/tmp/cxx-test.${op}.XXXXXX")"
cleanup() { rm -f "$out" ; }
trap cleanup 0
"$op" | cxx - "$out" "$@" || die "error running CXX=$CXX."
"$out"
