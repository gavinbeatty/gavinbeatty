#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM

progname="$(basename -- "$0")"

usage() {
    echo "usage: ${progname} [<svnpath>]"
}
    

if test $# -eq 0 ; then
    eval set -- "."
elif test $# -ne 1 ; then
    usage >&2
    exit 1
fi

if ! type svnlastcommit.sh >/dev/null 2>&1 ; then
    echo "requirement not met: please install svnlastcommit.sh" >&2
    exit 1
fi

if ! svn info "$1" >/dev/null 2>&1 ; then
    echo 'not an svn url or checkout!' >&2
    exit 1
fi

get_externals() {
    svn propget svn:externals "$1" | awk \
        '{ if ($2 ~ /-r[[:digit:]][[:digit:]]*/) { printf("%s %s\n", $1, $3); } else if ($0 != "") { print $0; } }'
}

get_externals "$1" | while read name url ; do
    echo "${name} -r$(svnlastcommit.sh "$url") ${url}"
done

