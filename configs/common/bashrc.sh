# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
test -z "${bashrc_guard:-}" || return 0
bashrc_guard=1

case $- in
*i*) isinteractive=1 ; iecho() { echo "$@" ; } ;;
*) isinteractive=0 ; iecho() { true ; } ;;
esac
. ~/.bashrc.pre.sh 2>/dev/null || true

iecho ".bashrc"
# XXX perhaps use this to add to PATH etc.
# XXX have a look at pathmunge in /etc/rc.d on arch (at least)
regexelem() { echo "$2" | "${GREP:-grep}" -q "\(^${1}:\\|:${1}:\\|:${1}\$\\|^${1}\$\)" ; }

if test "$isinteractive" -ne 0 ; then
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
iecho "ulimit -c $(ulimit -c)"
# get rid of nosy others
# 0027 => 'u=rwx,g=rx,o='
umask 0027
iecho "umask $(umask)"

if test -r "${HOME}/.dircolors" ; then
    eval $(dircolors "${HOME}/.dircolors") >/dev/null
fi

########################################################################
# Set variables that have no dependency on PATH etc.
########################################################################
UNAME="$(uname 2>/dev/null | tr '[A-Z]' '[a-z]' 2>/dev/null || true)"
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
if ! echo "$LESS" | grep -q '\<-[[:alnum:]]*F\>' ; then LESS="${LESS} -F" ; fi
if ! echo "$LESS" | grep -q '\<-[[:alnum:]]*X\>' ; then LESS="${LESS} -X" ; fi
if ! echo "$LESS" | grep -q '\<-[[:alnum:]]*R\>' ; then LESS="${LESS} -R" ; fi
if ! echo "$LESS" | grep -q '\<-[[:alnum:]]*r\>' ; then LESS="${LESS} -r" ; fi
if ! echo "$LESS" | grep -q '\<-[[:alnum:]]*S\>' ; then LESS="${LESS} -S" ; fi
export LESS

# line-wrap minicom by default
MINICOM="${MINICOM:-}"
if ! echo "$MINICOM" | grep -q -- '-[[:alnum:]]*w' ; then
    MINICOM="${MINICOM}${MINICOM:+ }-w" ; export MINICOM
fi
if ! echo "$MINICOM" | grep -q -- '-[[:alnum:]]*c +on' ; then
    MINICOM="${MINICOM}${MINICOM:+ }-c on" ; export MINICOM
fi

########################################################################
# Set PATH and associated variables
########################################################################
if test "$isinteractive" -ne 0 ; then
    if ! regexelem '\.' "$v_" ; then
        PATH="${PATH:-}${PATH:+:}." ; export PATH
    fi
fi
PATH="${HOME}/bin${PATH:+:}${PATH:-}" ; export PATH

HOME_PREFIX="${HOME}/.local" ; export HOME_PREFIX
if test -d "${HOME_PREFIX}" ; then
    for n_ in "${HOME_PREFIX}/"{sbin,bin} ; do
        if test -d "$n_" ; then
            PATH="${n_}${PATH:+:}${PATH:-}" ; export PATH
        fi
    done
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
if test -z "${MANPATH:-}" && type manpath >/dev/null 2>&1 ; then
    MANPATH="$(manpath)" ; export MANPATH
