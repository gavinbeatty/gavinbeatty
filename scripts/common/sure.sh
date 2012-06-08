#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (C) 2012 by Gavin Beatty
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
getopt="${getopt-getopt}"
have() { type "$@" >/dev/null 2>&1 ; }

case "$prog" in
sureno.sh)
    short_descr="Prints an \"are your sure you want to ... [yN]\" message and runs based on the user's input. The default answer is N."
    yesno_default="[yN]"
    yes_test() {
        yes_test_return=0
        expr "$1" : "[yY]" >/dev/null 2>&1 || yes_test_return=$?
        return "$yes_test_return"
    }
    ;;
sureyes.sh)
    short_descr="Prints an \"Are your sure you want to ... [Yn]\" message and runs based on the user's input. The default answer is Y."
    yesno_default="[Yn]"
    yes_test() {
        yes_test_return=0
        ! expr "$1" : ".*[nN].*" >/dev/null 2>&1 || yes_test_return=$?
        return "$yes_test_return"
    }
    ;;
*)
    echo "error: Unknown name for this program. Please install as either \`sureno.sh' or \`sureyes.sh'." >&2
    exit 1
    ;;
esac
main() {
    if ! have "shellquote" ; then
        shellquote() { echo "$@" ; }
    fi

    if have "$getopt" ; then
        opts="$("$getopt" -n "$prog" -o "h" -- "$@")"
        eval set -- "$opts"

        while true ; do
            case "$1" in
            -h) help ; exit 0 ;;
            --) shift ; break ; ;;
            *) echo "error: Unknown option $1" >&2 ; exit 1 ; ;;
            esac
            shift
        done
    fi
    if test $# -eq 0 ; then
        echo "error: Must give one <command> argument." >&2
        exit 1
    fi
    printf "${prog}: Are you sure you want to: $(shellquote "$@")"
    read -p "? ${yesno_default}: " yesno
    yes_test "$yesno" || exit $?
    exit 0
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
