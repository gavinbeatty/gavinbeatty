# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
if test -n "${bashrc_msys_guard-}" ; then return 0 ; fi
bashrc_msys_guard=1
iecho ".bashrc.msys.sh"

CMAKETOOL_BUILD_DIR="${USERPROFILE}/work/build" ; export CMAKETOOL_BUILD_DIR

if test -z "$USER" ; then
    USER="$USERNAME" ; export USER
fi

if ! have "python" ; then
    python="$(find "/c" -maxdepth 1 -type d \
        -iregex '.*/Python2[0-9]+$' -print 2>/dev/null | sort -n | tail -n1)"
    tmp_PATH="$(envlist "$PATH" append "$python")"
    if test -n "$tmp_PATH" ; then
        PATH="$tmp_PATH" ; export PATH
    fi
    unset python
fi

# find the most recent vim available
if test -d "/c/Program Files/Vim/" ; then
    vim="$(find "/c/Program Files/Vim" -maxdepth 1 -type d \
        -iregex '.*/vim[0-9]+$' -print 2>/dev/null | sort -n | tail -n1)"
    tmp_PATH="$(envlist "$PATH" prepend "$vim")"
    if test -n "$tmp_PATH" ; then
        PATH="$tmp_PATH" ; export PATH
    fi
    unset vim
fi

# if cmake isn't already in the path...
if ! have "cmake" ; then
    cmake="$(find "/c/Program Files" -maxdepth 1 -type d \
        -iregex '.*/CMake [0-9]+\.[0-9]+$' -print 2>/dev/null | sort -n | tail -n1)"
    tmp_PATH="$(envlist "$PATH" append "$cmake")"
    if test -n "$tmp_PATH" ; then
        PATH="$tmp_PATH" ; export PATH
    fi
    unset cmake
fi

gnuwin32="/c/Program Files/GnuWin32/bin"
if test -d "$gnuwin32" ; then
    tmp_PATH="$(envlist "$PATH" append "$gnuwin32")"
    if test -n "$tmp_PATH" ; then
        PATH="$tmp_PATH" ; export PATH
    fi
fi
unset gnuwin32

builddirbase_() {
    echo "${USERPROFILE}/work/build/${1}$(pwd)"
}
builddirmsys() {
    builddirbase_ msysmake
}
cdbuildbase_() {
    bdir="$(builddirbase_ "$1")"
    test -d "$bdir" || mkdir -p "$bdir"
    cd "$bdir"
}
cdbuildmsys() {
    cdbuildbase_ msysmake
}
# doesn't work as $USERPROFILE is C:\Users\${USERNAME} and pwd is like
# /c/Users/${USERNAME}
srcdirmsys() {
    pwd | sed -e 's#^'"${USERPROFILE}"'/work/build/[a-zA-Z0-9]*##'
}
cdsrcmsys() {
    cd "$(srcdirmsys)"
}
