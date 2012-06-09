#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

default_kill=

getopt=${getopt-getopt}
help=${help-}
quiet=${quiet-}
remove=${remove-}
force_remove=${force_remove-}
killsignal=${killsignal-}
pidfile=${pidfile-}
pid=${pid-}
kill=${kill-$default_kill}

prog="$(basename -- "$0")"

longopts_support=
e=0
"$getopt" -T >/dev/null 2>&1 || e=$?
if test "$e" -eq 4 ; then
    longopts_support=1
fi
unset e

usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-q] [-k <killsignal>] [-K <kill>] -p <pid>
   or: $prog [-q] [-k <killsignal>] [-K <kill>] [-r|-R] -f <pidfile>
EOF
}
help() {
    cat <<EOF
Options:
 -h${longopts_support:+|--help}:
  Prints this help message and exits.
 -q${longopts_support:+|--quiet}:
  If the pid is not found, etc., return error as usual, but don't print
  anything.
 -k${longopts_support:+|--killsignal} <killsignal>:
  Sends the process with the given <killsignal> with -s.
 -p${longopts_support:+|--pid} <pid>:
  Kill the given <pid>.
 -f${longopts_support:+|--pidfile} <pidfile>:
  Get the pid to kill from the given <pidfile>.
 -r${longopts_support:+|--remove}:
  Remove the <pidfile> argument to -f after killing.
 -R${longopts_support:+|--force-remove}:
  Remove the <pidfile> argument to -f even if the kill was unsuccessful.
 -K${longopts_support:+|--kill} <kill>:
  The kill command to use to kill processes. An empty string means use
  \`kill', falling back to \$(which kill). Defaults to "$kill".
EOF
}
error() { echo "error: $@" >&2 ; }
die() { error "$@" ; exit 1 ; }
have() { type "$@" >/dev/null 2>&1 ; }
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -ab -c -c >/dev/null 2>&1
}
doquiet() {
    local e=0
    if test -n "$quiet" ; then
        "$@" >/dev/null 2>&1 || e=$?
    else
        "$@" || e=$?
    fi
    return "$e"
}
dokill() {
    if doquiet "$kill" "$@" ; then
        if (test -n "$remove") && (test -n "$pidfile") ; then
            rm -f -- "$pidfile"
        fi
    elif (test -n "$force_remove") && (test -n "$pidfile") ; then
        rm -f -- "$pidfile"
    fi
}
cleanup() {
    if test -n "$force_remove" ; then
        if test -n "$pidfile" ; then
            rm -f -- "$pidfile"
        fi
    fi
}

main() {
    if getopt_works ; then
        long=
        if test -n "$longopts_support" ; then
            long="-l help,quiet,killsignal:,pidfile:,remove,force-remove,pid:,kill:"
        fi
        opts="$(getopt -n "$prog" -o "hqk:f:rRp:K:" $long -- "$@")"
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h|--help) help=1 ;;
            -q|--quiet) quiet=1 ;;
            -k|--killsignal) killsignal=$2 ; shift ;;
            -f|--pidfile) pidfile=$2 ; shift ;;
            -r|--remove) remove=1 ;;
            -R|--force-remove) remove=1 ; force_remove=1 ;;
            -p|--pid) pid=$2 ; shift ;;
            -K|--kill) kill=$2 ; shift ;;
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
    if test -z "$kill" ; then
        kill="kill"
        if ! have "$kill" ; then
            kill="$(which kill)"
            if ! have "$kill" ; then
                die "No <kill> found in your system: please supply one."
            fi
        fi
    elif ! have "$kill" ; then
        die "Given <kill>, \`$kill', does not exist."
    fi
    # only now will we try to force remove
    trap " cleanup ; " 0

    if test -n "$pidfile" ; then
        if test -n "$pid" ; then
            usage >&2
            die "Can only give one of -f <pidfile> and -p <pid>."
        fi
        pid="$(cat -- "$pidfile" 2>/dev/null)" || die "Cannot read <pidfile> $pidfile."
        if test -z "$pid" ; then
            usage >&2
            die "No PID in <pidfile>."
        fi
    elif test -z "$pid" ; then
        usage >&2
        die "Must give one of -f <pidfile> or -p <pid>."
    fi
    expr "$pid" '*' 2 '+' 1 >/dev/null 2>&1 || die "Invalid pid $pid."

    if test -n "$killsignal" ; then
        dokill -s "$killsignal" "$pid"
    else
        dokill "$pid"
    fi
}
main "$@"
