#!/usr/bin/env bash

# (C) 2002-2003 Dan Allen and Stefan Kamphausen

# Written by Dan Allen <dan@mojavelinux.com>
# - small additions by Stefan Kamphausen
# - better completion code by Robi Malik robi.malik@nexgo.de
# - trailing path support by Damon Harper <ds+dev-cdargs@usrbin.ca> Feb 2006

# Modified by: Gavin Beatty <gavinbeatty@gmail.com> 2007, 2011
test -n "${gav_cdargs_bash_guard-}" && return 0
gav_cdargs_bash_guard=1
iecho ".cdargs.bash"

# Globals
CDARGS_SORT=0   # set to 1 if you want mark to sort the list
CDARGS_NODUPS=1 # set to 1 if you want mark to delete dups

# --------------------------------------------- #
# Run the cdargs program to get the target      #
# directory to be used in the various context   #
# This is the fundamental core of the           #
# bookmarking idea.  An alias or substring is   #
# expected and upon receiving one it either     #
# resolves the alias if it exists or opens a    #
# curses window with the narrowed down options  #
# waiting for the user to select one.           #
#                                               #
# @param  string alias                          #
#                                               #
# @access private                               #
# @return 0 on success, >0 on failure           #
# --------------------------------------------- #
function _cdargs_get_dir ()
{
    local bookmark extrapath
    # if there is one exact match (possibly with extra path info after it),
    # then just use that match without calling cdargs
    if test -e "$HOME/.cdargs" ; then
        dir=`/bin/grep "^$1 " "$HOME/.cdargs"`
        if test -z "$dir" ; then
            bookmark="${1/\/*/}"
            if test "$bookmark" != "$1" ; then
                dir=`/bin/grep "^$bookmark " "$HOME/.cdargs"`
                extrapath=`echo "$1" | /bin/sed 's#^[^/]*/#/#'`
            fi
        fi
        test -n "$dir" && dir=`echo "$dir" | /bin/sed 's/^[^ ]* //'`
    fi
    if (test -z "$dir") || (test "$dir" != "${dir/
/}") ; then
        # okay, we need cdargs to resolve this one.
        # note: intentionally retain any extra path to add back to selection.
        dir=
        if cdargs --noresolve "${1/\/*/}"; then
            dir=`cat "$HOME/.cdargsresult"`
            /bin/rm -f "$HOME/.cdargsresult";
        fi
    fi
    if test -z "$dir" ; then
        echo "Aborted: no directory selected" >&2
        return 1
    fi
    test -n "$extrapath" && dir="$dir$extrapath"
    if ! test -d "$dir" ; then
        echo "Failed: no such directory '$dir'" >&2
        return 2
    fi
}

