#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

# taken from the environment, set these in bashrc etc.
SVN_EXE=${SVN_EXE-svn} ; export SVN_EXE
SVNRELNOTES_PYTHON=${SVNRELNOTES_PYTHON-python}
SVN2LOG=${SVN2LOG-svn2log.py}

# these are arguments, _don't_ set them in bashrc
verbose=${verbose-0}
python=${python-$SVNRELNOTES_PYTHON}
svn2log=${svn2log-$SVN2LOG}

prog="$(basename -- "$0")"
usage() {
    echo "usage: $prog [-h] [-p <python>] [-l svn2log] <fromurl> [<tourl>]"
}
die() {
    echo "error: $@" >&2
    exit 1
}
have() {
    type -- "$@" >/dev/null 2>&1
}

main() {
    if have getopt ; then
        opts=$(getopt -n "$prog" -o "hp:l:" -- "$@")
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h)
                usage
                exit 0
                ;;
            -v)
                verbose=1
                ;;
            -p)
                python=$2
                shift
                ;;
            -l)
                svn2log=$2
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                die "unknown option: $1"
                ;;
            esac
            shift
        done
    fi

    if test $# -eq 1 ; then
        tourl="."
    elif test $# -eq 2 ; then
        tourl="$2"
    else
        usage >&2
        exit 1
    fi
    rev=$(svnlastcommit.sh "$1")
    if test -z "$rev" ; then
        die "svnlastcommit.sh failed to find revision for $1"
    fi
    ${SVN_EXE} log -v --xml -r"${rev}:HEAD" "$tourl" | $python $svn2log -O -H -s
}
main "$@"
