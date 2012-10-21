# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
test -z "${bashrc_guard:-}" || return 0
bashrc_guard=1

case $- in
*i*) isinteractive=1 ; iecho() { echo "$@" ; } ;;
*) isinteractive=0 ; iecho() { true ; } ;;
esac
iecho ".bashrc"
# XXX perhaps use this to add to PATH etc.
# XXX have a look at pathmunge in /etc/rc.d on arch (at least)
regexelem() { echo "$2" | grep -q "\(^${1}:\\|:${1}:\\|:${1}\$\\|^${1}\$\)" ; }

if test -r ~/.bashrc.pre.sh ; then
    . ~/.bashrc.pre.sh
fi

if test "$isinteractive" -ne 0 ; then
    cat -- /tmp/gavinbeatty-du.log 2>/dev/null || true
    if type -- df >/dev/null 2>&1 ; then
        df -h
    fi
fi

# Use vi mode readline instead of emacs style
#set -o vi
# To do with resizing and redrawing terminals XXX explain
#shopt -s checkwinsize # BASH only

ulimit -c unlimited
iecho "ulimit -c $(ulimit -c)"
# get rid of nosy others
# 0027 => 'u=rwx,g=rx,o='
umask 0027
iecho "umask $(umask)"

if test -r ~/.dircolors ; then
    eval $(dircolors ~/.dircolors) >/dev/null
fi

########################################################################
# Set variables that have no dependency on PATH etc.
########################################################################
UNAME="$(uname 2>/dev/null || true)"
HOST="$(hostname -s 2>/dev/null || true)"
if test -z "$HOST" ; then HOST="$(hostname 2>/dev/null || true)" ; fi

HISTSIZE="30" ; export HISTSIZE

FULLNAME="Gavin Beatty" ; export FULLNAME
EMAIL="gavinbeatty@gmail.com" ; export EMAIL
DEBFULLNAME="${FULLNAME}" ; export DEBFULLNAME
DEBEMAIL="${EMAIL}" ; export DEBEMAIL
GIT_AUTHOR_NAME="${FULLNAME}" ; export GIT_AUTHOR_NAME
GIT_AUTHOR_EMAIL="${EMAIL}" ; export GIT_AUTHOR_EMAIL
BZR_EMAIL="${FULLNAME} <${EMAIL}>" ; export BZR_EMAIL
GPG_KEY_ID="Gavin Beatty (Dublin, Ireland) <gavinbeatty@gmail.com>"

LESS="${LESS:-}"
if ! echo "$LESS" | grep -q '\<-F\>' ; then LESS="${LESS} -F" ; fi
if ! echo "$LESS" | grep -q '\<-X\>' ; then LESS="${LESS} -X" ; fi
if ! echo "$LESS" | grep -q '\<-R\>' ; then LESS="${LESS} -R" ; fi
if ! echo "$LESS" | grep -q '\<-r\>' ; then LESS="${LESS} -r" ; fi
if ! echo "$LESS" | grep -q '\<-S\>' ; then LESS="${LESS} -S" ; fi
export LESS

# line-wrap minicom by default
MINICOM="${MINICOM:-}"
if ! echo "$MINICOM" | grep -q -- '-[a-zA-Z0-9]*w' ; then
    MINICOM="${MINICOM}${MINICOM:+ }-w" ; export MINICOM
fi
if ! echo "$MINICOM" | grep -q -- '-[a-zA-Z0-9]*c +on' ; then
    MINICOM="${MINICOM}${MINICOM:+ }-c on" ; export MINICOM
fi

########################################################################
# XDG
# http://standards.freedesktop.org/basedir-spec/
########################################################################
#if ! test -f "/etc/SuSE-release" ; then
#    v_="${XDG_DATA_HOME:-}"
#    XDG_DATA_HOME="${v_}${v_:+:}${HOME}/.local/share"
#    export XDG_DATA_HOME
#    v_="${XDG_DATA_DIRS:-}"
#    XDG_DATA_DIRS="${v_}${v_:+:}/usr/local/share/:/usr/share/"
#    export XDG_DATA_DIRS
#    v_="${XDG_CONFIG_HOME:-}"
#    XDG_CONFIG_HOME="${v_}${v_:+:}${HOME}/.config"
#    export XDG_CONFIG_HOME
#    v_="${XDG_CONFIG_DIRS:-}"
#    XDG_CONFIG_DIRS="${v_}${v_:+:}/etc/xdg"
#    export XDG_CONFIG_DIRS
#    unset v_
#fi

