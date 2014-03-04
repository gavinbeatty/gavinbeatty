#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (C) 2007, 2008, 2011 by Gavin Beatty
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
set -u
set -e

prog="$(basename -- "$0")"
prefix="${PREFIX-/usr/local}"
lf="
"
getopt="${getopt-getopt}"
#verbose="${verbose-0}"

have() { type "$@" >/dev/null 2>&1 ; }

TEXTDOMAIN="$prog" ; export TEXTDOMAIN
TEXTDOMAINDIR="${prefix}/share/locale/sh/" ; export TEXTDOMAINDIR
if ! have gettext.sh ; then
    gettext() { printf "%s" "$@" ; }
    eval_gettext() { fallback_eval_gettext "$@" ; }
    # no need for ngettext etc.
else
    set +u
    set +e
    . gettext.sh
    set -e
    set -u
fi

usage() {
    echo "$(eval_gettext "usage: \${prog} [-p <prefix>] [-s <suffix>] [-d]")"
}
help() {
    cat <<EOF
$(gettext "Copyright (C) 2007, 2008, 2011 Gavin Beatty <gavinbeatty@gmail.com>")
$(gettext "Licensed under the MIT license: http://www.opensource.org/licenses/MIT")

$(gettext "Creates a temporary file/directory.")

$(usage)

$(gettext "Options:")
 -h:
   $(gettext "Prints this help message.")
 -p <prefix>:
   $(gettext "Specify a prefix to give the desired file/directory.")
 -s <suffix>:
   $(eval_gettext "Specify a suffix to give the desired file/directory.\${lf}   WARNING: The file/directory will not be created as atomically if a\${lf}   suffix is given. For all uses except the most security critical,\${lf}   this should not be a concern.")
 -d:
   $(gettext "Create a directory instead of a file.")
EOF
}

tmp_prefix="${tmp_prefix-}"
suffix="${suffix-}"
dir="${dir-}"

############################
## User created functions ##
############################
mymktemp_impl_() {
    local opt=
    if test -n "$dir" ; then opt="-d" ; fi
    mktemp $opt "${tmp_prefix}XXXXXXXX"
}

main() {
    if ! have mktemp ; then
        echo "$(gettext "error: Please install mktemp")"
        exit 1
    fi

    opts="$("$getopt" -n "$prog" -o "hb:dp:s:" --  "$@")"
    eval set -- "$opts"

    while true ; do
        case "$1" in
        -h) help ; exit 0 ; ;;
        -d) dir=1 ; ;;
        -p) tmp_prefix="$2" ; shift ; ;;
        -s) suffix="$2" ; shift ; ;;
        --) shift ; break ; ;;
        *)
            o="$1"
            echo "$(eval_gettext "error: Unknown option \${o}")" >&2
            exit 1
            ;;
        esac
        shift
    done
    if test $# -gt 0 ; then
        echo "$(gettext "error: Expected zero arguments")" >&2
        exit 1
    fi
    e=0
    t="$(mymktemp_impl_ "$@")" || e=$?
    if test $e -eq 0 ; then
        if test -n "$suffix" ; then
            mv -- "$t" "${t}$suffix" || e=$?
            if test $e -eq 0 ; then
                t="${t}$suffix"
            fi
        fi
    fi
    echo "$t"
    exit $e
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
