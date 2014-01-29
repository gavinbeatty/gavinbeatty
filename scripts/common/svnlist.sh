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
tags=${tags:-}
branches=${branches:-}
trunk=${trunk:-}
full=${full:-}
append=${append:-}

longopts_support=
e=0
"$getopt" -T >/dev/null 2>&1 || e=$?
test "$e" -eq 4 && longopts_support=1

prog="$(basename -- "$0")"
say() { printf "%s\n" "$*" ; }
usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-v] [-f] [-a] -b [<path>]
   or: $prog [-v] [-f] [-a] -t [<path>]
   or: $prog [-v] [-f] [-a] -T [<path>]
EOF
}
help() {
    cat <<EOF
Options:
 -h${longopts_support:-|--help}:
  Prints this help message and exits.
 -v${longopts_support:-|--verbose}:
  Give more verbose output.
 -b${longopts_support:-|--branches}:
  Print branches.
 -t${longopts_support:-|--tags}:
  Print tags.
 -T${longopts_support:-|--trunk}:
  Print the trunk.
 -f${longopts_support:-|--full}:
  Print full URLs.
 -a${longopts_support:-|--append}:
  Append the longest "valid" suffix of <path> to each output line.
  ("Valid" is the first that works, and is blindly applied to each subsequent line.)

Arguments:
 <path>:
  The path to use. If not given, it defaults to the current directory. <path>
  can also be a repository URL.
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

# usage: svnurl <path>
svnurl() {
    local e=0
    local url="$(LC_ALL=C $SVN_EXE info "$1" 2>/dev/null || e=$?)"
    if test $e -ne 0 ; then
        return $e
    fi
    say "$url" | sed -n 's/^URL: //p'
}
# usage: svnnameurl <path> trunk|tags|branches
svnnameurl() {
    local url=$(svnurl "$1")
    local trail=
    url="${url%%/}"
    if ! say "$url" | grep -q '/\(trunk\|tags\|branches\)\($\|/\)' ; then
        if $SVN_EXE ls "$url/" 2>&1 | grep -q '^\(trunk\|tags\|branches\)\($\|/\)' ; then
            url="$url/$2"
        else
            if test "$url" != "$1" ; then
                trail=" (from $1)"
            fi
            die "URL does not contain trunk, tags, or branches: ${url}${trail:-}"
        fi
    fi
    url=$(say "${url%%/}/" | perl -e 'while(<STDIN>){s!/(trunk|tags|branches)(/.*|$)!/$ARGV[0]/!;print;}' "$2")
    if ! LC_ALL=C $SVN_EXE info "$url" >/dev/null 2>&1 ; then
        if test "$url" != "$1" ; then
            trail=" (from $1)"
        fi
        die "URL does not exist: ${url}${trail:-}"
    fi
    verbose 1 "URL: $url${trail:-}"
    say "$url"
}
svnls() {
    if test -n "$full" ; then
        $SVN_EXE ls "$1" | perl -e 'while(<STDIN>){s|^|$ARGV[0]|;s|/+$||;print;}' "$1"
    else
        $SVN_EXE ls "$1" | sed 's|//*$||'
    fi
}
# Only prints something when we left-trimmed one-or-more slashes.
ltrim() { say "$1" | sed -n 's#^[^/]*//*##p' ; }
# Append the longest suffix of "$1" to each URL from stdin.
appendLongest() {
    local trail="${1##/}"
    local havetrail=
    if test -z "$append" ; then cat
    else
        local url=
        while read url ; do
            url="${url%%/}"
            if test -z "$havetrail" ; then
                trail="${1##/}"
                while test -n "$trail" ; do
                    if ! $SVN_EXE info "${url}/$trail" >/dev/null 2>&1 ; then
                        trail="$(ltrim "$trail")"
                        trail="${trail##/}"
                    else
                        havetrail=1
                        trail="${trail%%/}"
                        break
                    fi
                done
            fi
            if test -n "$havetrail" && $SVN_EXE info "${url}/$trail" >/dev/null 2>&1 ; then
                say "${url}/$trail"
            else
                say "$url"
            fi
        done
    fi
}

main() {
    if getopt_works ; then
        longopts=
        test -z "$longopts_support" || longopts="-l help,verbose,tags,branches,trunk,full,append"
        opts="$("$getopt" -n "$prog" -o "hvtbTfa" $longopts -- "$@")"
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h|--help) help=1 ;;
            -v|--verbose) verbose=$((verbose + 1)) ;;
            -t|--tags) tags=1 ;;
            -b|--branches) branches=1 ;;
            -T|--trunk) trunk=1 ;;
            -f|--full) full=1 ;;
            -a|--append) append=1 ;;
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
    test -n "$tags" && tags=1
    test -n "$branches" && branches=1
    test -n "$trunk" && trunk=1

    exclusive="${tags}${branches}${trunk}"
    if test -z "${exclusive}" ; then
        error "Must give one of -t, -b, -T flags."
        usage >&2
        exit 1
    elif test "${exclusive}" -gt 1 ; then
        error "Cannot give more than one of -t, -b, -T at the same time."
        usage >&2
        exit 1
    fi

    if test $# -eq 0 ; then
        eval set -- "."
    elif test $# -gt 1 ; then
        error "Must give 0 or 1 <path> arguments."
        usage >&2
        exit 1
    fi

    if ! url="$(svnurl "$1")" ; then
        die "$1 is not an svn url or checkout!"
    fi

    if test -n "$tags" ; then
        if lsurl="$(svnnameurl "$1" "tags")" ; then
            svnls "$lsurl" | appendLongest "$url"
        fi
    elif test -n "$branches" ; then
        if lsurl="$(svnnameurl "$1" "branches")" ; then
            svnls "$lsurl" | appendLongest "$url"
        fi
    else
        svnnameurl "$1" "trunk" | sed 's|//*$||' | appendLongest "$url"
    fi
}
main "$@"