########################################################################
# Set PATH and associated variables
########################################################################
if test "${isinteractive:-0}" -ne 0 ; then
    v_="${PATH:-}"
    if ! regexelem '\.' "$v_" ; then
        PATH="${v_}${v_:+:}." ; export PATH
    fi
fi
v_="${PATH:-}"
n_="${HOME}/bin"
if (test -d "$n_") && (! echo "$v_" | grep -Fq "$n_") ; then
    PATH="${v_}${v_:+:}$n_" ; export PATH
fi

HOME_PREFIX="${HOME}/.local/usr" ; export HOME_PREFIX
if test -d "${HOME_PREFIX}" ; then
    v_="${PATH:-}"
    n_="${HOME_PREFIX}/sbin"
    if (test -d "$n_") && (! echo "$v_" | grep -Fq "$n_") ; then
        PATH="${n_}${v_:+:}${v_}" ; export PATH
    fi
    v_="${PATH:-}"
    n_="${HOME_PREFIX}/bin"
    if (test -d "$n_") && (! echo "$v_" | grep -Fq "$n_") ; then
        PATH="${n_}${v_:+:}${v_}" ; export PATH
    fi
fi
n_="${HOME}/.cabal/bin"
v_=
test -z "${PATH:-}" || v_=":$PATH"
if (test -d "${HOME}/.cabal") && (! echo "$v_" | grep -Fq "$n_") ; then
    PATH="${n_}${v_}" ; export PATH
fi
# mac specific, but put it here regardless
n_="${HOME}/Library/Haskell/bin"
v_=
test -z "${PATH:-}" || v_=":$PATH"
if (test -d "$n_") && (! echo "$v_" | grep -Fq "$n_") ; then
    PATH="${n_}${v_}" ; export PATH
fi
if type manpath >/dev/null 2>&1 ; then
    MANPATH="${MANPATH:-}${MANPATH:+:}$(manpath)" ; export MANPATH
fi
for n_ in "${HOME}/Library/Haskell/ghc/lib/"*"/share/man" ; do
    v_=
    test -z "${MANPATH:-}" || v_=":$MANPATH"
    if (test -d "$n_") && (! echo "$v_" | grep -Fq "$n_") ; then
        MANPATH="${n_}${v_}" ; export MANPATH
    fi
done

# use rvm for now... i don't know if it's incompatible with gem (the way i've done it)
n_="${HOME}/.rvm/bin"
v_=
test -z "${PATH:-}" || v_=":$PATH"
if (test -d "${HOME}/.rvm") && (! echo "$v_" | grep -Fq "$n_") ; then
    PATH="${n_}${v_}" ; export PATH
fi
#if (type -- ruby >/dev/null 2>&1) && (test -d "${HOME}/.gem") \
#&& (type -- awk >/dev/null 2>&1) && (type -- sed >/dev/null 2>&1) ; then
#    if test -z "${RUBY_VERSION:-}" ; then
#        RUBY_VERSION="$(ruby --version | awk ' { print $2 } ' | sed -e 's/\.[0-9][0-9]*$//')"
#    fi
#    n_="${HOME}/.gem/ruby/${RUBY_VERSION}/bin"
#    v_="${PATH:-}"
#    if (test -d "$n_") && (! echo "$v_" | grep -Fq "$n_") ; then
#        PATH="${n_}${v_:+:}${v_}" ; export PATH
#    fi
#    unset v_
#fi
n_="${HOME}/.cabal/bin"
v_=
test -z "${PATH:-}" || v_=":$PATH"
if (test -d "${HOME}/.cabal") && (! echo "$v_" | grep -Fq "$n_") ; then
    PATH="${n_}${v_}" ; export PATH
fi
unset v_
unset n_

########################################################################
# Set anything depending on PATH etc.
########################################################################
if type -- less >/dev/null 2>&1 ; then
    PAGER="less" ; export PAGER
fi

for i_ in vim vi nano pico ; do
    if type -- "$i_" >/dev/null 2>&1 ; then
        VISUAL="$i_" ; export VISUAL
        break
    fi
done
unset i_
EDITOR="${VISUAL:-}" ; export EDITOR
SVN_EDITOR="${VISUAL:-}" ; export SVN_EDITOR
if type -- google-chrome >/dev/null 2>&1 ; then
    BROWSER="google-chrome" ; export BROWSER
elif type -- iceweasel >/dev/null 2>&1 ; then
    BROWSER="iceweasel" ; export BROWSER
elif type -- firefox >/dev/null 2>&1 ; then
    BROWSER="firefox" ; export BROWSER
