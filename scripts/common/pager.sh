#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -e
set -u
trap "echo Caught SIGINT >&1 ; exit 1" INT
trap "echo Caught SIGTERM >&1 ; exit 1" TERM

stdin="${stdin-/dev/stdin}"

if (! test -f "$stdin") && (! test -p "$stdin") ; then
    echo "error: Nothing piped in" >&2
    echo "usage: <someprogram> | pager.sh" >&2
    exit 1
fi
pageropts=""
pager="${PAGER-}"
if ! type "$pager" >/dev/null 2>&1 ; then
    pager=""
fi
if test -z "$pager" ; then
    for i in "more" "less" "cat"; do
        if type "$i" >/dev/null 2>&1 ; then
            pager="$i"
            break
        fi
    done
    if test -z "$pager" ; then
        echo "error: No suitable pager found (even 'cat'!). Please set \$PAGER." >&2
        exit 1
    fi
fi
if echo "$pager" | perl -ne 'chomp; if(/^[[:alpha:]][[:alnum:]]*$/) { exit 0; } exit 1;' >/dev/null 2>&1 ; then
    pageropts="$(echo "$pager" | tr "[a-z]" "[A-Z]")"
    pageropts="$(eval "echo \"\${${pageropts}}\"")"
fi
"$pager" $pageropts "$@"
