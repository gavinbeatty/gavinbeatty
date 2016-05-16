test -z "${bashrc_guard:-}" || return 0
bashrc_guard=1
. ~/.bashrc.pre.sh 2>/dev/null || true

# To the extent possible under law, the author(s) have dedicated all
# copyright and related and neighboring rights to this software to the
# public domain worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along
# with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# ~/.bashrc: executed by bash(1) for interactive shells.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the msys2 mailing list.

# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Shell Options
#
# See man bash for more options...
#
# Don't wait for job termination notification
# set -o notify
#
# Don't use ^D to exit
# set -o ignoreeof
#
# Use case-insensitive filename globbing
# shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
# shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# [[ -f /etc/bash_completion ]] && . /etc/bash_completion

# History Options
#
# Don't put duplicate lines in the history.
# export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Aliases
#
# Some people use a different file for aliases
# if [ -f "${HOME}/.bash_aliases" ]; then
#   source "${HOME}/.bash_aliases"
# fi
#
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
#
# Default to human readable figures
# alias df='df -h'
# alias du='du -h'
#
# Misc :)
# alias less='less -r'                          # raw control characters
# alias whence='type -a'                        # where, of a sort
# alias grep='grep --color'                     # show differences in colour
# alias egrep='egrep --color=auto'              # show differences in colour
# alias fgrep='fgrep --color=auto'              # show differences in colour
#
# Some shortcuts for different directory listings
# alias ls='ls -hF --color=tty'                 # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
# alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #

# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077

# Functions
#
# Some people use a different file for functions
# if [ -f "${HOME}/.bash_functions" ]; then
#   source "${HOME}/.bash_functions"
# fi
#
# Some example functions:
#
# a) function settitle
# settitle ()
# {
#   echo -ne "\e]2;$@\a\e]1;$@\a";
# }
#
# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
# cd_func ()
# {
#   local x2 the_new_dir adir index
#   local -i cnt
#
#   if [[ $1 ==  "--" ]]; then
#     dirs -v
#     return 0
#   fi
#
#   the_new_dir=$1
#   [[ -z $1 ]] && the_new_dir=$HOME
#
#   if [[ ${the_new_dir:0:1} == '-' ]]; then
#     #
#     # Extract dir N from dirs
#     index=${the_new_dir:1}
#     [[ -z $index ]] && index=1
#     adir=$(dirs +$index)
#     [[ -z $adir ]] && return 1
#     the_new_dir=$adir
#   fi
#
#   #
#   # '~' has to be substituted by ${HOME}
#   [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
#
#   #
#   # Now change to the new dir and add to the top of the stack
#   pushd "${the_new_dir}" > /dev/null
#   [[ $? -ne 0 ]] && return 1
#   the_new_dir=$(pwd)
#
#   #
#   # Trim down everything beyond 11th entry
#   popd -n +11 2>/dev/null 1>/dev/null
#
#   #
#   # Remove any other occurence of this dir, skipping the top of the stack
#   for ((cnt=1; cnt <= 10; cnt++)); do
#     x2=$(dirs +${cnt} 2>/dev/null)
#     [[ $? -ne 0 ]] && return 0
#     [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
#     if [[ "${x2}" == "${the_new_dir}" ]]; then
#       popd -n +$cnt 2>/dev/null 1>/dev/null
#       cnt=cnt-1
#     fi
#   done
#
#   return 0
# }
#
# alias cd=cd_func

# Gavin

say() { printf "%s\n" "$*" ; }

export PATH="/bin:/mingw64/bin:${HOME}/.local/bin:${PATH}"
export LANG=en_US.UTF-8
if test "$TERM" = xterm ; then
    export TERM=xterm-256color
fi
if (test -n "$TMUX" || test -n "$SCREEN") && test "$TERM" = xterm-256color ; then
    export TERM=screen-256color
fi
eval $(dircolors -b ~/.dircolors)

isinteractive() { case $- in *i*) return 0 ;; esac ; return 1 ; }
if test "${isinteractive:-0}" -eq 1 || isinteractive ; then
    isinteractive=1
    isay() { printf %s\\n "$*" ; } ; iprintf() { printf "$@" ; }
else
    isinteractive=0
    isay() { true ; } ; iprintf() { true ; }