fi

if test "${isinteractive:-0}" -ne 0 ; then
    if type -- keychain >/dev/null 2>&1 ; then
        KEYCHAIN_DIR="${HOME}/.keychain"
        if test ! -d "$KEYCHAIN_DIR" ; then
            if test ! -e "$KEYCHAIN_DIR" ; then
                mkdir -p "$KEYCHAIN_DIR"
            fi
        fi
        if test -d "$KEYCHAIN_DIR" ; then
            keychain --inherit any-once --noask --quick --host gavinbeatty >/dev/null 2>&1
            for i_ in "sh" "sh-gpg" ; do
                if test -r "${KEYCHAIN_DIR}/gavinbeatty-${i_}" ; then
                    iecho "gavinbeatty-${i_}"
                    . "${KEYCHAIN_DIR}/gavinbeatty-${i_}"
                fi
            done
            unset i_
        fi
    fi
    if type -- tty >/dev/null 2>&1 ; then
        GPG_TTY=$(tty) ; export GPG_TTY
    fi
fi

if test "${isinteractive:-0}" -ne 0 ; then
    if test -r "${HOME}/.git-completion.bash" ; then
        . "${HOME}/.git-completion.bash"
    else
    # taken from git/contrib/completion/git-completion.bash
    #
    # __git_ps1 accepts 0 or 1 arguments (i.e., format string)
    # returns text to add to bash PS1 prompt (includes branch name)
    __git_ps1() {
        local g="$(git rev-parse --git-dir 2>/dev/null)"
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

            if [ -n "${1-}" ]; then
                printf "$1" "${b##refs/heads/}$w$i$r"
            else
                printf " (%s)" "${b##refs/heads/}$w$i$r"
            fi
        fi
    }
    fi

fi
svn_ps1_() {
    local v="$(LC_ALL=C ${SVN_EXE:-svn} info 2>/dev/null)"
    if test $? -eq 0 ; then
        v="$(echo "$v" | perl -wne 'if(/^URL: .*\/(trunk|tags|branches)(\/|$)/){s!^.*/(trunk|tags|branches)((/[^/]*)?).*!$1$2!;s/^trunk.*/trunk/;print;}')"
        if test -n "$v" ; then printf "$1" "$v" && return 0 ; fi
    fi
    return 1
}
ps1_() {
    local i=
    for i in __git_ps1 svn_ps1_ ; do
        local v="$("$i" "$@")"
        if test -n "$v" ; then echo "$v" && break ; fi
    done
}
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
elif test "${isinteractive:-0}" -ne 0 ; then
    PS1="$PS1_NOCOLOR" ; export PS1
fi
SUDO_PS1="$PS1_NOCOLOR" ; export SUDO_PS1

########################################################################
# Darwin
########################################################################
# macports
if (test -d "/opt/local/bin") && (! echo "${PATH:-}" | grep -Fq "/opt/local/bin") ; then
    PATH="${PATH:-}${PATH:+:}/opt/local/bin}" ; export PATH
fi
if (test -d "/opt/local/sbin") && (! echo "${PATH:-}" | grep -Fq "/opt/local/sbin") ; then
    PATH="${PATH:-}${PATH:+:}/opt/local/sbin}" ; export PATH
fi
v_="${PATH:-}"
n_="/Applications/MacVim.app/Contents/MacOS"
if test -d "$n_" && ! echo "$v_" | grep -Fq "$n_" ; then
    PATH="$n_${v_:+:}$v_" ; export PATH
fi
if test "${isinteractive:-0}" -ne 0 ; then
    if type Vim >/dev/null 2>&1 ; then alias vim=Vim ; fi
    if type mvim >/dev/null 2>&1 ; then alias gvim=mvim ; fi
fi

# don't set MANPATH as it needs to contain all default manpage paths
# as well as MacPort's
v_="${SGML_CATALOG_FILES:-}"
n_="/opt/local/share/xsl/docbook-xsl/catalog.xml"
if (test -r "$n_") && (! echo "${v_:-}" | grep -Fq "$n_") ; then
    SGML_CATALOG_FILES="${v_}${v_:+:}$n_"
    export SGML_CATALOG_FILES
fi

if test "${isinteractive:-0}" -ne 0 ; then
    alias spotlight-on='sudo mdutil -a -i on'
    alias spotlight-off='sudo mdutil -a -i off'
fi

