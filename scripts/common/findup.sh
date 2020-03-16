#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Finds file FILE going backwards in the directory heirarchy.
###########################################################################
# Author unknown. Found without attached Author or Copyright or Licensing
# information.
# Modified by: Gavin Beatty <public@gavinbeatty.com> 2012
###########################################################################
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

shell="${BOURNE_SHELL:-}"

die() { echo "error: $@" >&2 ; exit 1 ; }
have() { type "$@" >/dev/null 2>&1 ; }

get_shell() {
    if test -z "$shell" ; then
        shell="bash"
        if have dash ; then shell="dash"
        elif have sh ; then shell="sh"
        elif ! have "$shell" ; then die "Unknown shell!" ; fi
    fi
}
get_xargs() {
    if test -z "$xargs" ; then
        xargs=xargs
        ! have gxargs || xargs=gxargs
        have "$xargs" || die "Unknown shell!"
    fi
}

findhere() {
    find . -maxdepth 1 -name "$1" | $xargs -r0 "$shell" -c 'echo $#' count | wc -l
}

if test $# -ne 1 ; then
    echo "usage: $(basename -- "$0") <file>" >&2
    exit 1
fi
get_shell
get_xargs
lastpwd=""
while test "$(findhere "$1")" -eq 0 ; do
    cd ..
    pwd="$(pwd)"
    if test "$lastpwd" = "$pwd" ; then
        die "Found root or symlink loop"
    fi
    lastpwd="$pwd"
done
find "$pwd" -maxdepth 1 -name "$1"
