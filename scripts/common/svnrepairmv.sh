#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

SVN_EXE=${SVN_EXE:-svn} ; export SVN_EXE
help=${help:-}
getopt=${getopt:-getopt}
verbose=${verbose:-0}
dry_run=${dry_run:-}

longopts_support=
e=0
"$getopt" -T >/dev/null 2>&1 || e=$?
test "$e" -eq 4 && longopts_support=1

prog="$(basename -- "$0")"
say() { printf "%s\n" "$*" ; }
usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-v|-n] <path1.1> <path1.2> [<path2.1> <path2.2>...]
EOF
}
help() {
    cat <<EOF
Options:
 -h${longopts_support:-|--help}:
  Prints this help message and exits.
 -v${longopts_support:-|--verbose}:
  Be more verbose.
 -n${longopts_support:-|--dry-run}:
  Dry run. Implies -v.

Arguments:
 <path1.1>:
 The first part of the first path pair.
 <path1.2>:
 The second part of the first path pair.
 <path2.1>:
 The first part of the second path pair.
 <path2.2>:
 The second part of the second path pair.
EOF
}
error() {
    say "error: $*" >&2
}
#usage: verbose <level> <msg>...
verbose() {
    if test $verbose -ge "$1" ; then
        shift
        say "verbose: $@" >&2
    fi
}
die() {
    error "$@"
    exit 1
}
have() {
    type "$1" >/dev/null 2>&1
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -a -bc -c >/dev/null 2>&1
}

svnst() {
    verbose 1 $SVN_EXE status "$@"
    $SVN_EXE status "$@"
}
svncol1() { svnst -- "$1" | head -n1 | sed 's/^\(.\).*/\1/' ; }
categorizepath() {
    local col1="$(svncol1 "$1")"
    local cat="$(test "$col1" != "!" || echo old)$(test "$col1" != "?" || echo new)"
    verbose 2 "path:$1 col1:$col1 cat:$cat"
    case "$cat" in
        old) echo old ;;
        new) echo new ;;
        oldnew) die "Categorized $1 as both old and new." ;;
        *) die "Unable to categorize $1 as either old or new." ;;
    esac
}

svnrepairoldnew() {
    local old="$1"
    local new="$2"
    verbose 1 mv -n -- "$new" "$old" "&&" $SVN_EXE mv -- "$old" "$new"
    test -n "$dry_run" || ( mv -n -- "$new" "$old" && $SVN_EXE mv -- "$old" "$new" )
}

main() {
    if getopt_works ; then
        longopts=
        test -z "$longopts_support" || longopts="-l help,verbose,dry-run"
        opts="$("$getopt" -n "$prog" -o "hvn" $longopts -- "$@")"
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
            -h|--help) help=1 ;;
            -v|--verbose) verbose=$((verbose + 1)) ;;
            -n|--dry-run) verbose=$((verbose + 1)) ; dry_run=1 ;;
            --) shift ; break ;;
            *) die "Unknown option: $1" ;;
            esac
            shift
        done
    fi

    if test -n "$help" ; then
        usage
        echo
        help
        exit 0
    fi

    if test $# -lt 2 ; then
        error "Must give at least <path1.1> <path1.2>."
        usage >&2
        exit 1
    fi
    if test "$(expr $# % 2)" != 0 ; then
        error "Must give <pathN.1> <pathN.2> pairs."
        usage >&2
        exit 1
    fi
    while test $# -gt 0 ; do
        if test $# -lt 2 ; then
            die "Missing second part of pair of <path> elements."
        fi
        local p1="$1"
        local p2="$2"
        shift 2
        local cat1="$(categorizepath "$p1")"
        local cat2="$(categorizepath "$p2")"
        if test "$cat1" = old ; then
            svnrepairoldnew "$p1" "$p2"
        else
            svnrepairoldnew "$p2" "$p1"
        fi
    done
}
main "$@"