########################################################################
# MSYS/mingw
########################################################################
# XXX how to detect msys/mingw properly? what's the difference?
if (test x"$MSYSTEM" = x"MINGW32") || (test x"$OSTYPE" = x"msys") ; then
    if test -z "$USER" ; then
        USER="${USERNAME:-}" ; export USER # export even if empty
    fi
    if ! type python >/dev/null 2>&1 ; then
        python="$(find "/c" -maxdepth 1 -type d \
            -iregex '.*/Python2[0-9]+$' -print 2>/dev/null | sort -n | tail -n1)"
        v_="${PATH:-}"
        n_="$python"
        if (test -r "$n_") && (! echo "${v_}" | grep -Fq "$n_") ; then
            PATH="${v_}${v_:+:}$n_"
            export PATH
        fi
        unset python
    fi
    # find the best vim available, even if one is already in PATH
    if test -d "/c/Program Files/Vim/" ; then
        vim="$(find "/c/Program Files/Vim" -maxdepth 1 -type d \
            -iregex '.*/vim[0-9]+$' -print 2>/dev/null | sort -n | tail -n1)"
        v_="${PATH:-}"
        n_="$vim"
        if (test -r "$n_") && (! echo "${v_}" | grep -Fq "$n_") ; then
            PATH="${v_}${v_:+:}$n_"
            export PATH
        fi
        unset vim
    fi
    v_="${PATH:-}"
    n_="/c/Program Files/GnuWin32/bin"
    if test -r "$n_" && ! echo "${v_}" | grep -Fq "$n_" ; then
        PATH="${v_}${v_:+:}$n_"
        export PATH
    fi
fi

