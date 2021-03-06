# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
test -z "${bashrc_guard:-}" || return 0
bashrc_guard=1

say() { printf "%s\n" "$*" ; }
isinteractive() { case $- in *i*) return 0 ;; esac ; return 1 ; }
if test "${isinteractive:-0}" -eq 1 || isinteractive ; then
    isinteractive=1
    isay() { printf %s\\n "$*" ; } ; iprintf() { printf "$@" ; }
else
    isinteractive=0
    isay() { true ; } ; iprintf() { true ; }
fi
iscygwin() { uname -o 2>/dev/null | tr 'A-Z' 'a-z' | grep -Fq cygwin ; }
ismsys() { uname -o 2>/dev/null | tr 'A-Z' 'a-z' | grep -Fq msys ; }
if test -z "${iscygwin:-}" && iscygwin ; then iscygwin=1 ; else iscygwin=0 ; fi
if test -z "${ismsys:-}" && ismsys ; then ismsys=1 ; else ismsys=0 ; fi
. ~/.bashrc.pre.sh 2>/dev/null || true

isay ".bashrc"

driveroot_=""
if test "${iscygwin:-0}" -eq 1 ; then
    driveroot_="/cygdrive"
fi

# XXX perhaps use this to add to PATH etc.
# XXX have a look at pathmunge in /etc/rc.d on arch (at least)
regexelem() { say "$2" | "${GREP:-grep}" -q "\\(^$1:\\|:$1:\\|:$1\$\\|^$1\$\\)" ; }

if test "${iscygwin:-0}" -eq 0 && test "$isinteractive" -ne 0 ; then
    cat /tmp/gavinbeatty-du.log 2>/dev/null || true
    if type df >/dev/null 2>&1 ; then
        df -h
    fi
fi

# Use vi mode readline instead of emacs style
#set -o vi
# To do with resizing and redrawing terminals XXX explain
#shopt -s checkwinsize # BASH only

ulimit -c unlimited
isay "ulimit -c $(ulimit -c)"
# get rid of nosy others
# 0027 => 'u=rwx,g=rx,o='
umask 0027
isay "umask $(umask)"

if test -r "${HOME}/.dircolors" ; then
    eval $(dircolors -b "${HOME}/.dircolors") >/dev/null
fi

########################################################################
# Set variables that have no dependency on PATH etc.
########################################################################
if test -n "${XDG_CONFIG_HOME:-}" && (test "${ismsys:-0}" = 1 || test "${iscygwin:-0}" = 1) ; then
    XDG_CONFIG_HOME="${LOCALAPPDATA:-$USERPROFILE/AppData/Local}" ; export XDG_CONFIG_HOME
else
    XDG_CONFIG_HOME="$HOME/.config" ; export XDG_CONFIG_HOME
fi

UNAME="$(uname 2>/dev/null | tr 'A-Z' 'a-z' 2>/dev/null || true)"
HOST="$(hostname -s 2>/dev/null || true)"
test -n "$HOST" || HOST="$(hostname 2>/dev/null || true)"
test -z "$HOST" || HOST="$(say "$HOST" | tr A-Z a-z)"

HISTSIZE="100" ; export HISTSIZE

LESS="${LESS:-}"
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*F' ; then LESS="${LESS} -F" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*X' ; then LESS="${LESS} -X" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*R' ; then LESS="${LESS} -R" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*r' ; then LESS="${LESS} -r" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*S' ; then LESS="${LESS} -S" ; fi
if ! say "$LESS" | grep -q '\(^\|[[:space:]]\)-[[:alnum:]]*x' ; then LESS="${LESS} -x4" ; fi
export LESS

# line-wrap minicom by default
MINICOM="${MINICOM:-}"
if ! say "$MINICOM" | grep -q -- '-[[:alnum:]]*w' ; then
    MINICOM="${MINICOM:+$MINICOM }-w" ; export MINICOM
fi
if ! say "$MINICOM" | grep -q -- '-[[:alnum:]]*c +on' ; then
    MINICOM="${MINICOM:+$MINICOM }-c on" ; export MINICOM
fi

########################################################################
# Set PATH and associated variables
########################################################################
if test "$isinteractive" -ne 0 ; then
    if ! regexelem '\.' "${PATH:-}" ; then
        PATH="${PATH:+$PATH:}." ; export PATH
    fi
fi
PATH="${HOME}/bin${PATH:+:$PATH}" ; export PATH

HOME_PREFIX="${HOME}/.local" ; export HOME_PREFIX
if test -d "${HOME_PREFIX}" ; then
    for n_ in "${HOME_PREFIX}/"{sbin,bin} ; do
        if test -d "$n_" && ! say "${PATH:-}" | grep -Fq "$n_" ; then
            PATH="${n_}${PATH:+:$PATH}" ; export PATH
        fi
    done
