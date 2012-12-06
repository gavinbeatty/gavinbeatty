# gavinbeatty:bashrc.maths.sh
# A default .bashrc is in /local/skel/bash_profile;
# this could be copied and adapted.
iecho ".bashrc.maths.sh"

LC_ALL="en_IE.UTF-8" ; export LC_ALL
LANG="${LC_ALL}" ; export LANG
LC_CTYPE="${LC_ALL}" ; export LC_CTYPE

if test "$UNAME" = "Linux" ; then
    v_="${PATH:-}"
    n_="${HOME}/opt/debian/usr/jre/bin"
    if test -d "$n_" && ! echo "$v_" | grep -Fq "$n_" ; then
        PATH="${v_}${v_:+:}$n_" ; export PATH
    fi
    v_="${PATH:-}"
    n_="${HOME}/opt/debian/usr/jdk/bin"
    if test -d "$n_" && ! echo "$v_" | grep -Fq "$n_" ; then
        PATH="${v_}${v_:+:}$n_" ; export PATH
    fi
    v_="${PATH:-}"
    n_="${HOME}/opt/debian/usr/abinit/5.3/bin"
    if test -d "$n_" && ! echo "$v_" | grep -Fq "$n_" ; then
        PATH="${v_}${v_:+:}$n_" ; export PATH
    fi
    if test -z "$MANPATH" && type manpath >/dev/null 2>&1 ; then
        MANPATH="$(manpath 2>/dev/null || true)"
    fi
    if test -n "$MANPATH" ; then
        v_="${MANPATH:-}"
        n_="${HOME}/opt/debian/usr/man"
        if test -d "$n_" && ! echo "$v_" | grep -Fq "$n_" ; then
            MANPATH="${v_}${v_:+:}$n_" ; export MANPATH
        fi
    fi
fi

if test "$HOST" = "jbell" ; then
    v_="${PATH:-}"
    n_="${HOME}/opt/debian/usr/man"
    if test -d "$n_" && ! echo "$v_" | grep -Fq "$n_" ; then
        PATH="${v_}${v_:+:}$n_" ; export PATH
    fi
fi

# http_proxy="http://proxy.maths.tcd.ie/" ; export http_proxy
# HTTP_PROXY="${http_proxy}" ; export HTTP_PROXY

if test "${isinteractive:-0}" -ne 0 ; then
    msgs
fi
