# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
if test -n "${bash_logout_guard-}" ; then return 0 ; fi
bash_logout_guard=1
#iecho ".bash_logout"

# XXX this does not work when using tmux etc. -- you'll only have one login shell
# XXX tmux list-sessions hangs for some reason when run from ~/.bash_logout
#if (type -- keychain >/dev/null 2>&1) \
#&& (type -- who >/dev/null 2>&1) && (type -- wc >/dev/null 2>&1) \
#&& (test "$(who | grep -F -- "$USER" | wc -l)" -eq 1) ; then
#    keychain --quiet -k all
#fi

for bash_logout_i in $HOSTS ; do
    if test -r "${HOME}/.bash_logout.${bash_logout_i}" ; then
        . "${HOME}/.bash_logout.${bash_logout_i}"
    fi
done
unset bash_logout_i
