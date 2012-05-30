#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}
help=${help-}
pidfile=${pidfile-}
pid=${pid-}

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
usage: $prog -h
   or: $prog -f <pidfile> <comm> <deadfile>
   or: $prog -p <pid> <comm> <deadfile>
EOF
}
help() {
    cat <<EOF
Options:
 -h${longopts_support:+|--help}:
  Prints this help message and exits.
 -f${longopts_support:+|--pidfile} <pidfile>:
  A file containing only the process ID of <comm>.
 -p${longopts_support:+|--pid} <pid>:
  The process ID of <comm>.

Arguments:
 <comm>:
  The command to check for. This should be what "ps -wwo comm=" would print.
 <deadfile>:
  The file to use as a dead check.  If <deadfile> does not exist, an error is
  printed to stdout and to <deadfile>. If <deadfile> does exist, nothing is
  printed to either stdout or <deadfile>.

If the process is not found, the return value is non-zero.

Not giving the right number of arguments or none or both of -f and -p will
simply return with non-zero error code.
Otherwise, all failures (such as not being able to read the <pidfile>) will
create the <deadfile> containing the error, and return non-zero.
EOF
}
error() {
    echo "error: $@" >&2
}
die() {
    error "$@"
    exit 1
}
have() {
    type -- "$@" >/dev/null 2>&1
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -ab -c -c >/dev/null 2>&1
}
is_num() {
    test -n "$1" && expr "$1" '*' 2 + 1 >/dev/null 2>&1
}
dead() {
    local d=$1
    shift
    if test "${no_deadfile-0}" -eq 1 ; then
        echo "$@" > "$d"
        die "$@"
    else
        exit 1
    fi
}

main() {
    if getopt_works ; then
        long=
        if test -n "$longopts_support" ; then
            long="-l help,pidfile:,pid:"
        fi
        opts="$(getopt -n "$prog" -o "hf:p:" $long -- "$@")"
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h|--help)
                help=1
                ;;
            -f|--pidfile)
                pidfile=$2
                shift
                ;;
            -p|--pid)
                pid=$2
                shift
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
    if test $# -ne 2 ; then
        usage >&2
        die "Must give 2 arguments, <comm> and <deadfile>."
    fi
    comm=$1
    deadfile=$2

    if test -n "$pidfile" ; then
        if test -n "$pid" ; then
            usage >&2
            die "Cannot give -f <pidfile> and -p <pid> at the same time."
        fi
        pid=$(cat -- "$pidfile") || dead "$deadfile" "Cannot read <pidfile>, $pidfile"
        is_num "$pid" || dead "$deadfile" "Invalid pid, $pid, from <pidfile>, $pidfile"
    elif test -n "$pid" ; then
        is_num "$pid" || dead "$deadfile" "Invalid <pid>, $pid"
    else
        die "Must give one of -f <pidfile> and -p <pid>."
    fi

    no_deadfile=1
    if test -f "$deadfile" ; then
        no_deadfile=0
    fi

    ps_comm=$(LC_ALL=C ps -wwp "$pid" -o comm=) || dead "$deadfile" "<pid>, $pid, not running."
    if test "$comm" != "$ps_comm" ; then
        dead "$deadfile" "Expected \"$comm\", but received \"$ps_comm\"" > "$deadfile"
    fi
    exit 0
}
main "$@"
