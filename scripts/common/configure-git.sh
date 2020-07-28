#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (c) 2007, 2008, 2009, 2010, 2011, 2012, 2013 by Gavin Beatty
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
set -u
set -e
trap "echo Caught SIGINT >&2 ; exit 1 ; " INT
trap "echo Caught SIGTERM >&2 ; exit 1 ; " TERM

default_name="Gavin Beatty"
default_email="public@gavinbeatty.com"
default_work_email="gavinbeatty@optiver.us"
default_excludesfile="$HOME/.gitignore"
default_attributesfile="$HOME/.gitattributes"

no_getopt_warning="${NO_GETOPT_WARNING:-}"
getopt="${GETOPT:-getopt}"
verbose="${CONFIGURE_GIT_VERBOSE:-0}"
dryrun="${CONFIGURE_GIT_DRYRUN:-}"
help=${CONFIGURE_GIT_HELP:-}
list=${CONFIGURE_GIT_LIST:-}
name=${CONFIGURE_GIT_NAME:-$default_name}
email=${CONFIGURE_GIT_EMAIL:-$default_email}
environment="${CONFIGURE_GIT_ENVIRONMENT:-}"
excludesfile=${CONFIGURE_GIT_EXCLUDESFILE:-$default_excludesfile}
attributesfile=${CONFIGURE_GIT_ATTRIBUTESFILE:-$default_attributesfile}
sections=${CONFIGURE_GIT_SECTIONS:-all}
configfile=${CONFIGURE_GIT_CONFIGFILE:-}
configtype=${CONFIGURE_GIT_CONFIGTYPE:---global}
pager="${CONFIGURE_GIT_PAGER:-}"
test -n "$pager" || pager="${GIT_PAGER:-}"
test -n "$pager" || pager="${PAGER:-less}"
git="${CONFIGURE_GIT_GIT:-git}"

prog="configure-git.sh"

say() { printf "%s\n" "$*" ; }
die() { printf "error: %s\n" "$*" >&2 ; exit 1 ; }
verbose() {
    if test "$verbose" -ge "$1" ; then
        shift
        say "verbose: $*" >&2
    fi
}
go() { test -n "$dryrun" || "$@" ; }
have() { type "$@" >/dev/null 2>&1 ; }
havefirst() { test $# -gt 0 && type "$1" >/dev/null 2>&1 ; }

if ! have sed ; then die "sed is required." ; fi

usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-v] [-L]
   or: $prog [-S <sections>] [-s|-l|-f <configfile>] [-x <excludesfile>] [-n <name>] [-e <email>] [-w]
EOF
}
help() {
    cat <<EOF
Configure git to use modern preferences.

$(usage)

Options:
 -h                     prints this help message.
 -v                     give verbose information about what the script is
                          doing. For example, print the commands used to do
                          its work. Supply this option multiple times to
                          increase verbosity further.
 -t                     run a dry ryn. No changes are actually made. Implies
                          -v.
 -L                     prints the list of accepted <sections> and exits.
                          The list printed is the equivalent to the special
                          section, "all".
 -S <sections>          configures only the given <sections>, which is a
                          comma-separated list.
 -s                     configures the "system" git config file. If none of
                          -s, -l, -f <configfile> are given, the "global"
                          git config file is used.
 -l                     configures the "local" git config file. If none of
                          -s, -l, -f <configfile> are given, the "global"
                          git config file is used.
 -f <configfile>        configures the given <configfile>. If none of -s,
                          -l, -f <configfile> are given, the "global" git
                          config file is used.
 -x <excludesfile>      configure the given <excludesfile> as the global
                          exclude file, instead of the default,
                          $default_excludesfile.
 -n <name>              use the given <name> instead of the default,
                          $default_name.
 -e                     use the given <email> instead of the default,
                          $default_email.
 -w                     use the "work" variant of e-mail,
                          $default_work_email.
 -E                     use name and email provided from the environment using
                          \$FULLNAME and \$EMAIL.
 -g <git>               use the provided <git> instead of "git".
EOF
}
git_required_version=$((1 * 100 + 5 * 10 + 0))
git_required_version_str="1.5.0"