fi
n_="/opt/mono/bin"
if test -d "$n_" && ! say "${PATH:-}" | grep -Fq "$n_" ; then
    PATH="${n_}${PATH:+:$PATH}" ; export PATH
fi
n_="${HOME}/.local/opt/node/bin"
if test -d "$n_" && ! say "${PATH:-}" | grep -Fq "$n_" ; then
    PATH="${n_}${PATH:+:$PATH}" ; export PATH
fi
test -n "${bashrc_opam_config_env:-}" || (type opam >/dev/null 2>/dev/null && eval `opam config env` >/dev/null 2>/dev/null) || true
bashrc_opam_config_env=1

DOTNET_CLI_TELEMETRY_OPTOUT=1 ; export DOTNET_CLI_TELEMETRY_OPTOUT

test "${iscygwin:-0}" -ne 0 || . "$HOME/.rvm/scripts/rvm" >/dev/null 2>&1 || true
# macports
if test -d "/opt/local/bin" && ! say "${PATH:-}" | grep -Fq "/opt/local/bin" ; then
    PATH="${PATH:+$PATH:}/opt/local/bin" ; export PATH
fi
if test -d "/opt/local/sbin" && ! say "${PATH:-}" | grep -Fq "/opt/local/sbin" ; then
    PATH="${PATH:+$PATH:}/opt/local/sbin" ; export PATH
fi
n_="/Applications/MacVim.app/Contents/MacOS"
if test -d "$n_" && ! say "${PATH:-}" | grep -Fq "$n_" ; then
    PATH="$n_${PATH:+:$PATH}" ; export PATH
fi
if test "$isinteractive" -ne 0 ; then
    if type mvim >/dev/null 2>&1 ; then alias gvim=mvim ; fi
fi
n_="/Applications/threadscope.app/Contents/MacOS"
if test -d "$n_" && ! say "${PATH:-}" | grep -Fq "$n_" ; then
    PATH="$n_${PATH:+:$PATH}" ; export PATH
fi
unset n_
n_="${driveroot_}/c/Program Files/TortoiseSVN/bin"
if ! type svn >/dev/null 2>&1 && test -d "$n_" && ! say "${PATH:-}" | grep -Fq "$n_" ; then
    PATH="$n_${PATH:+:$PATH}" ; export PATH
fi
unset n_


########################################################################
# Set anything depending on PATH etc.
########################################################################
if type less >/dev/null 2>&1 ; then
    PAGER="less" ; export PAGER
fi

if type nvim >/dev/null 2>&1 && test -r "$XDG_CONFIG_HOME/nvim/init.vim" ; then
    VISUAL="nvim"
else
    for i_ in vim vi nano pico ; do
        if type "$i_" >/dev/null 2>&1 ; then
            VISUAL="$i_" ; export VISUAL
            break
        fi
    done
    unset i_
fi
EDITOR="${VISUAL:-}" ; export EDITOR
SVN_EDITOR="${VISUAL:-}" ; export SVN_EDITOR
if type firefox >/dev/null 2>&1 ; then
    BROWSER="firefox" ; export BROWSER
fi

if test "$isinteractive" -ne 0 ; then
    if type keychain >/dev/null 2>&1 ; then
        KEYCHAIN_DIR="${HOME}/.keychain"
        mkdir "$KEYCHAIN_DIR" 2>/dev/null
        if keychain --inherit any-once --noask --quick --host gavinbeatty >/dev/null 2>&1 ; then
            if . "${KEYCHAIN_DIR}/gavinbeatty-sh" 2>/dev/null ; then
                isay "keychain/gavinbeatty-sh"
            elif . "${KEYCHAIN_DIR}/gavinbeatty-sh-gpg" 2>/dev/null ; then
                isay "keychain/gavinbeatty-sh-gpg"
            fi
        fi
    else
        . ~/".ssh-agent.$HOST.sh" 2>/dev/null || . ~/.ssh-agent.sh 2>/dev/null || true
    fi
    if type tty >/dev/null 2>&1 ; then
        GPG_TTY=$(tty) ; export GPG_TTY
    fi
fi

