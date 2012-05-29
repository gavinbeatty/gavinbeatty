#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (c) 2011 Gavin Beatty
# <gavinbeatty@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND  NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###########################################################################
set -e
set -u
prog="$(basename -- "$0")"
lf="
"
help="${SCRIPT_HELP:-}"
getopt="${SCRIPT_GETOPT-getopt}"
verbose="${SCRIPT_VERBOSE-0}"

have() { type -- "$@" >/dev/null 2>&1 ; }
usage() { echo "usage: $prog <arg>..." ; }
help() {
    cat <<EOF
Copyright (c) 2012 Gavin Beatty <gavinbeatty@gmail.com>
Licensed under the MIT license: http://www.opensource.org/licenses/MIT

A template for POSIX sh shell scripts.

$(usage)
Options:
 -h:
  Prints this help message.
 -v:
  Give verbose information about what the script is doing.
  For example, print the commands used to do it's work. Supply this
  option multiple times to increase verbosity further.
EOF
}

main() {
    if "$getopt" -n "$prog" -o hva:bc -- -a arg -h -- -c >/dev/null 2>&1 ; then
        opts="$("$getopt" -n "$prog" -o "hv" -- "$@")"
        eval set -- "$opts"
        while true ; do
            case "$1" in
                -h) help=1 ;;
                -v) verbose=$(( $verbose + 1 )) ;;
                --) shift ; break ;;
                *) die "Unknown option $1" ;;
            esac
            shift
        done
    else
        warning "$getopt failed. Only taking options from the environment."
    fi
    echo "XXX implementation missing" >&2
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
