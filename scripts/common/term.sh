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
prefix="${GAV_PREFIX:-$HOME}"
lf="
"
getopt="${getopt-getopt}"
verbose="${verbose-0}"

dryrun="${dryrun:-}"
tmpdir="${tmpdir:-${HOME}/.tmp}"

TEXTDOMAIN="$prog" ; export TEXTDOMAIN
TEXTDOMAINDIR="${prefix}/share/locale/sh/" ; export TEXTDOMAINDIR
have() { type -- "$@" >/dev/null 2>&1 ; }
if ! have gettext.sh ; then
    if (! have fallback_eval_gettext) || (! have fallback_eval_ngettext) ; then
        echo "$(gettext "error: fallback_eval_(n)gettext are required.")"
        # don't exit: they mightn't be used
    fi
    gettext() { echo "$1" ; }
    eval_gettext() { fallback_eval_gettext "$@" ; }
    ngettext() { if test "$3" = "1" ; then echo "$1" ; else echo "$2" ; fi ; }
    eval_ngettext() { fallback_eval_ngettext "$@" ; }
fi

set -e
set -u

usage() {
    echo "$(eval_gettext "usage: \${prog} <session-name>")"
}
help() {
    cat <<EOF
$(gettext "Copyright (c) 2011 Gavin Beatty <gavinbeatty@gmail.com>")
$(gettext "Licensed under the MIT license: http://www.opensource.org/licenses/MIT")

$(gettext "starts a terminal session using dtach and dvtm.")

$(usage)
$(gettext "Options:")
 -h:
  $(gettext "Prints this help message.")
 -v:
  $(gettext "Give verbose information about what the script is doing.\${lf}For example, print the commands used to do it's work. Supply this\${lf}option multiple times to increase verbosity further.")
EOF
}
echodo() { echo "$@" ; sleep 1 ; "$@" ; }
dodo() { "$@" ; }

main() {
#     check_deps have sleep
#     check_deps have_file "${prefix}/somefile.txt"

    opts="$("$getopt" -n "$prog" -o "hvnt:" -- "$@")"
    eval set -- "$opts"

    echoecho="dodo"
    echodo="dodo"
    while true ; do
        case "$1" in
            -h) help ; exit 0 ; ;;
            -v) verbose=$(( $verbose + 1 )) ; ;;
            -n) dryrun=1 ; verbose=1 ; ;;
            -t) tmpdir="$2" ; shift ; ;;
            --) shift ; break ; ;;
            *) echo "error: unknown option $1" >&2 ; exit 1 ; ;;
        esac
        shift
    done
    if test $verbose -gt 0 ; then
        echodo="echodo"
        echoecho="echo"
    fi
    if test -n "$dryrun" ; then echodo="echo" ; fi
    if test $# -eq 0 ; then
        session_name="$(id -un)"
    else
        session_name="$1"
    fi
    #$echodo dtach -A "${tmpdir}/${session_name}" -e '^B' -r winch dvtm
    e=0
    $echoecho tmux has-session -t "$session_name" 2>/dev/null || e=$?
    if test $e -eq 0 ; then $echodo tmux attach -t "$session_name"
    else $echodo tmux new -s "$session_name" ; fi
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
