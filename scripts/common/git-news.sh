#!/bin/sh
# vi: set ft=sh et sw=4 ts=4 tw=80:
# git-news: Log what's new in the remote tracking branch, or vice-versa.
# Copyright (c) 2012, 2013 Gavin Beatty <public@gavinbeatty.com>
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
set -e
set -u
pax() { trap '' 0 ; exit "$@" ; }
die() { echo "error: $@" >&2 ; pax 1 ; }
udie() { usage >&2 ; die "$@" ; }
trap ' die Caught SIGINT ; ' INT
trap ' die Caught SIGTERM ; ' TERM
trap ' echo Unexpected exit >&2 ; exit 1 ; ' 0
prog="$(basename -- "$0")"
subprog="${prog##git-}"
niceprog="git $subprog"
test "$prog" != "$subprog" || niceprog="$prog"
usage() {
    cat <<EOF
$prog: Log what's new in the remote tracking branch, or vice-versa.
usage: $niceprog [options] -- [<command>]
    -r, --remote    find changes from remote not in local (HEAD..remote) (default)
    -l, --local     find changes from local not in remote (remote..HEAD)
    -B, --branch <branch>
                    use <branch> for comparison (current branch is the default)
    -c, --chrono    list the changes in chronological order (default)
    -N, --new       list the changes, newest first
    -u, --uni       news in b since last merge base (HEAD..remote) (unidirectional) (default)
    -b, --bi        all differences since last merge base (HEAD...remote) (bidirectional)
    --stat[=<arg>]  when the command is log, passed along directly
    -p, --patch     when the command is log, pass -p (to show the diffs as well)
    -n, --dry-run   print the final command, but don't execute it
    -v, --verbose   print and execute the final command
EOF
}
testrun=
verbose=
reverse=
newest=
branch=
dir=..
extra=
command=
stat=
patch=
args=0
odone=
arg() {
    if test "$args" -eq 0 ; then args=1 ; command="$1"
    else udie "Too many arguments." ; fi
}
while test $# -gt 0 ; do
    if test -z "$odone" ; then
        case "$1" in
            -n|--dry-run) testrun=1 ; verbose=1 ;;
            -v|--verbose) verbose=1 ;;
            -r|--remote) reverse= ;;
            -l|--local) reverse=1 ;;
            -B|--branch)
                test $# -ge 2 || udie "Missing <branch> argument for ${1}."
                branch="$2" ; shift ;;
            --branch=*) branch="${1#--branch=}" ;;
            -c|--chrono|--chronological|--old|--oldest|--oldest-first) newest= ;;
            -N|--reverse-chrono|--reverse-chronological|--new|--newest|--newest-first) newest=1 ;;
            -u|--uni|--unidi|--unidir|--unidirectional) dir=.. ; extra= ;;
            -b|--bi|--bidi|--bidir|--bidirectional) dir=... ; extra="--left-right" ;;
            --stat|--stat=*) stat="$1" ;;
            -p|--patch) patch=1 ;;
            -h|-\?|--help) usage ; pax ;; # but not much point in --help since git catches it
            --) odone=1 ;;
            -) arg "$1" ;;
            -*) udie "Unrecognized option, $1." ;;
            *) arg "$1" ;;
        esac
    elif test "$args" -eq 0 ; then args=1 ; command="$1"
    else break ; fi
    shift
done
if echo "$stat" | grep -Fq " " ; then
    udie "Invalid --stat argument, $stat."
fi
go() {
    if test -n "$verbose" ; then echo "$*" ; fi
    if test -z "$testrun" ; then trap '' 0 ; exec "$@" ; fi
}
if test -z "$branch" ; then
    branch="$(git rev-parse --abbrev-ref HEAD)"
    if test "$branch" = HEAD ; then
        die "Not on any branch so I cannot find the remote branch."
    fi
fi
r="$(git config branch."$branch".remote)" || die "No remote for ${branch}."
rbr_="$(git config branch."$branch".merge)" || die "No remote branch for ${branch}."
rbranch="${rbr_##refs/heads/}"
test "$rbranch" != "$rbr_" || die "Expected remote branch $rbr_ to be in refs/heads/."
command="${command:-log}"
if test "$command" = log ; then
    if test -n "$patch" ; then extra="$extra -p" ; fi
    if test -n "$stat" ; then extra="$extra $stat" ; fi
fi
if test -z "$newest" ; then extra="$extra --reverse" ; fi
if test -n "$reverse" ; then
    go git "$command" $extra "$@" "${r}/$rbranch"$dir
else
    go git "$command" $extra "$@" $dir"${r}/$rbranch"
fi
if test -n "$testrun" ; then pax ; fi