fi
EDITOR="${VISUAL:-}" ; export EDITOR
SVN_EDITOR="${VISUAL:-}" ; export SVN_EDITOR
UNAME="$(uname 2>/dev/null | tr 'A-Z' 'a-z' 2>/dev/null || true)"
HOST="$(hostname -s 2>/dev/null || true)"
if test -z "$HOST" ; then HOST="$(hostname 2>/dev/null || true)" ; fi

HISTSIZE="30" ; export HISTSIZE

LESS="${LESS:-}"
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*F' ; then LESS="${LESS} -F" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*X' ; then LESS="${LESS} -X" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*R' ; then LESS="${LESS} -R" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*r' ; then LESS="${LESS} -r" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*S' ; then LESS="${LESS} -S" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*x' ; then LESS="${LESS} -x4" ; fi
export LESS
export XARGS=xargs

if type less >/dev/null 2>&1 ; then
    PAGER="less" ; export PAGER
fi

for i_ in vim vi nano pico ; do
    if type "$i_" >/dev/null 2>&1 ; then
        VISUAL="$i_" ; export VISUAL
        break
    fi
done
unset i_

if test "$isinteractive" -ne 0 ; then
    if test -r "${HOME}/.git-completion.bash" ; then
        . "${HOME}/.git-completion.bash"
        git_ps1_() {
            local p="$(__git_ps1 "$@")"
            test -n "$p" || return 1
            printf "%s\n" "$p"
        }
    else
    # taken from git/contrib/completion/git-completion.bash
    #
    # __git_ps1 accepts 0 or 1 arguments (i.e., format string)
    # returns text to add to bash PS1 prompt (includes branch name)
    git_ps1_() {
        local g="$(git rev-parse --git-dir 2>/dev/null)" || return 1
        if [ -n "$g" ]; then
            local r
            local b
            if [ -d "$g/rebase-apply" ]
            then
                if test -f "$g/rebase-apply/rebasing"
                then
                    r="|REBASE"
                elif test -f "$g/rebase-apply/applying"
                then
                    r="|AM"
                else
                    r="|AM/REBASE"
                fi
                b="$(git symbolic-ref HEAD 2>/dev/null)"
            elif [ -f "$g/rebase-merge/interactive" ]
            then
                r="|REBASE-i"
                b="$(cat "$g/rebase-merge/head-name")"
            elif [ -d "$g/rebase-merge" ]
            then
                r="|REBASE-m"
                b="$(cat "$g/rebase-merge/head-name")"
            elif [ -f "$g/MERGE_HEAD" ]
            then
                r="|MERGING"
                b="$(git symbolic-ref HEAD 2>/dev/null)"
            else
                if [ -f "$g/BISECT_LOG" ]
                then
                    r="|BISECTING"
                fi
                if ! b="$(git symbolic-ref HEAD 2>/dev/null)"
                then
                    if ! b="$(git describe --exact-match HEAD 2>/dev/null)"
                    then
                        b="$(cut -c1-7 "$g/HEAD")..."
                    fi
                fi
            fi

            local w
            local i

            if test -n "${GIT_PS1_SHOWDIRTYSTATE-}"; then
                if test "$(git config --bool bash.showDirtyState)" != "false"; then
                    git diff --no-ext-diff --ignore-submodules \
                        --quiet --exit-code || w="*"
                    if git rev-parse --quiet --verify HEAD >/dev/null; then
                        git diff-index --cached --quiet \
                            --ignore-submodules HEAD -- || i="+"
                    else
                        i="#"
                    fi
                fi
            fi
            printf "${1:- (%s)}" "${b##refs/heads/}$w$i$r"
        else return 1
        fi
    }
    fi
    svn_ps1_() {
        if local v="$(LC_ALL=C ${SVN_EXE:-svn} info 2>/dev/null)" ; then
            v="$(say "$v" | perl -ne 'if(/^URL: .*\/(trunk|tags|branches)(\/|$)/){s!^.*/(trunk|tags|branches)(/*$|/*[^/]*).*!$1$2!;s!^trunk/+.*!trunk!;print;exit;}')"
            if test -n "$v" ; then printf "${1:- (%s)}" "$v" && return 0 ; fi
        fi
        return 1
    }
    ps1_() {
        ! git_ps1_ "$@" || return 0
        ! svn_ps1_ "$@" || return 0
        return 0
    }
