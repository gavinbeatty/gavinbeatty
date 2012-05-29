#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (c) 2007, 2008, 2009, 2010, 2011 by Gavin Beatty
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

version="3.0"

getopt="${getopt-getopt}"
verbose="${verbose-0}"
dryrun="${dryrun-}"

prog="$(basename -- "$0")"
prefix="${GAV_PREFIX:-$HOME}"
lf="
"

TEXTDOMAIN="$prog" ; export TEXTDOMAIN
TEXTDOMAINDIR="${prefix}/share/locale/sh/" ; export TEXTDOMAINDIR
have() { type -- "$@" >/dev/null 2>&1 ; }
if have gettext.sh ; then
    set +e
    set +u
    . gettext.sh
    set -u
    set -e
else
    if (! have fallback_eval_gettext) || (! have fallback_eval_ngettext) ; then
        echo "$(gettext "error: fallback_eval_(n)gettext are required.")"
        # don't exit: they mightn't be used
    fi
    gettext() { echo "$1" ; }
    eval_gettext() { fallback_eval_gettext "$@" ; }
    ngettext() { if test "$3" = "1" ; then echo "$1" ; else echo "$2" ; fi ; }
    eval_ngettext() { fallback_eval_ngettext "$@" ; }
fi
if ! have sed ; then
    echo "$(gettext "error: sed is required.")" >&2
    exit 1
fi
if ! have git ; then
    echo "$(gettext "error: git is required.")" >&2
    exit 1
fi

usage() {
    echo "$(gettext "usage: ${prog} [-v] [-n]")"
}
help() {
    cat <<EOF
$(gettext "Copyright (c) 2007, 2008, 2009, 2010, 2011 by Gavin Beatty <gavinbeatty@gmail.com>")
$(gettext "Licensed under the MIT license: http://www.opensource.org/licenses/MIT")

$(gettext "Configure git to use modern preferences.")

$(usage)

$(gettext "Options:")
 -h:
  $(gettext "Prints this help message.")
 -V:
  $(gettext "Prints the version number.")
 -v:
  $(eval_gettext "Give verbose information about what the script is doing. For example,\${lf}  print the commands used to do it's work. Supply this option multiple\${lf}  times to increase verbosity further.")
EOF
}
echodo() {
    echo "$@"
    "$@"
}
git_required_version=$((1 * 100 + 5 * 10 + 0))
git_required_version_str="1.5.0"

error_git_version() {
    v="$1"
    r="$git_required_version_str"
    echo "$(eval_gettext "error: \`git' version \`\${v}' is not supported. version >= \`\${r}' is required.")"
    exit 1
}
main() {
    if have "$getopt" ; then
        e=0
        opts="$("$getopt" -n "$prog" -o "hVvn" -- "$@")" || e=$?
        if test $e -ne 0 ; then exit 1 ; fi
        eval set -- "$opts"

        while true ; do
            case "$1" in
                -h) help ; exit 0 ; ;;
                -V) echo "$version" ; exit 0 ; ;;
                -v) verbose=$(( $verbose + 1 )) ; ;;
                -n) dryrun=1 ; verbose=$(( $verbose + 1 )) ; ;;
                --) shift ; break ; ;;
                *) exit 1 ; ;;
            esac
            shift
        done
    fi

    git_version=0
    git_version_str="$(git --version | sed 's/^git version //' | sed 's/\./ /g')"
    set -- $git_version_str
    git_version=$((${1:-0} * 100 + ${2:-0} * 10 + ${3:-0}))
    if test "${git_version:-0}" -lt "$git_required_version" ; then
        echo "error: git version ($git_version) >= $git_required_version is required" >&2
        exit 1
    fi

    echodo=""
    if test "$verbose" -ge 1 ; then echodo="echodo" ; fi
    if test -n "$dryrun" ; then echodo="echo" ; fi

# personalize these with your own name and email address
    if test -n "${FULLNAME-}" ; then
        $echodo git config --global user.name "$FULLNAME"
    else
        echo "warning: \$FULLNAME has not been set" >&2
    fi
    if test -n "${EMAIL-}" ; then
        $echodo git config --global user.email "$EMAIL"
    else
        echo "warning: \$EMAIL has not been set" >&2
    fi
    if test -n "${GPG_KEY_ID-}" ; then
        $echodo git config --global user.signingkey "$GPG_KEY_ID"
    fi

# colorize output
    $echodo git config --global color.status auto
    $echodo git config --global color.diff auto
    $echodo git config --global color.branch auto

# shortcut aliases
    $echodo git config --global alias.st "status"
    $echodo git config --global alias.ci "commit"
    $echodo git config --global alias.cis "commit -s"
    $echodo git config --global alias.cia "commit -a"
    $echodo git config --global alias.cias "commit -a -s"
    $echodo git config --global alias.co "checkout"
    $echodo git config --global alias.br "branch"
    $echodo git config --global alias.a  "add -v"
    $echodo git config --global alias.l  "log --stat"
    $echodo git config --global alias.bigdiff "diff --find-copies-harder -B -C"
    $echodo git config --global alias.bdiff "diff --binary"
    $echodo git config --global alias.cdiff "diff --cached"
    $echodo git config --global alias.dstat "diff --stat"
    $echodo git config --global alias.cpick "cherry-pick"
    $echodo git config --global alias.unstage "reset HEAD"
    $echodo git config --global alias.get "fetch -v"
    $echodo git config --global alias.sm "submodule"

# this so I can submit patches using git send-email
    $echodo git config --global sendemail.smtpserver smtp.gmail.com
    $echodo git config --global sendemail.aliasesfile ~/.gitaliases
    $echodo git config --global sendemail.aliasfiletype mailrc

# global ignore file to keep repetition down
    $echodo git config --global core.excludesfile ~/.gitignore

# turn on new 1.5 features which break backwards compatibility
    $echodo git config --global core.legacyheaders false
    $echodo git config --global repack.usedeltabaseoffset true

# warnings appear in 1.6 if not set (we set to default = current)
    $echodo git config --global push.default current
}
trap "echo Caught SIGINT >&2 ; exit 1 ; " INT
trap "echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