fi
for n_ in "$HOME"/Library/Haskell/ghc/lib/*/share/man ; do
    v_=
    test -z "${MANPATH:-}" || v_=":$MANPATH"
    if (test -d "$n_") && (! echo "$v_" | grep -Fq "$n_") ; then
        MANPATH="${n_}${v_}" ; export MANPATH
    fi
done
unset v_
# use rvm for now... i don't know if it's incompatible with gem (the way i've done it)
n_="${HOME}/.rvm/bin"
if (test -d "${HOME}/.rvm") && (! echo "${PATH:-}" | grep -Fq "$n_") ; then
    PATH="${n_}${PATH:+:}${PATH:-}" ; export PATH
fi
unset n_
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
if test "$isinteractive" -ne 0 ; then
    if type mvim >/dev/null 2>&1 ; then alias gvim=mvim ; fi
fi
n_="/Applications/threadscope.app/Contents/MacOS"
if test -d "$n_" && ! echo "${PATH:-}" | grep -Fq "$n_" ; then
    PATH="$n_${PATH:+:}${PATH:-}" ; export PATH
fi
#pyver_="$(python -V 2>&1 | sed 's/^Python \([0-9]*\.[0-9]*\)\(\.[0-9]*\)/\1/')" || true
#if test -n "$pyver_" ; then
#    n_="${HOME}/Library/Python/${pyver_}/bin"
#    v_="${PATH:-}"
#    if test -d "$n_" ; then
#        PATH="$n_${v_:+:}$v_" ; export PATH
#    fi
#fi

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

########################################################################
# Set anything depending on PATH etc.
########################################################################
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
EDITOR="${VISUAL:-}" ; export EDITOR
SVN_EDITOR="${VISUAL:-}" ; export SVN_EDITOR
if type google-chrome >/dev/null 2>&1 ; then
    BROWSER="google-chrome" ; export BROWSER
elif type iceweasel >/dev/null 2>&1 ; then
    BROWSER="iceweasel" ; export BROWSER
elif type firefox >/dev/null 2>&1 ; then
    BROWSER="firefox" ; export BROWSER
fi

if test "$isinteractive" -ne 0 ; then
    if type keychain >/dev/null 2>&1 ; then
        KEYCHAIN_DIR="${HOME}/.keychain"
        mkdir "$KEYCHAIN_DIR" 2>/dev/null
        if keychain --inherit any-once --noask --quick --host gavinbeatty >/dev/null 2>&1 ; then
            if . "${KEYCHAIN_DIR}/gavinbeatty-sh" 2>/dev/null ; then
                iecho "keychain/gavinbeatty-sh"
            elif . "${KEYCHAIN_DIR}/gavinbeatty-sh-gpg" 2>/dev/null ; then
                iecho "keychain/gavinbeatty-sh-gpg"
            fi
        fi
    fi
    if type tty >/dev/null 2>&1 ; then
        GPG_TTY=$(tty) ; export GPG_TTY
    fi
fi

if test "$isinteractive" -ne 0 ; then
    if test -r "${HOME}/.git-completion.bash" ; then
        . "${HOME}/.git-completion.bash"
        git_ps1_() {
            local p="$(__git_ps1 "$@")"
            test -n "$p" || return 1
            echo "$p"
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
            v="$(echo "$v" | perl -ne 'if(/^URL: .*\/(trunk|tags|branches)(\/|$)/){s!^.*/(trunk|tags|branches)(/*$|/*[^/]*).*!$1$2!;s!^trunk/+.*!trunk!;print;exit;}')"
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
v_="${SGML_CATALOG_FILES:-}"
n_="/opt/local/share/xsl/docbook-xsl/catalog.xml"
if (test -r "$n_") && (! echo "${v_:-}" | grep -Fq "$n_") ; then
    SGML_CATALOG_FILES="${v_}${v_:+:}$n_"
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

    r() {
        # must be on own line because of '&', I think
        "$@" >/dev/null 2>&1 &
    }
    if type xdg-open >/dev/null 2>&1 ; then
        OPENER="xdg-open"
    elif type open >/dev/null 2>&1 && test "$(echo "$UNAME")" = "darwin" ; then
        OPENER="command open"
    # elif windows, OPENER="start" ?
    fi
    open() {
        if test -n "${OPENER:-}" ; then r $OPENER "$@"
        else echo "No OPENER installed/configured." >&2
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
    # How much hardwhere concurrency exists.
    nconc() { grep ^apicid /proc/cpuinfo | sort -u | wc -l ; }
    # ${JCONC:-1} is a decent, high value for `make -j` etc.
    n_="$(nconc 2>/dev/null || true)"
    if test -n "$n_" && test "$n_" -gt 2 ; then
        export JCONC=$(( $n_ - 2 ))
    fi
    unset n_

    case "$UNAME" in
        *mingw*|windows*|cygwin*)
            abspath() {
                if test $# -eq 0 ; then pwd
                else local i ; for i in "$@" ; do
                    case "$i" in /*|[A-Za-z]:*) echo "$i" ;; *) echo "$(pwd)/$i" ;; esac
                done ; fi
            }
            winslash() {
                test $# -ne 0 || set -- .
                local i ; for i in "$@" ; do
                    abspath "$i" | sed -e 's!\\!/!g'
                done
            }
            posixslash() { winslash "$@" ; }
            ;;
        *) abspath() {
                if test $# -eq 0 ; then pwd
                else local i ; for i in "$@" ; do
                    case "$i" in /*) echo "$i" ;; *) echo "$(pwd)/$i" ;; esac
                done ; fi
            }
            winslash() {
                test $# -ne 0 || set -- .
                local i ; for i in "$@" ; do
                    abspath "$i" | sed -e 's!/!\\!g'
                done
            }
            posixslash() {
                test $# -ne 0 || set -- .
                local i ; for i in "$@" ; do abspath "$i" ; done
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
    XARGS="xargs"
    if type gxargs >/dev/null 2>&1 ; then
        XARGS="gxargs"
    fi
    XARGS_R="$XARGS -r"
    if ! echo | $XARGS_R >/dev/null 2>&1 ; then
        XARGS_R="$XARGS"
    fi
    grepsrc() { find-src.sh -0f | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepall() { local t="$1" ; shift ; find-src.sh -0f -t "$t" | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepcpp() { find-src.sh -0fc | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    greppy() { find-src.sh -0f -t python | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepsh() { find-src.sh -0f -t bash | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepcs() { find-src.sh -0f -t cs | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepjam() { find-src.sh -0f -t jam | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepcmake() { find-src.sh -0f -n CMakeLists.txt | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepxml() { find-src.sh -0f -t xml | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepxsd() { find-src.sh -0f -t xsd | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }
    grepallxml() { find-src.sh -0f -t allxml | $XARGS -0 "${GREP:-grep}" -Hn "$@" ; }

    svnl() { p ${SVN_EXE:-svn} "$@" ; }
    svngext() {
        if test $# -eq 0 ; then set -- . ; fi
        ${SVN_EXE:-svn} pg svn:externals "$@"
    }
    svneext() {
        if test $# -eq 0 ; then set -- . ; fi
        ${SVN_EXE:-svn} pe svn:externals "$@"
    }
    svnst() { ${SVN_EXE:-svn} st --ignore-externals "$@" | "${GREP:-grep}" -v '^X  ' ; }
    svnstm() { svnst "$@" | "${GREP:-grep}" '^M' ; }
    svnstma() { svn status "$@" | "${GREP:-grep}" '^M' ; }
    svnstqa() { svn status "$@" | "${GREP:-grep}" '^?' ; }
    svnlog() { svnl log -vr HEAD:1 "$@" ; }
    svnmergelog() { svnlog -g "$@" ; }
    _diffpager() {
        if test -z "${DIFF:-}" && (test -p /dev/stdout || test -f /dev/stdout) ; then
            "${PAGER:-less}" "$@"
        elif type colordiff >/dev/null 2>&1 ; then
            colordiff | "${PAGER:-less}" "$@" ; return ${PIPESTATUS[0]}
        else "${PAGER:-less}" "$@" ; fi
    }
    svndiff() { DIFFEXTRA=-b ${SVN_EXE:-svn} diff "$@" | _diffpager ; return ${PIPESTATUS[0]} ; }
    svnmkpatch() { ${SVN_EXE:-svn} diff --internal-diff --notice-ancestry --show-copies-as-adds "$@" ; }
    alt() { ! type colordiff >/dev/null 2>&1 || DIFF=colordiff ; p "${DIFF:-diff}" -U10 -brN "$@" ; }
    svndiffstat() { svndiff "$@" | diffstat ; return ${PIPESTATUS[0]} ; }
    svnlogcopies() { svnl log -v --stop-on-copy "$@" ; }
    svnurl() { LC_ALL=C ${SVN_EXE:-svn} info "$@" | sed -n 's/^URL: //p' ; }
    svntags() { svnlist.sh -t "$@" ; }
    svnbr() { svnlist.sh -b "$@" ; }
    svntr() { svnlist.sh -T "$@" ; }

    moshl() { mosh --server='~'/.local/bin/mosh-server "$@" ; }

    bj() {
        local testfile="/tmp/gavinbeatty-bjtestcap-$(uuidgen)"
        bjam "-j${JCONC:-1}" --verbose-test "$@" 2>&1 | tee "$testfile"
        local e="${PIPESTATUS[0]}"
        cat <<EOF
XXXXXXXXXXXXXXXXXXX
XXX TEST OUTPUT XXX
XXXXXXXXXXXXXXXXXXX
EOF
        local ge=0
        "${GREP:-grep}" -E '^(\*\*passed\*\*|\.\.\.failed)' "$testfile" || ge=$?
        case $ge in
            0|1) ;;
            *) return $ge ;;
        esac
        rm "$testfile" || return $?
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
    xxxs() {
        local xxxsfile="/tmp/gavinbeatty-xxxs-$(uuidgen)"
        sfgrep XXX | tee "$xxxsfile"
        wc -l < "$xxxsfile"
        rm "$xxxsfile" || :
    }

    ismounted() { mount | "${GREP:-grep}" -Fq " on ${1} type " ; }

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
            if ! echo "$bash_alias_ls $LS_OPTIONS" | grep -Eq ' +-[A-Za-z0-9]*G' ; then
                # defining CLICOLOR has the same effect as -G option and is more
                # foolproof (if -G isn't supported, say)
                CLICOLOR=1 ; export CLICOLOR
                #LS_OPTIONS="${LS_OPTIONS} -G"
            fi
        else
            if ! echo "$bash_alias_ls $LS_OPTIONS" | grep -Eq ' +--colou?r(=| +)(auto|tty)' ; then
                LS_OPTIONS="${LS_OPTIONS} --color=auto"
            fi
        fi
        if ! echo "$bash_alias_ls $LS_OPTIONS" | grep -Eq ' +(-[A-Za-z0-9]*F|--classify)' ; then
            LS_OPTIONS="${LS_OPTIONS} -F"
        fi
        export LS_OPTIONS
        alias ls="${bash_alias_ls}"
    fi
    alias dash='PS1=\$\  dash'
    alias sl='ls'
    alias ks='ls'
    alias l='ls -l'
    alias la='l -a'
    alias lsquote='ls --quoting-style=shell-always'
    alias lsescape='ls --quoting-style=escape'
    o_=
    if echo $TERM | grep -q -- '-256color' ; then o_="${o_:--}2" ; fi
    if echo $LANG | grep -iq -- '\.UTF-8$' ; then o_="${o_:--}u" ; fi
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
