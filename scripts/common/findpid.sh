#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (C) 2008, 2012 by Gavin Beatty
# <public@gavinbeatty.com>
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

die() { echo "error: $@" >&2 ; exit 1 ; }
have() { type "$@" >/dev/null 2>&1 ; }
help() {
    cat <<EOF
Copyright (C) 2008, 2012 by Gavin Beatty
<public@gavinbeatty.com>

Print the command line for a <pid>.

$(usage)
EOF
}
usage() {
    echo "usage: $prog <pid>"
}
error_no_pid_arg() {
    usage >&2
    die "Must give one \${CARG}<pid>\${COFF} argument."
}
error_no_such_pid() {
    die "There is no process with a <pid> of $1."
}
error_invalid_pid() {
    die "Invalid <pid> argument, $1: must be an integer greater than 0."
}

main() {
    if ! have print0 ; then
        die "Please install print0"
    fi
    if test $# -ne 1 ; then
        error_no_pid_arg
    fi
    pid_arg="$1"
    if ! test "$pid_arg" -gt 0 ; then
        error_invalid_pid "$pid_arg"
    fi
    cmdline="/proc/${pid_arg}/cmdline"
    if ! test -r "$cmdline" ; then
        error_no_such_pid "$pid_arg"
    fi
    print0 "$cmdline"
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