if test "${isinteractive:-0}" -ne 0 ; then
    if test -r /etc/bash_completion ; then
        # /etc/bash_completion sources ~/.bash_completion for me
        . /etc/bash_completion
    elif test -r "${HOME}/.bash_completion" ; then
        . "${HOME}/.bash_completion"
    fi

    r() {
        # must be on own line because of '&', I think
        "$@" >/dev/null 2>&1 &
    }
    if type xdg-open >/dev/null 2>&1 ; then
        OPENER="xdg-open"
    elif type open >/dev/null 2>&1 && test "$(echo "$UNAME" | tr '[A-Z]' '[a-z]')" = "darwin" ; then
        OPENER="command open"
    # elif windows, OPENER="start" ?
    fi
    open() {
        if test -n "${OPENER:-}" ; then r $OPENER "$@"
        else echo "No OPENER installed." >&2
        fi
    }
    e() {
        if test -f cscope.out ; then
            vim "+cscope add Gav_fnameescape('$(pwd)/cscope.out')" "$@"
        else vim "$@"
        fi
    }
    p() { if test $# -gt 0 ; then "$@" | "$PAGER" ; fi ; }
    today() { date +"%Y%m%d" ; }
    todaytime() { date +"%Y%m%d-%H%M%S" ; }

    cdlink() { cd "$(readlink "$1")" ; }
    h() { p history ; }
    hlast() {
        if test $# -eq 0 ; then set -- 10 ; fi
        history | tail -n "$(expr "$1" + 1)" | head -n "$1"
    }

    doin() {
        if test $# -lt 2 ; then
            echo "usage: in <dir> <command> [<args>...]" >&2
            return 1
        fi
        local d="$1"
        shift
        (cd -- "$d" && "$@")
    }
    XARGS="xargs"
    if type gxargs >/dev/null 2>&1 ; then
        XARGS="gxargs"
    fi
    XARGS_R="$XARGS -r"
    if ! echo | $XARGS_R >/dev/null 2>&1 ; then
        XARGS_R="$XARGS"
    fi
    grepcpp() { find-src.sh -0fc | $XARGS -0 grep -Hn "$@" ; }
    greppy() { find-src.sh -0f -t python | $XARGS -0 grep -Hn "$@" ; }
    # note it's actually for .bash and .sh extensions
    grepsh() { find-src.sh -0f -t bash | $XARGS -0 grep -Hn "$@" ; }
    grepsrc() { find-src.sh -0f | $XARGS -0 grep -Hn "$@" ; }

    svnl() { p ${SVN_EXE:-svn} "$@" ; }
    svngext() {
        if test $# -eq 0 ; then set -- . ; fi
        ${SVN_EXE:-svn} pg svn:externals "$@"
    }
    svneext() {
        if test $# -eq 0 ; then set -- . ; fi
        ${SVN_EXE:-svn} pe svn:externals "$@"
    }
    svnst() { ${SVN_EXE:-svn} st --ignore-externals "$@" | grep -v '^X  ' ; }
    svnlog() { svnl log -vgr HEAD:1 "$@" ; }
    svndiff() { ${SVN_EXE:-svn} diff "$@" | "$PAGER" ; }
    svnlogcopies() { svnl log -v --stop-on-copy "$@" ; }
    svnurl() { LC_ALL=C ${SVN_EXE:-svn} info "$@" | sed -n 's/^URL: //p' ; }
    svntags() { svnlist.sh -t "$@" ; }
    svnbr() { svnlist.sh -b "$@" ; }
    svntr() { svnlist.sh -T "$@" ; }

    bj() {
        local testfile="/tmp/gavinbeatty-bjtestcap-$(uuidgen)"
        bjam -j6 --verbose-test "$@" 2>&1 | tee -- "$testfile"
        local e="${PIPESTATUS[0]}"
        cat <<EOF
XXXXXXXXXXXXXXXXXXX
XXX TEST OUTPUT XXX
XXXXXXXXXXXXXXXXXXX
EOF
        local ge=0
        grep -E -- '^(\*\*passed\*\*|\.\.\.failed)' "$testfile" || ge=$?
        case $ge in
            0|1) ;;
            *) return $ge ; ;;
        esac
        rm -- "$testfile" || return $?
        return $e
    }
    bjin() {
        test $# -eq 0 && { echo "usage: bjin <dir> [<args>...]" >&2 ; return 1; }
        local d=$1
        shift
        doin "$d" bj "$@"
    }
    bjerrs() {
        local errsfile="/tmp/gavinbeatty-bjerrs-$(uuidgen)"
        bj "$@" | tee -- "$errsfile"
        local e="${PIPESTATUS[0]}"
        fgrep error: -- "$errsfile" | wc -l
        local ge="${PIPESTATUS[0]}"
        local we="${PIPESTATUS[1]}"
        rm -- "$errsfile" || return $?
        test $e -ne 0 && return $e
        test $ge -ne 0 && return $ge
        test $we -ne 0 && return $we
        return 0
    }
    xxxs() {
        local xxxsfile="/tmp/gavinbeatty-xxxs-$(uuidgen)"
        sfgrep XXX | tee -- "$xxxsfile"
        wc -l < "$xxxsfile"
        rm -- "$xxxsfile" || :
    }

    ismounted() { mount | grep -Fq " on ${1} type " ; }

    if (type sed >/dev/null 2>&1) && (type grep >/dev/null 2>&1) \
    && (echo | grep -Eq ''); then
        LS_OPTIONS="${LS_OPTIONS:-}"
        bash_alias_ls="$(eval echo $(alias ls 2>/dev/null | sed -e 's/^alias ls=//'))"
        if test -z "$bash_alias_ls" ; then
            bash_alias_ls='ls ${LS_OPTIONS}'
        else
            bash_alias_ls="${bash_alias_ls} "'${LS_OPTIONS}'
        fi
        if uname | grep -Eqi '(bsd|darwin)' ; then
            if ! echo "$bash_alias_ls $LS_OPTIONS" | grep -Eq -- ' +-[A-Za-z0-9]*G' ; then
                # defining CLICOLOR has the same effect as -G option and is more
                # foolproof (if -G isn't supported, say)
                CLICOLOR=1 ; export CLICOLOR
                #LS_OPTIONS="${LS_OPTIONS} -G"
            fi
        else
            if ! echo "$bash_alias_ls $LS_OPTIONS" | grep -Eq -- ' +--colou?r(=| +)(auto|tty)' ; then
                LS_OPTIONS="${LS_OPTIONS} --color=auto"
            fi
        fi
        if ! echo "$bash_alias_ls $LS_OPTIONS" | grep -Eq -- ' +(-[A-Za-z0-9]*F|--classify)' ; then
            LS_OPTIONS="${LS_OPTIONS} -F"
        fi
        export LS_OPTIONS
        alias ls="${bash_alias_ls}"
    fi
    alias tmux='tmux -2u'
    alias dash='PS1=\$\  dash'
    alias sl='ls'
    alias ks='ls'
    alias l='ls -l'
    alias la='l -a'
    alias lsquote='ls --quoting-style=shell-always'
    alias lsescape='ls --quoting-style=escape'
    alias scr='screen -d -RR -s "${SCREEN_SHELL}"'
    alias r='runq.sh'
    if type xdg-open >/dev/null 2>&1 ; then
        alias o='runq.sh xdg-open'
    else
        alias o='runq.sh doubleclick.sh'
    fi
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

if test -r ~/.bashrc.post.sh ; then
    . ~/.bashrc.post.sh
fi