gitconfig() {
    if test -n "$configfile" ; then
        verbose 1 $git config -f "$configfile" -- "$@"
        go $git config -f "$configfile" -- "$@"
    else
        verbose 1 $git config "$configtype" -- "$@"
        go $git config "$configtype" -- "$@"
    fi
}
user_section() {
    gitconfig user.name "$name"
    gitconfig user.email "$email"
}
mail_section() {
# this so I can submit patches using git send-email
    gitconfig sendemail.aliasesfile ~/.gitaliases
    gitconfig sendemail.aliasfiletype mailrc
}
color_section() {
    gitconfig color.ui "auto"
}
diff_section() {
    gitconfig diff.colorMoved "default"
    gitconfig diff.colorMovedWS "allow-indentation-change"
    if type icdiff >/dev/null 2>/dev/null ; then
        gitconfig diff.icdiff.cmd 'icdiff -H -N -U 10 --strip-trailing-cr $LOCAL $REMOTE | less'
    fi
    gitconfig diff.renameLimit "1000"
}
core_section() {
    ! test -r "$excludesfile" || gitconfig core.excludesfile "$excludesfile"
    ! test -r "$attributesfile" || gitconfig core.attributesfile "$attributesfile"
    gitconfig push.default simple
    gitconfig merge.defaultToUpstream true
}
interactive_section() {
    gitconfig grep.lineNumber true
}
pager_section() {
    if type "$pager" >/dev/null 2>/dev/null ; then
        gitconfig core.pager "$pager"
        if type diff-highlight >/dev/null 2>/dev/null ; then
            gitconfig pager.diff "diff-highlight | $pager"
            gitconfig pager.log "diff-highlight | $pager"
            gitconfig pager.show "diff-highlight | $pager"
        fi
        gitconfig pager.difftool "$pager"
    fi
}
alias_section() {
    gitconfig alias.st "status"
    gitconfig alias.a "add -v"
    gitconfig alias.co "checkout"
    gitconfig alias.ci "commit"
    gitconfig alias.cia "commit -a"
    gitconfig alias.get "fetch -v -p"
    gitconfig alias.rclone "clone --recursive"
    gitconfig alias.prebase "pull --rebase"
    gitconfig alias.rebaseup "rebase -i @{u}"
    gitconfig alias.mergenoff "merge --no-ff"
    gitconfig alias.noff "merge --no-ff"
    gitconfig alias.ff "merge --ff"
    gitconfig alias.cpick "cherry-pick"
    gitconfig alias.wk "worktree"
    gitconfig alias.br "branch -v"
    gitconfig alias.thisbr "thisbranch"
    gitconfig alias.rbr "remotebranch"
    gitconfig alias.bigdiff "diff --find-copies-harder -B -C"
    gitconfig alias.bindiff "diff --binary"
    gitconfig alias.cdiff "diff --cached"
    gitconfig alias.unstage "reset HEAD --"
    gitconfig alias.sm "submodule"
    gitconfig alias.tags "-p for-each-ref --sort=-creatordate --format=\"%(refname:short) %(creatordate:short) %(subject)\" refs/tags"
    gitconfig alias.r "remote -v"
    gitconfig alias.ll "log -v --stat"
    gitconfig alias.l "log --pretty=format:'%C(auto)%h %cd %s' --date=short --decorate=short"
    gitconfig alias.gl "log --graph --pretty=format:'%C(auto)%h %cd %s' --date=short --decorate --stat"
    gitconfig alias.lol "log --graph --pretty=format:'%C(auto)%h %cd %s' --date=short --decorate --abbrev-commit"
    gitconfig alias.lola "log --graph --pretty=format:'%C(auto)%h %cd %s' --date=short --decorate --abbrev-commit --all"
    gitconfig alias.ignored "ls-files --others -i --exclude-standard"
    gitconfig alias.standup "log --pretty=format:'%Cred%h%Creset -%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --since yesterday --author '$name'"
    gitconfig alias.alias "config --get-regexp '^alias\.'"
}
is_windows() {
    local os="$(uname -o 2>/dev/null || true)"
    os="$(say "$os" | tr A-Z a-z)"
    if test -z "$os" || say "$os" | grep -q '^\(msys\|cygwin\|win\)' ; then
        return 0
    fi
    return 1
}
credential_section() {
    if is_windows ; then
        gitconfig credential.helper manager
    else
        gitconfig credential.helper cache
    fi
}
tag_section() {
    gitconfig tag.sort creatordate
}
getopt_name_works() {
    $getopt -n "foo" -o a:b -- 2>/dev/null | grep -q '^ *-- *$'
}
getopt_works() {
    $getopt -o a:b -- -b -a foo 2>/dev/null | grep -q "^ *-b -a '\?foo'\? -- *\$"
}
getopt_long_works() {
    local e=0
    $getopt -T >/dev/null 2>&1 || e=$?
    test $e -eq 4
}

