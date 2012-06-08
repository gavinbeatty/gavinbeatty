#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:

###########################################################################
# Copyright (c) 2011, 2012 Gavin Beatty                     
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
getopt="${TERM_GETOPT-getopt}"
help="${TERM_HELP:-}"
verbose="${TERM_VERBOSE-0}"
dryrun="${TERM_DRYRUN:-}"
sleep="${TERM_SLEEP:-2}"

tmpdir="${TMPDIR:-${HOME}/.tmp}"

justdo="justdo"
cleardo="justdo"

usage() { echo "usage: $prog <session-name>" ; }
help() {
    cat <<EOF
Copyright (c) 2011, 2012 Gavin Beatty <gavinbeatty@gmail.com>
Licensed under the MIT license: http://www.opensource.org/licenses/MIT

starts a terminal session using dtach and dvtm.

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
have() { type "$@" >/dev/null 2>&1 ; }
echodo() { echo "$@" ; "$@" ; }
echosleepdo() { echo "$@" ; sleep "$sleep" ; "$@" ; }
justdo() { "$@" ; }

main() {
    if "$getopt" -n "$prog" -o "fooa:bc:" -- -a b -b -ofo >/dev/null 2>&1 ; then
        opts="$("$getopt" -n "$prog" -o "hvnt:" -- "$@")"
        eval set -- "$opts"
        while true ; do
            case "$1" in
                -h) help=1 ;;
                -v) verbose=$(( $verbose + 1 )) ;;
                -n) dryrun=1 ; verbose=1 ;;
                -t) tmpdir="$2" ; shift ;;
                --) shift ; break ;;
                *) echo "error: unknown option $1" >&2 ; exit 1 ;;
            esac
            shift
        done
    else
        warning "Only taking options from the environment."
    fi
    test -z "$help" || { help ; exit 0 ; }

    if test $verbose -gt 0 ; then
        justdo="echodo"
        cleardo="echosleepdo"
    fi
    if test -n "$dryrun" ; then cleardo="echo" ; fi
    if test $# -eq 0 ; then
        session_name="$(id -un)"
    else
        session_name="$1"
    fi
    ## dtach-dvtm implementation
    #$echodo dtach -A "${tmpdir}/${session_name}" -e '^B' -r winch dvtm
    e=0
    $justdo tmux has-session -t "$session_name" 2>/dev/null || e=$?
    if test $e -eq 0 ; then
        $cleardo tmux attach -t "$session_name"
    else
        $cleardo tmux new -s "$session_name"
    fi
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