# --------------------------------------------- #
# Perform the command (cp or mv) using the      #
# cdargs bookmark alias as the target directory #
#                                               #
# @param  string command argument list          #
#                                               #
# @access private                               #
# @return void                                  #
# --------------------------------------------- #
function _cdargs_exec ()
{
    local arg dir i last call_with_browse

    # Get the last option which will be the bookmark alias
    eval last=\${$#};

    # Resolve the bookmark alias.  If it cannot resolve, the
    # curses window will come up at which point a directory
    # will need to be choosen.  After selecting a directory,
    # the function will continue and $_cdargs_dir will be set.
    if test -e $last ; then
        last=
    fi
    if _cdargs_get_dir "$last"; then
        # For each argument save the last, move the file given in
        # the argument to the resolved cdargs directory
        i=1;
        for arg; do
            if test $i -lt $# ; then
                $command "$arg" "$dir";
            fi
            let i=$i+1;
        done
    fi
}

# --------------------------------------------- #
# Prepare to move file list into the cdargs     #
# target directory                              #
#                                               #
# @param  string command argument list          #
#                                               #
# @access public                                #
# @return void                                  #
# --------------------------------------------- #
function mvb ()
{
    local command

    command='mv -i';
    _cdargs_exec $*;
}

# --------------------------------------------- #
# Prepare to copy file list into the cdargs     #
# target directory                              #
#                                               #
# @param  string command argument list          #
#                                               #
# @access public                                #
# @return void                                  #
# --------------------------------------------- #
function cpb ()
{
    local command

    command='cp -i';
    _cdargs_exec $*;
}

# --------------------------------------------- #
# Change directory to the cdargs target         #
# directory                                     #
#                                               #
# @param  string alias                          #
#                                               #
# @access public                                #
# @return void                                  #
# --------------------------------------------- #
function cdb () 
{ 
    local dir

    _cdargs_get_dir "$1" && cd "$dir";  # removed the pwd echo
}
alias cb='cdb'
alias cv='cdb'

# --------------------------------------------- #
# Mark the current directory with alias         #
# provided and store as a cdargs bookmark       #
# directory                                     #
#                                               #
# @param  string alias                          #
#                                               #
# @access public                                #
# @return void                                  #
# --------------------------------------------- #
function mark () 
{ 
    local tmpfile

    # first clear any bookmarks with this same alias, if file exists
    if [[ "$CDARGS_NODUPS" && -e "$HOME/.cdargs" ]]; then
        tmpfile=`echo ${TEMP:-${TMPDIR:-/tmp}} | /bin/sed -e "s/\\/$//"`
        tmpfile=$tmpfile/cdargs.$USER.$$.$RANDOM
        /bin/grep -v "^$1 " "$HOME/.cdargs" > $tmpfile && 'mv' -f $tmpfile "$HOME/.cdargs";
    fi
    # add the alias to the list of bookmarks
    cdargs --add=":$1:`pwd`"; 
    # sort the resulting list
    if [ "$CDARGS_SORT" ]; then
        sort -o "$HOME/.cdargs" "$HOME/.cdargs";
    fi
}
# Oh, no! Not overwrite 'm' for stefan! This was 
# the very first alias I ever wrote in my un*x 
# carreer and will always be aliased to less...
# alias m='mark'

# --------------------------------------------- #
# Mark the current directory with alias         #
# provided and store as a cdargs bookmark       #
# directory but do not overwrite previous       #
# bookmarks with same name                      #
#                                               #
# @param  string alias                          #
#                                               #
# @access public                                #
# @return void                                  #
# author: SKa                                   #
# --------------------------------------------- #
function ca ()
{
    # add the alias to the list of bookmarks
    cdargs --add=":$1:`pwd`"; 
}

# --------------------------------------------- #
# Bash programming completion for cdargs        #
# Sets the $COMPREPLY list for complete         #
#                                               #
# @param  string substring of alias             #
#                                               #
# @access private                               #
# @return void                                  #
# --------------------------------------------- #
function _cdargs_aliases ()
{
    local cur bookmark dir strip oldIFS
    COMPREPLY=()
    if test -e "$HOME/.cdargs" ; then
        cur=${COMP_WORDS[COMP_CWORD]}
        if test "$cur" != "${cur/\//}" ; then # if at least one /
            bookmark="${cur/\/*/}"
            dir=`/bin/grep "^$bookmark " "$HOME/.cdargs" | /bin/sed 's#^[^ ]* ##'`
            if test -n "$dir" -a "$dir" = "${dir/
/}" -a -d "$dir" ; then
                strip="${dir//?/.}"
                oldIFS="$IFS"
                IFS='
'
                COMPREPLY=( $(
                    compgen -d "$dir`echo "$cur" | /bin/sed 's#^[^/]*##'`" \
                        | /bin/sed -e "s/^$strip/$bookmark/" -e "s/\([^\/a-zA-Z0-9#%_+\\\\,.-]\)/\\\\\\1/g" ) )
                IFS="$oldIFS"
            fi
        else
            COMPREPLY=( $( (echo $cur ; cat "$HOME/.cdargs") | \
                           awk 'BEGIN {first=1}
                                 {if (first) {cur=$0; l=length(cur); first=0}
                                 else if (substr($1,1,l) == cur) {print $1}}' ) )
        fi
    fi
    return 0
}

# --------------------------------------------- #
# Bash programming completion for cdargs        #
# Set up completion (put in a function just so  #
# `nospace' can be a local variable)            #
#                                               #
# @param  none                                  #
#                                               #
# @access private                               #
# @return void                                  #
# --------------------------------------------- #
_cdargs_complete() {
  local nospace=
  [ "${BASH_VERSINFO[0]}" -ge 3 -o \( "${BASH_VERSINFO[0]}" = 2 -a \( "${BASH_VERSINFO[1]}" = 05a -o "${BASH_VERSINFO[1]}" = 05b \) \) ] && nospace='-o nospace'
  complete $nospace -S / -X '*/' -F _cdargs_aliases cv cb cdb
}

_cdargs_complete
