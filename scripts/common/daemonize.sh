#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

default_datefmt="%Y%m%d-%H%M%S"

getopt=${getopt-getopt}
help=${help-}
envstrip=${envstrip-}
pidfile=${pidfile-}
datefmt=${datefmt-}
stdoutfile=${stdoutfile-}
stderrfile=${stderrfile-}
wait=${wait-3}

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
   or: $prog [-E] [-w <wait>] [-p <pidfile>] [-d <datefmt>|default] [-e <stderrfile>] -o <stdoutfile> -- <command> [<args>...]
EOF
}
have() {
    type -- "$@" >/dev/null 2>&1
}
help() {
    cat <<EOF
Options:
 -h${longopts_support:+|--help}:
  Prints this help message and exits.
 -E${longopts_support:+|--envstrip}:
  Clears the environment of all variables except HOME, PATH, TERM, PWD, PS1 and
  PS2. Use "env" as your <command> if you really want a different environment.
 -w${longopts_support:+|--wait} <wait>:
  Wait <wait> seconds to see if the process died. If <wait> is zero, no check
  is made.
 -p${longopts_support:+|--pidfile} <pidfile>:
  Overwrite <pidfile> with the pid of the process.
 -d${longopts_support:+|--datefmt} <datefmt>|default:
  <datefmt> is passed to POSIX date. If <datefmt> is "default", use the
  default, $default_datefmt.
 -o${longopts_support:+|--stdoutfile} <stdoutfile>:
  Write stdout of the command to <stdoutfile>.
 -e${longopts_support:+|--stderrfile} <stderrfile>:
  If specified, write stderr of the command to <stderrfile>. If not specified,
  stderr is redirected to stdout (which is written to <stdoutfile>).

Arguments:
 --:
  Must be given so arguments to <command> are not swallowed up by $prog.
 <command>:
  The command to daemonize.
 <args>:
  Optional arguments passed to <command>.
EOF
}
die() {
    echo "error: $@" >&2
    exit 1
}
warning() {
    echo "warning: $@" >&2
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -ab -c -c >/dev/null 2>&1
}
# usage: insertdate <file> <date>
#
# inserts the date before the extension (if any).
insertdate() {
    if basename -- "$1" 2>/dev/null | grep -Fq '.' ; then
        echo "$1" | perl -we 'while(<STDIN>){s/(.*)\./$1$ARGV[0]./;print;}' "$2"
    else
        echo "$1$2"
    fi
}

main() {
    if getopt_works ; then
        long=
        if test -n "$longopts_support" ; then
            long="-l help,envstrip,wait:,pidfile:,datefmt:,stdoutfile:,stderrfile:"
        fi
        opts="$("$getopt" -n "$prog" -o "hEw:p:d:o:e:" $long -- "$@")"
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h|--help)
                help=1
                ;;
            -E|--envstrip)
                envstrip=1
                ;;
            -w|--wait)
                wait=$2
                shift
                ;;
            -p|--pidfile)
                pidfile=$2
                shift
                ;;
            -d|--datefmt)
                datefmt=$2
                shift
                ;;
            -o|--stdoutfile)
                stdoutfile=$2
                shift
                ;;
            -e|--stderrfile)
                stderrfile=$2
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
    if test -z "$stdoutfile" ; then
        usage >&2
        die "Must give a -o <stdoutfile>."
    fi

    if test -n "$datefmt" ; then
        if test "$datefmt" = "default" ; then
            datefmt=$default_datefmt
        fi
        stdoutfile=$(insertdate "$stdoutfile" "$(date "+$datefmt")")
        if test -n "$stderrfile" ; then
            stderrfile=$(insertdate "$stderrfile" "$(date "+$datefmt")")
        fi
    fi
    if test $# -eq 0 ; then
        usage >&2
        die "Must give a <command>."
    fi

    if test -z "$stderrfile" ; then
        if test -n "$envstrip" ; then
            # env should _not_ fork() and exec(), but just exec() for capturing
            # the pid to work
            # cannot use -- with -i in env :(
            env -i HOME="${HOME-}" PATH="${PATH-}" TERM="${TERM-}" PWD="${PWD-}" PS1="${PS1-}" PS2="${PS2-}" "$@" >"$stdoutfile" 2>&1 &
        else
            "$@" >"$stdoutfile" 2>&1 &
        fi
    else
        if test -n "$envstrip" ; then
            # env should _not_ fork() and exec(), but just exec() for capturing
            # the pid to work
            # cannot use -- with -i in env :(
            env -i HOME="${HOME-}" PATH="${PATH-}" TERM="${TERM-}" PWD="${PWD-}" PS1="${PS1-}" PS2="${PS2-}" "$@" >"$stdoutfile" 2>"$stderrfile" &
        else
            "$@" >"$stdoutfile" 2>"$stderrfile" &
        fi
    fi
    pid="$!"
    if test "$wait" -gt 0 ; then
        sleep -- "$wait"
        if LC_ALL=C PS_PERSONALITY=posix ps -o pid= -p "$pid" >/dev/null 2>&1 ; then
            if test -n "$pidfile" ; then
                echo "$pid" > "$pidfile"
            else
                echo "$pid"
            fi
        else
            die "Command is dead after $wait second wait: $@"
        fi
    fi
}
main "$@"