fi
#export -f ps1_ # BASH only
PS1_ROOT='\[\e[01;31m\]\h \[\e[01;34m\]\w \[\e[1;32m\]\$\[\e[00m\] '
export PS1_ROOT
PS1_ROOT_NOCOLOR='\h:\w\$ '
export PS1_ROOT_NOCOLOR
#PS1_FUNC='\[\e[01;32m\]\u\[\e[1;37m\]@\[\e[0m\]\[\e[01;32m\]\h\[\e[01;34m\]\w\[\e[01;31m\]$(ps1_ "(%s)")\[\e[1;32m\]\$\[\e[00m\] '
PS1_FUNC='\[\e[0;32m\]\u\[\e[m\]@\[\e[1;34m\]\h\[\e[m\]:\[\e[0;37m\]\w\[\e[m\]$(ps1_ '\''\[\e[1;31m\](%s)\[\e[m\]'\'')\$ '
export PS1_FUNC
#PS1_NOFUNC='\[\e[01;32m\]\u\[\e[1;37m\]@\[\e[0m\]\[\e[01;32m\]\h\[\e[01;34m\]\w\[\e[01;31m\]\[\e[1;32m\]\$\[\e[00m\] '
PS1_NOFUNC='\[\e[0;32m\]\u\[\e[m\]@\[\e[1;34m\]\h\[\e[m\]:\[\e[0;37m\]\w\[\e[m\]\$ '
export PS1_NOFUNC
PS1_NOCOLOR='\u@\h:\w\$ '
export PS1_NOCOLOR
if test "${TERM:-}" != 'dumb' && test -n "${BASH:-}" ; then
    if test "$(/usr/bin/id -u)" = '0' ; then
        PS1="$PS1_ROOT" ; export PS1
    else
        PS1="$PS1_FUNC" ; export PS1
    fi
elif test "$isinteractive" -ne 0 ; then
    PS1="$PS1_NOCOLOR" ; export PS1
fi
SUDO_PS1="$PS1_NOCOLOR" ; export SUDO_PS1

if test -n "$isinteractive" ; then
    quote() { test $# -eq 0 || printf %s\\n "$(printf %q\  "$@")" | sed 's/ $//' ; }
    vimnone() { vim --cmd 'let g:none=1' "$@" ; }
    vimmin() { vim --cmd 'let g:min=1' "$@" ; }
    p() { if test $# -gt 0 ; then "$@" | "${PAGER:-less}" ; fi ; }
    today() { date +"%Y%m%d" ; }
    todaytime() { date +"%Y%m%d-%H%M%S" ; }
    abspath() {
        if test $# -eq 0 ; then pwd
        else local i ; for i in "$@" ; do
            case "$i" in /*|[A-Za-z]:*) say "$i" ;; *) say "$(pwd)/$i" ;; esac
        done ; fi
    }
    winslash() {
        test $# -ne 0 || set -- .
        local i ; for i in "$@" ; do
            abspath "$i" | sed -e 's!\\!/!g'
        done
    }
    posixslash() { winslash "$@" ; }
    realpath() { python -c 'import sys;import os.path;print(os.path.realpath(sys.argv[1]))' ; }
    postpath() { for i in "$@" ; do export PATH="${PATH:+${PATH}:}$i" ; done ; }
    prepath() { for i in "$@" ; do export PATH="$i${PATH:+:${PATH}}" ; done ; }
    grepsrc() { find-src.sh -0Lf | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepall() { local t="$1" ; shift ; find-src.sh -0Lf -t "$t" | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grephs() { find-src.sh -0Lf -t haskell | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepcpp() { find-src.sh -0Lfc | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepjava() { find-src.sh -0Lf -t java | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    greppy() { find-src.sh -0Lf -t python | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepsh() { find-src.sh -0Lf -t bash | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepcs() { find-src.sh -0Lf -t cs | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepjam() { find-src.sh -0Lf -t jam | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepcmake() { find-src.sh -0Lf -n CMakeLists.txt | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepxml() { find-src.sh -0Lf -t xml | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepxsd() { find-src.sh -0Lf -t xsd | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepallxml() { find-src.sh -0Lf -t allxml | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }

    dusort() { du -sbL "$@" | sort -n | awk '{print $2}' ; }
    # DIFF must not use color.
    # DIFFCOLOR should force color, if the tool supports colors at all.
    export DIFF="diff -U10 -p"
    if type colordiff >/dev/null 2>&1 ; then
        export DIFFCOLOR="colordiff --force -U10 -p"
    else
        export DIFFCOLOR="$DIFF"
    fi

    c() { DIFF="$DIFFCOLOR" "$@" ; }
    alt() { c p $DIFF -rN "$@" ; }

    svnl() { p ${SVN_EXE:-svn} "$@" ; }
    svnd() { c svnl "$@" ; }
    svngext() {
        if test $# -eq 0 ; then set -- . ; fi
        ${SVN_EXE:-svn} pg svn:externals "$@"
    }
    svneext() {
        if test $# -eq 0 ; then set -- . ; fi
        ${SVN_EXE:-svn} pe svn:externals "$@"
    }
    svnst() { ${SVN_EXE:-svn} st --ignore-externals "$@" | "${GREP:-grep}" -v '^X  ' ; }
    svnsti() { ${SVN_EXE:-svn} st --ignore-externals "$@" | "${GREP:-grep}" -v '^X  \|^?' ; }
    svnstm() { svnst "$@" | "${GREP:-grep}" '^M' ; }
    svnstma() { svn status "$@" | "${GREP:-grep}" '^M' ; }
    svnstqa() { svn status "$@" | "${GREP:-grep}" '^?' ; }
    svnlog() { svnd log -vr HEAD:1 "$@" ; }
    svnlogat() { local at="$1" ; shift ; svnd log -vr "$at":1 "$@"@"$at" ; }
    svnnews() { svnd log -vr BASE:HEAD --incremental "$@" ; }
    svnmergelog() { svnlog -g "$@" ; }
    svndiff() { svnd diff "$@" ; }
    svnwdiff() { svndiff -x -w "$@" ; }
    svnfdiff() { svndiff --ignore-properties "$@" ; }
    svnpdiff() { svndiff --properties-only "$@" ; }
    svnmkpatch() { ${SVN_EXE:-svn} diff --notice-ancestry --show-copies-as-adds "$@" ; }
    svnfulldiff() { svndiff --notice-ancestry --show-copies-as-adds "$@" ; }
    svnlogcopies() { svnl log -v --stop-on-copy "$@" ; }
    svnurl() { LC_ALL=C ${SVN_EXE:-svn} info "$@" | sed -n 's/^URL: //p' ; }
    svntags() { svnlist.sh -t "$@" ; }
    svnstags() { svnsort.sh -t "$@" ; }
    svntagcmp() { printf %s "old " ; svnurl "$@" || say error'!' >&2 ; printf %s "new " ; local new="$(svnsort.sh -t "$@" || say error'!' >&2)" ; printf %s\\n "$new" | tail -n1 ; }
    svnbr() { svnlist.sh -b "$@" ; }
    svnsbr() { svnsort.sh -b "$@" ; }
    svntr() { svnlist.sh -T "$@" ; }
    alias dash='PS1=\$\  dash'
    alias ls="ls -F --color=auto"
    alias sl='ls'
    alias ks='ls'
    alias l='ls -l'
    alias la='ls -la'
    alias lsd='ls -ltrh'
    alias lsquote='ls --quoting-style=shell-always'
    alias lsescape='ls --quoting-style=escape'
    o_=
    if say $TERM | grep -q -- '-256color$' ; then o_="${o_:--}2" ; fi
    if say $LANG | grep -iq -- '\.UTF-8$' ; then o_="${o_:--}u" ; fi
    alias tmux="tmux $o_"
    unset o_
    alias scr='screen -d -RR -s "${SCREEN_SHELL}"'
    alias encrypt='gpg -c'
    alias btftp='tftp -m binary'
    if ! type gmake >/dev/null 2>&1 ; then
        alias gmake='make'
    fi
    if type colordiff >/dev/null 2>&1 ; then
        alias diff='colordiff'
    fi
fi
. ~/.bashrc.post.sh 2>/dev/null || true
