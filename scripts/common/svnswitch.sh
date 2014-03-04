#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

SVN_EXE=${SVN_EXE:-svn} ; export SVN_EXE
help=${help:-}
verbose=${verbose:-0}
ask=${ask:-}
branch=${branch:-}
tag=${tag:-}
trunk=${trunk:-}
dryrun=${dryrun:-}

prog="$(basename -- "$0")"
usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-v] [-n] [-a] -b <branch> [<path>]
   or: $prog [-v] [-n] [-a] -t <tag> [<path>]
   or: $prog [-v] [-n] [-a] -T [<path>]
EOF
}
help() {
    cat <<EOF
Options:
 -h:
  Prints this help message and exits.
 -v:
  Be more verbose.
 -n:
  Don't actually switch, just print what _would_ be done if we did switch.
 -a:
  Ask before switching.
 -b <branch>:
  Switch to the given <branch> name.
 -t <tag>:
  Switch to the given <tag> name.
 -T:
  Switch to trunk.

Arguments:
 <path>:
  The path to the checkout you would like to "svn switch". If not given,
  defaults to the current directory.
EOF
}
verbose() {
    if test $verbose -ge "$1" ; then
        echo "verbose: $@" >&2
    fi
}
error() {
    echo "error: $@" >&2
}
die() {
    error "$@"
    exit 1
}
have() {
    type "$@" >/dev/null 2>&1
}

# usage: svnurl <path>
svnurl() {
    local e=0
    local url="$(LC_ALL=C $SVN_EXE info -- "$1" 2>/dev/null)" || e=$?
    if test $e -ne 0 ; then
        return $e
    fi
    echo "$url" | sed -n 's/^URL: //p'
}
# usage: svnswurl <path> <tag_or_branch_path>
# e.g., svnswurl . tags/v1.0
svnswurl() {
    local url=$(svnurl "$1")
    if ! echo "$url" | grep -Eq '/(trunk|tags|branches)(/|$)' ; then
        die "The URL is not in trunk, tags or branches: $url"
    fi

    newurl=$(echo "$url" | perl -wnpe 's!/(tags|branches)(/|$)[^/]*!/'"$2"'$2!')
    if test "$newurl" != "$url" ; then
        echo "$newurl"
        return 0
    fi

    newurl=$(echo "$url" | perl -wnpe 's!/(trunk)(/|$)!/'"$2"'$2!')
    if test "$newurl" != "$url" ; then
        echo "$newurl"
        return 0
    fi
    echo "$url"
}
    
main() {
    if have getopt ; then
        opts="$(getopt -n "$prog" -o "hvnab:t:T" -- "$@")"
        eval set -- "$opts"

        while test $# -gt 0 ; do
        case "$1" in
            -h)
                help=1
                ;;
            -v)
                verbose=$(( verbose + 1 ))
                ;;
            -n)
                dryrun=1
                ;;
            -a)
                ask=1
                ;;
            -b)
                branch="$2"
                shift
                ;;
            -t)
                tag="$2"
                shift
                ;;
            -T)
                trunk=1
                ;;
            --)
                shift
                break
                ;;
            *)
                die "Unknown option: $1"
                ;;
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

    if test $# -eq 0 ; then
        eval set -- "."
    fi
    if test $# -ne 1 ; then
        usage >&2
        die "Must give zero or one arguments."
    fi

    if (test -z "$branch") && (test -z "$tag") && (test -z "$trunk") ; then
        usage >&2
        die "Must give one of -b, -t, -T flags."
    fi
    if (test -n "$branch") && (test -n "$tag") && (test -n "$trunk") ; then
        usage >&2
        die "Must give only of of -b, -t, -T flags."
    fi

    if test -n "$branch" ; then
        url=$(svnswurl "$1" "branches/$branch")
    elif test -n "$tag" ; then
        url=$(svnswurl "$1" "tags/$tag")
    else
        url=$(svnswurl "$1" "trunk")
    fi

    if test -z "$dryrun" ; then
        cd -- "$1"
    fi

    if test -n "$dryrun" ; then
        echo "(cd -- \"$1\" && $SVN_EXE switch -- \"$url\")"
    elif test -n "$ask" ; then
        echo "${prog}: $SVN_EXE switch $url"
        while true ; do
            printf "Continue? y/n: "
            answer=
            read answer
            if echo "$answer" | grep -iq '^[yn]$' ; then
                $SVN_EXE switch -- "$url"
                break
            fi
        done
    else
        verbose 1 "URL: $url"
        $SVN_EXE switch -- "$url"
    fi
}
main "$@"