if test "$isinteractive" -ne 0 ; then
    if test -r "${HOME}/.git-prompt.sh" ; then
        . "${HOME}/.git-prompt.sh"
        git_ps1_() {
            local p="$(__git_ps1 "$@")"
            test -n "$p" || return 1
            printf %s\\n "$p"
        }
    else
        git_ps1_() { return 1 ; }
    fi
    svn_ps1_() {
        if local v="$(LC_ALL=C ${SVN_EXE:-svn} info 2>/dev/null)" ; then
            v="$(say "$v" | perl -ne 'if(/^URL: .*\/(trunk|tags|branches)(\/|\s*$)/){s!^.*/(trunk|tags|branches)(/*\s*$|/*[^/]*).*!$1$2!;s!^trunk/+.*!trunk!;print;exit;}')"
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

########################################################################
# Darwin
########################################################################
# don't set MANPATH as it needs to contain all default manpage paths
# as well as MacPort's
n_="/opt/local/share/xsl/docbook-xsl/catalog.xml"
if test -r "$n_" && ! say "${SGML_CATALOG_FILES:-}" | grep -Fq "$n_" ; then
    SGML_CATALOG_FILES="${SGML_CATALOG_FILES:+$SGML_CATALOG_FILES:}$n_"
    export SGML_CATALOG_FILES
fi

if test "$isinteractive" -ne 0 ; then
    alias spotlight-on='sudo mdutil -a -i on'
    alias spotlight-off='sudo mdutil -a -i off'

    if test -r /etc/bash_completion ; then
        # /etc/bash_completion sources "${HOME}/.bash_completion" for me
        . /etc/bash_completion
    elif test -r "${HOME}/.bash_completion" ; then
        . "${HOME}/.bash_completion"
    fi
    jhome() {
        if test $# -ge 1 && test -n "$1" ; then
            readlink -f "$1" | perl -e 'while(<STDIN>){s|/*[^/]*/$ARGV[0]$||;print;}' "$(basename "$1")"
        fi
    }
    jrehome() { jhome "$(which java)" ; }
    jdkhome() { jhome "$(which javac)" ; }

    # Don't add trailing ; as & includes a logical ;.
    r() { "$@" >/dev/null 2>&1 & }
    quote() { test $# -eq 0 || printf %s\\n "$(printf %q\  "$@")" | sed 's/ $//' ; }
    if type xdg-open >/dev/null 2>&1 ; then
        OPENER="xdg-open"
    elif type open >/dev/null 2>&1 && test "$(say "$UNAME")" = "darwin" ; then
        OPENER="command open"
    # elif windows, OPENER="start" ?
    fi
    open() {
        if test -n "${OPENER:-}" ; then r $OPENER "$@"
        else say "No OPENER installed/configured." >&2
        fi
    }
    e() {
        if test -f cscope.out ; then
            vim "+cscope add fnameescape('$(pwd)/cscope.out')" "$@"
        else vim "$@"
        fi
    }
    vimnone() { vim --cmd 'let g:none=1' "$@" ; }
    vimmin() { vim --cmd 'let g:min=1' "$@" ; }
    p() { if test $# -gt 0 ; then "$@" | "$PAGER" ; fi ; }
    today() { date +"%Y%m%d" ; }
    todaytime() { date +"%Y%m%d-%H%M%S" ; }
    # How much hardwhere concurrency exists.
    nconc() { grep ^apicid /proc/cpuinfo | sort -u | wc -l ; }
    # ${JCONC:-1} is a decent, high value for `make -j` etc.
    n_="$(nconc 2>/dev/null || true)"
    if test -n "$n_" && test "$n_" -gt 2 ; then
        export JCONC=$(( $n_ - 3 ))
    fi
    unset n_

    case "$UNAME" in
        *msys*|*mingw*|windows*|cygwin*)
            abspath() {
                if test $# -eq 0 ; then pwd
                else local i ; for i in "$@" ; do
                    case "$i" in /*|[A-Za-z]:*) say "$i" ;; *) say "$(pwd)/$i" ;; esac
                done ; fi
            }
            ;;
        *) abspath() {
                if test $# -eq 0 ; then pwd
                else local i ; for i in "$@" ; do
                    case "$i" in /*) say "$i" ;; *) say "$(pwd)/$i" ;; esac
                done ; fi
            }
            ;;
    esac
    cdlink() { cd "$(readlink "$1")" ; }
    h() { p history ; }
    hlast() {
        if test $# -eq 0 ; then set -- 10 ; fi
        history | tail -n "$(expr "$1" + 1)" | head -n "$1"
    }

    bak() { mv -n "$1" "${1}.bak" ; }
    doin() {
        if test $# -lt 2 ; then
            echo "usage: in <dir> <command> [<args>...]" >&2
            return 1
        fi
        local d="$1"
        shift
        (cd -- "$d" && "$@")
    }
    if type greadlink >/dev/null 2>&1 ; then
        realpath() { greadlink -f "$@" ; }
    elif type readlink >/dev/null 2>&1 ; then
        realpath() { readlink -f "$@" ; }
    else
        realpath() { python -c 'import sys;import os.path;print(os.path.realpath(sys.argv[1]))' ; }
    fi
    postpath() { for i in "$@" ; do export PATH="${PATH:+${PATH}:}$i" ; done ; }
    prepath() { for i in "$@" ; do export PATH="$i${PATH:+:${PATH}}" ; done ; }
    XARGS="xargs"
    if type gxargs >/dev/null 2>&1 ; then
        XARGS="gxargs"
    fi
    XARGS_R="$XARGS -r"
    if ! echo | $XARGS_R >/dev/null 2>&1 ; then
        XARGS_R="$XARGS"
    fi
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

    sshsudoi() { local u="$1" ; shift ; ${SSH:-ssh} -t "$@" sudo -u "$u" -i ; }
    sshsui() { local u="$1" ; shift ; ${SSH:-ssh} -t "$@" sudo su - "$u" ; }

    # DIFF may use a heuristic to try to colorize.
    # DIFFCOLOR should force color, if the tool supports colors.
    if type git >/dev/null 2>&1 && type svngitdiff.py >/dev/null 2>&1 ; then
        export      DIFF="svngitdiff.py -U10 -p --patience --color=auto"
        export DIFFCOLOR="svngitdiff.py -U10 -p --patience --color=always"
    elif type colordiff >/dev/null 2>&1 ; then
        export      DIFF="colordiff         -U10 -p"
        export DIFFCOLOR="colordiff --force -U10 -p"
    else
        export      DIFF="diff -U10 -p"
        export DIFFCOLOR="$DIFF"
    fi

    c() { DIFF="$DIFFCOLOR" "$@" ; }
    alt() { c p $DIFF -rN "$@" ; }

    svnpty() { winpty ${SVN_EXE:-svn} "$@" ; }
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
    svnlshead() { ${SVN_EXE:-svn} ls -rHEAD "$@" ; }
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

    moshl() { mosh --server='~'/.local/bin/mosh-server "$@" ; }

    mk() { make -kj8 "$@" ; }
    bj() { bj.bash "$@" ; }
    bjin() {
        test $# -eq 0 && { echo "usage: bjin <dir> [<args>...]" >&2 ; return 1; }
        local d=$1
        shift
        doin "$d" bj "$@"
    }
    bjerrs() {
        local errsfile="/tmp/gavinbeatty-bjerrs$(uuidgen 2>/dev/null || true)"
        bj "$@" | tee "$errsfile"
        local e="${PIPESTATUS[0]}"
        fgrep error: "$errsfile" | wc -l
        local ge="${PIPESTATUS[0]}"
        local we="${PIPESTATUS[1]}"
        rm "$errsfile" || return $?
        test $e -ne 0 && return $e
        test $ge -ne 0 && return $ge
        test $we -ne 0 && return $we
        return 0
    }

    ismounted() { mount | "${GREP:-grep}" -Fq " on ${1} type " ; }

    if (type sed >/dev/null 2>&1) && (type grep >/dev/null 2>&1) ; then
        LS_OPTIONS="${LS_OPTIONS:-}"
        bash_alias_ls="$(eval echo $(alias ls 2>/dev/null | sed 's/^alias ls=//'))"
        if test -z "$bash_alias_ls" ; then
            bash_alias_ls='ls ${LS_OPTIONS}'
        else
            bash_alias_ls="${bash_alias_ls} "'${LS_OPTIONS}'
        fi
        if uname | grep -qi '\(bsd\|darwin\)' ; then
            if ! say "$bash_alias_ls $LS_OPTIONS" | grep -q '  *-[A-Za-z0-9]*G' ; then
                # defining CLICOLOR has the same effect as -G option and is more
                # foolproof (if -G isn't supported, say)
                CLICOLOR=1 ; export CLICOLOR
                #LS_OPTIONS="${LS_OPTIONS} -G"
            fi
        else
            if ! say "$bash_alias_ls $LS_OPTIONS" | grep -q '  *--colo\(\|u\)r\(=\|  *\)\(auto\|tty\)' ; then
                LS_OPTIONS="${LS_OPTIONS} --color=auto"
            fi
        fi
        if ! say "$bash_alias_ls $LS_OPTIONS" | grep -q '  *\(-[A-Za-z0-9]*F\|--classify\)' ; then
            LS_OPTIONS="${LS_OPTIONS} -F"
        fi
        export LS_OPTIONS
        alias ls="${bash_alias_ls}"
    fi
    alias dash='PS1=\$\  dash'
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
    alias dir='ls --format=vertical'
    alias vdir='ls --format=long'
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
