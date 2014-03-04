#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -u
set -e
trap ' echo "Caught SIGINT" ; exit 1 ; ' INT
trap ' echo "Caught SIGTERM" ; exit 1 ; ' TERM

SVN_EXE=${SVN_EXE:-svn} ; export SVN_EXE
getopt=${getopt:-getopt}
verbose=${verbose:-0}
# The last "real" commit is the one given by svn info's Last Changed Rev.
# This is the last commit that isn't a copy, or at least it ignores copies such
# as creating tags etc.
#
# As such, it's not usually what we want (as I use svnlastcommit.sh mainly for
# finding a tag's commit revision for pegging externals).
real=${real:-}
local=${local:-}

progname="$(basename -- "$0")"
usage() {
    echo "usage: $progname [-v] [-r] [<path>...]"
}
die() { echo "error: $@" >&2 ; exit 1 ; }
wouldverbose() { test "$verbose" -ge "$1" ; }
verbose() {
    if wouldverbose "$1" ; then
        shift
        echo "$@"
    fi
}

main() {
    opts="$("$getopt" -o "vhlr" -- "$@")"
    eval set -- "$opts"

    while test $# -ne 0 ; do
        case "$1" in
        -v) verbose=$(( verbose + 1 )) ; ;;
        -h) usage ; exit 0 ; ;;
        -l) local=1 ; ;;
        -r) real=1 ; ;;
        --) shift ; break ; ;;
        *) die "unknown option: $1" ; ;;
        esac
        shift
    done

    if test $# -eq 0 ; then
        set -- "."
    fi

    for i in "$@" ; do
        e=0
        info="$(LC_ALL=C $SVN_EXE info -- "$i" 2>&1)" || e=$?
        if test $e -eq 0 ; then
            if test -z "$real" ; then
                # includes copies etc.
                url="$i"
                loghead=""
                if test -z "$local" ; then
                    url="$(echo "$info" | sed -n 's/^URL: //p')"
                    loghead=" URL"
                    if wouldverbose 2 ; then
                        loghead="${loghead}: $url"
                    fi
                fi
                rev="$($SVN_EXE log -l 1 -- "$url" 2>/dev/null | perl -wne 'if($.==2){s/^r(\d+).*/$1/;print;}')"
                via="log$loghead"
            else
                # is the last "development" commit
                rev="$(echo "$info" | sed -n 's/^Last Changed Rev: //p')"
                via="info"
            fi

            if wouldverbose 1 ; then
                echo "via ${via}: $rev"
            else
                echo "$rev"
            fi
        else
            die "$i is not an svn url or checkout!"
        fi
    done
}
main "$@"