main() {
    if havefirst $getopt && getopt_works ; then
        local e=0
        local getoptname=
        if getopt_name_works ; then
            getoptname="-n $prog"
        fi
        local getoptlongopts=
        if getopt_long_works ; then
            getoptlongopts="-l help,verbose,dry-run,list,name:,email:,e-mail:"
            getoptlongopts="${getoptlongopts},work,environment,excludesfile:,sections:"
            getoptlongopts="${getoptlongopts},system,local,configfile:,git:"
        fi
        e=0
        opts="$($getopt $getoptname -o "hvtLn:e:wEx:S:slf:g:" $getoptlongopts -- "$@")" || exit 1
        eval set -- "$opts"

        while test $# -gt 0 ; do
            case "$1" in
                -h|--help) help=1 ;;
                -v|--verbose) verbose=$((verbose + 1)) ;;
                -t|--dry-run) dryrun=1 ;;
                -L|--list) list=1 ;;
                -n|--name) name=$2 ; shift ;;
                -e|--email) email=$2 ; shift ;;
                -w|--work) email=$default_work_email ;;
                -E|--environment) environment=1 ; name="${FULLNAME:-$name}" ; email="${EMAIL:-$email}" ;;
                -x|--excludesfile) excludesfile=$2 ; shift ;;
                -S|--sections) sections=$2 ; shift ;;
                -s|--system) configtype=--system ;;
                -l|--local) configtype=--local ;;
                -f|--configfile) configfile=$2 ; shift ;;
                -g|--git) git=$2 ; shift ;;
                --) shift ; break ;;
                *) exit 1 ;;
            esac
            shift
        done
    else
        if test -n "$environment" ; then
            name="${FULLNAME:-$name}"
            email="${EMAIL:-$email}"
        fi
        if test -z "$no_getopt_warning" ; then
            say "warning: getopt \`$getopt' does not work. Options taken from environment." >&2
        fi
    fi
    if test $# -ne 0 ; then usage >&2 ; die "Unrecognized arguments: $@" ; fi
    if say "$name" | grep -Fq \' ; then
        die "Invalid characters in name, ${name}."
    fi
    if test -n "$dryrun" ; then
        verbose=$((verbose + 1))
    fi
    if test -n "$help" ; then help ; exit 0 ; fi

    if test -n "$list" ; then
        echo "user,mail,core,interactive,pager,alias,diff,color,credential,tag"
        exit 0
    fi

    if ! havefirst $git ; then die "$git is required." ; fi

    git_version=0
    git_version_str="$($git --version | sed 's/^git version //' | sed 's/\./ /g')"
    set -- $git_version_str
    git_version=$(( ${1:-0} * 100 + ${2:-0} * 10 + ${3:-0} ))
    if test "${git_version:-0}" -lt "$git_required_version" ; then
        die "git version ($git_version) >= $git_required_version_str is required"
    fi

    sections=$(echo "$sections" | tr '[:upper:]' '[:lower:]' | sed -e 's/[ 	]*[,+|][ 	]*/ /g')
    for sec in $sections ; do
        case "$sec" in
        user) user_section ;;
        mail) mail_section ;;
        core) core_section ;;
        interactive) interactive_section ;;
        pager) pager_section ;;
        alias) alias_section ;;
        diff) diff_section ;;
        color) color_section ;;
        credential) credential_section ;;
        tag) tag_section ;;
        all) user_section
            mail_section
            core_section
            interactive_section
            pager_section
            alias_section
            diff_section
            color_section
            credential_section
            tag_section
            ;;
        *)
            die "Unknown section: $sec"
            ;;
        esac
    done
}
main "$@"
