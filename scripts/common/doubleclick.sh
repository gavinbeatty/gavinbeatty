#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (c) 2009, 2011 by Gavin Beatty
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

have() { type "$@" >/dev/null 2>&1 ; }

TEXTDOMAIN="$prog" ; export TEXTDOMAIN
TEXTDOMAINDIR="${prefix}/share/locale/sh/" ; export TEXTDOMAINDIR
if ! have gettext.sh ; then
    gettext() { printf "%s" "$@" ; }
    eval_gettext() { fallback_eval_gettext "$@" ; }
else
    set +e
    set +u
    . gettext.sh
    set -u
    set -e
fi

usage() {
    echo "$(eval_gettext "usage: \${prog} <arg>...")"
}
help() {
    cat <<EOF
$(gettext "Copyright (c) 2009, 2011 Gavin Beatty <gavinbeatty@gmail.com>")
$(gettext "Licensed under the MIT license: http://www.opensource.org/licenses/MIT")

$(gettext "Opens files, directories etc. as though they were \"double clicked\".")

$(usage)
$(gettext "Options:")
 -h:
  $(gettext "Prints this help message.")
 -v:
  $(gettext "Give verbose information about what the script is doing.\${lf}For example, print the commands used to do it's work. Supply this\${lf}option multiple times to increase verbosity further.")
EOF
}

error_unknown_session() {
    local s="${1-}"
    if test -n "$s" ; then
        echo "$(eval_gettext "error: Unknown session type: \${s}")" >&2
    else
        echo "$(gettext "error: Unknown session type.")" >&2
    fi
    exit 1
}
error_no_args() {
    usage >&2
    echo "$(gettext "error: Must give at least one argument.")" >&2
    exit 1
}
error_unknown_opt() {
    local o="$1"
    usage >&2
    echo "$(gettext "error: Unknown option: \${o}")" >&2
    exit 1
}


main() {
    main_opts="$("$getopt" -n "$prog" -o "hv" -- "$@")"
    eval set -- "$main_opts"

    while true ; do
        case "$1" in
            -h)
                help
                exit 0
                ;;
            -v)
                echo "$version"
                exit 0
                ;;
            -v)
                verbose=$(( verbose + 1 ))
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                error_unknown_opt "$1"
                ;;
        esac
    done

    if test $# -eq 0 ; then
        error_no_args
    fi
    if test -n "${DESKTOP_LAUNCH:-}" ; then
        "$DESKTOP_LAUNCH" "$@"
    else
        DESKTOP_SESSION="${DESKTOP_SESSION:-}"
        if (have uname) && (uname | grep -Fiq "darwin") ; then
            open "$@"
        elif (test "$DESKTOP_SESSION" = "gnome") || (test -n "${GNOME_DESKTOP_SESSION_ID-}") ; then
            gnome-open "$@"
        elif (test "$DESKTOP_SESSION" = "kde") || (test -n "${KDE_SESSION-}") ; then
            kfmclient exec "$@"
        else
            error_unknown_session "$DESKTOP_SESSION"
        fi
    fi
}
trap "echo Caught SIGINT >&2 ; exit 1 ; " INT
trap "echo Caught SIGTERM >&2 ; exit ; " TERM
main "$@"
