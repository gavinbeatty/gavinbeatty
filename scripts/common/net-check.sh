#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

getopt=${getopt-getopt}
help=${help-}
dropped_udp=${dropped_udp:-}
unknown_udp_port=${unknown_udp_port:-}

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
   or: $prog [-u <dropped_udp>] [-p <unknown_udp_port>]
EOF
}
help() {
    cat <<EOF
Options:
 -h${longopts_support:+|--help}:
  Prints this help message and exits.
 -u${longopts_support:+|--dropped-udp} <dropped_udp>:
  <dropped_udp> can be either "show", or an integer. If "show", we print the
  number of dropped UDP packets. Otherwise, check if the number of dropped UDP
  packets matches <dropped_udp> and print and return error if it doesn't.
 -p${longopts_support:+|--unknown-udp-port} <unknown_udp_port>:
  <unknown_udp_port> can be either "show", or an integer. If "show", we print
  the number of UDP packets received on an unknown port. Otherwise, check if
  the number of UDP packets sent to an unknown port matches <unknown_udp_port>
  and print and return error if it doesn't.
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
    type "$@" >/dev/null 2>&1
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -ab -c -c >/dev/null 2>&1
}
dropped_udp() {
    local x="$(netstat -us)" || true # || die "Error using netstat"
    echo "$x" | grep -F errors | sed -e 's/[^0-9]*//g'
}
unknown_udp_port() {
    local x="$(netstat -us)" || true # || die "Error using netstat"
    echo "$x" | grep -F 'unknown port' | sed -e 's/[^0-9]*//g'
}

main() {
    if getopt_works ; then
        long=
        if test -n "$longopts_support" ; then
            long="-l help,dropped-udp:,unknown-udp-port:"
        fi
        opts="$(getopt -n "$prog" -o "hu:p:" $long -- "$@")"
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h|--help)
                help=1
                ;;
            -u|--dropped-udp)
                dropped_udp=$2
                shift
                ;;
            -p|--unknown-udp-port)
                unknown_udp_port=$2
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
    if (test -z "$dropped_udp") && (test -z "$unknown_udp_port") ; then
        usage >&2
        echo
        die "Must give one of -u or -p"
    fi

    ret=0
    if test -n "$dropped_udp" ; then
        if test "$dropped_udp" = "show" ; then
            dropped=$(dropped_udp)
            if test -z "$dropped" ; then
                echo "Cannot calculate number of dropped UDP packets" >&2
                ret=1
            else
                echo "Dropped UDP: $dropped"
            fi
        else
            expr "$dropped_udp" '*' 2 + 1 >/dev/null 2>&1 || die "Invalid value for <dropped_udp>"
            dropped=$(dropped_udp)
            if test -z "$dropped" ; then
                echo "Cannot calculate number of dropped UDP packets" >&2
                ret=1
            elif test "$dropped" -ne "$dropped_udp" ; then
                echo "Actually dropped $dropped UDP packets" >&2
                ret=1
            fi
        fi
    fi
    if test -n "$unknown_udp_port" ; then
        if test "$unknown_udp_port" = "show" ; then
            unknown=$(unknown_udp_port)
            if test -z "$unknown" ; then
                echo "Cannot calculate number of UDP packets received on an unknown port" >&2
                ret=1
            else
                echo "Unknown UDP port: $unknown"
            fi
        else
            expr "$unknown_udp_port" '*' 2 + 1 >/dev/null 2>&1 || die "Invalid value for <unknown_udp_port>"
            unknown=$(unknown_udp_port)
            if test -z "$unknown" ; then
                echo "Cannot calculate number of UDP packets received on an unknown port" >&2
                ret=1
            elif test "$unknown" -ne "$unknown_udp_port" ; then
                echo "Actually received $unknown UDP packets on an unknown port" >&2
                ret=1
            fi
        fi
    fi

    exit $ret
}
main "$@"
