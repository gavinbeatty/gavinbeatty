# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
if test -n "${bash_profile_guard-}" ; then return 0 ; fi
bash_profile_guard=1

if test -r ~/.profile ; then
    . ~/.profile
fi

if test -r ~/.bashrc ; then
    . ~/.bashrc # rely on the include guards
fi
# don't do post, just append here

