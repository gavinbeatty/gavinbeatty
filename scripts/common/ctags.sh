#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
# C/C++
# kinds
## list all:
## c  classes
## d  macro definitions
## e  enumerators (values inside an enumeration)
## f  function definitions
## g  enumeration names
## l  local variables [off]
## m  class, struct, and union members
## n  namespaces
## p  function prototypes [off]
## s  structure names
## t  typedefs
## u  union names
## v  variable definitions
## x  external variable declarations [off]
#
# fields
## list all:
## a   Access (or export) of class members
## f   File-restricted scoping [enabled]
## i   Inheritance information
## k   Kind of tag as a single letter [enabled]
## K   Kind of tag as full name
## l   Language of source file containing tag
## m   Implementation information
## n   Line number of tag definition
## s   Scope of tag definition [enabled]
## S   Signature of routine (e.g. prototype or parameter list)
## (t) type and name info (not in exuberant ctags 5.5.4) [enabled]
## z   Include the "kind:" key in kind field
#
# extra
## list all:
##  f   Include an entry for the base file name of every source file (e.g.
##      "example.c"), which addresses the first line of the file.
##
##  q   Include an extra class-qualified tag entry for each tag which is a member
##      of a class (for languages  for  which  this  information  is extracted;
##      currently  C++,  Eiffel,  and Java). The actual form of the qualified tag
##      depends upon the language from which the tag was derived (using a form that is
##      most natural for how qualified calls are specified in  the  language).  For
##      C++,  it  is  in  the  form "class::member";  for Eiffel and Java, it is in
##      the form "class.member". This may allow easier location of a specific tags
##      when multi‐ ple occurrences of a tag name occur in the tag file. Note,
##      however, that this could potentially more than double the size of  the  tag
##      file.
set -e
set -u
trap ' echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap ' echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
prog="$(basename -- "$0")"
help="${CTAGS_HELP:-}"
getopt="${CTAGS_GETOPT:-getopt}"
allow_no_getopt="${CTAGS_ALLOW_NO_GETOPT:-}"
ctags="${CTAGS_CTAGS:-ctags}"
verbose="${CTAGS_VERBOSE:-0}"
files="${CTAGS_FILES:-}"
echodo="${CTAGS_ECHODO:-}"
fxn="${CTAGS_FXN:-ctags_cxx}"

c_extra="+f"
c_fields="+flnsS"
c_kinds="+cdefgmpstuvx"

cxx_extra="+fq"
cxx_fields="+failnsS"
cxx_kinds="+cdefgmnpstuvx"

# XXX ctags -L "$opt_list" --c++-kinds=+p --fields=+iaS --extra=+q "$@"

usage() {
    echo "usage: $prog [-v] [-c|-x|-t <type>] [-f <files>|<dir>]"
}
have() { type "$@" >/dev/null 2>&1 ; }
echodo() { echo "$@" ; "$@" ; }
die() { echo "error: $@" >&2 ; exit 1 ; }
warning() { echo "warning: $@" >&2 ; }

ctags_generic() {
    $echodo ctags --sort=foldcase -R "$@"
}
ctags_c() {
    ctags_generic --extra="$c_extra" --fields="$c_fields" \
        --c-kinds="$c_kinds" "$@"
}
ctags_cxx() {
    ctags_generic --extra="$cxx_extra" --fields="$cxx_fields" \
        --c++-kinds="$cxx_kinds" "$@"
}

get_fxn() {
    case "$1" in
    c) echo "ctags_c" ;;
    c++|cpp|cxx|cc) echo "ctags_cxx" ;;
    generic|any) echo "ctags_generic" ;;
    *) ;;
    esac
}

main() {
    if have "$getopt" ; then
        opts="$("$getopt" -n "$prog" -o "+hvcxt:f:" -- "$@")"
        eval set -- "$opts"
        while true ; do
            case "$1" in
                -h) help=1 ;;
                -v) verbose=$(( $verbose + 1 ))
                    echodo="echodo"
                    ;;
                -c) fxn="ctags_c" ;;
                -x) fxn="ctags_cxx" ;;
                -t)
                    type="$(echo "$2" | tr '[A-Z]' '[a-z]')"
                    fxn="$(get_fxn "$type")"
                    if test -z "$fxn" ; then
                        die "Invalid <type> $2"
                    fi
                    ;;
                -f) files="$2" ; shift ;;
                --) shift ; break ;;
                *) usage >&2 ; exit 1 ;;
            esac
            shift
        done
    elif test -n "$allow_no_getopt" ; then
        warning "$getopt not found. Only taking options from the environment."
    else
        die "$getopt not found."
    fi
    test -z "$help" || { usage ; exit 0 ; }

    if test $# -gt 0 ; then
        if test -n "$files" ; then
            die "Cannot give <files> and <dir> at the same time"
        fi
        "$fxn" "$@"
    elif test $# -eq 0 ; then
        "$fxn" .
    else
        # doesn't seem to only index these files though
        "$fxn" -L "$files"
    fi
}
main "$@"
