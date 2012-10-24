# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
if test -n "${bashrc_alias_guard-}" ; then return 0 ; fi
bashrc_alias_guard=1
iecho ".bashrc.alias.sh"

if (type -- sed >/dev/null 2>&1) && (type -- grep >/dev/null 2>&1) \
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
alias tmux='tmux -2 '
alias dash='PS1=\$\  dash'
alias sl='ls'
alias ks='ls'
alias l='ls -l'
alias la='l -a'
alias lsquote='ls --quoting-style=shell-always'
alias lsescape='ls --quoting-style=escape'
alias scr='screen -d -RR -s "${SCREEN_SHELL}"'
alias dir='ls --format=vertical'
alias vdir='ls --format=long'

alias encrypt='gpg -c'

alias btftp='tftp -m binary'

if ! type -- gmake >/dev/null 2>&1 ; then
    alias gmake='make'
fi

if type -- colordiff >/dev/null 2>&1 ; then
    alias diff='colordiff'
fi

# kde4 devel
alias kdeenv='. "${HOME}/.bashrc.kde"'

# cmake helpers
alias srcdir='cmaketool.sh srcdir'
alias builddir='cmaketool.sh builddir'
alias cdsrc='cd $(srcdir)'
alias cdbuild='cd $(builddir)'
alias perlsed.sh='perlsed.bash'

for i_ in $HOSTS ; do
    if test -r "${HOME}/.bashrc.alias.${i_}.sh" ; then
        . "${HOME}/.bashrc.alias.${i_}.sh"
    fi
done
unset i_
