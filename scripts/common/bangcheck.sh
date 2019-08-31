#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Warns whether the #! bang is the correct one for the extension name of
# the given files.
###########################################################################
# Copyright (C) 2007, 2008, 2012 by Gavin Beatty
# <public@gavinbeatty.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND  NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###########################################################################
set -e
set -u

prog="$(basename -- "$0")"
prefix="${GAV_PREFIX:-$HOME}"
lf="
"
getopt="${getopt-}"
getopt_long=""
help="${help-}"
env="${env-}"
bin="${bin-}"

have() { type "$@" >/dev/null 2>&1 ; }
if test -n "$getopt" ; then
    e=0
    "$getopt" -T >/dev/null 2>&1 || e=$?
    test $e -ne 4 || getopt_long=1
else
    if have getopt ; then
        getopt="getopt"
        e=0
        getopt -T >/dev/null 2>&2 || e=$?
        if test $e -eq 4 ; then
            getopt_long=1
        fi
    elif have getopt-enhanced ; then
        getopt="getopt-enhanced"
        e=0
        getopt-enhanced -T >/dev/null 2>&2 || e=$?
        if test $e -eq 4 ; then
            getopt_long=1
        fi
    fi
fi

TEXTDOMAIN="$prog" ; export TEXTDOMAIN
TEXTDOMAINDIR="${prefix}/share/locale/sh/" ; export TEXTDOMAINDIR
if ! have gettext.sh ; then
    gettext() { printf "%s" "$@" ; }
    eval_gettext() { fallback_eval_gettext "$@" ; }
    # no need for ngettext etc.
else
    set +u
    set +e
    . gettext.sh
    set -e
    set -u
fi

warn() { echo "warn: $@" >&2 ; }
error() { echo "error: $@" >&2 ; }
die() { echo "error: $@" >&2 ; exit 1 ; }

usage() { echo "usage: ${prog} <file> [ ... ]" ; }
warning_not_readable() {
    local f="$1"
    warn "$(eval_gettext "Cannot read the <file> argument, \`\${f}'.")"
}
warning_unknown_source_type() {
    local f="$1"
    warn "$(eval_gettext "Cannot infer !bang type for the <file> argument, \`\${f}'.")"
}
warning_file_has_incorrect_bang() {
    local f="$1"
    local b="$2"
    local e="$3"
    warn "$(eval_gettext "<file> argument, \`\${f}', has !bang, \`\${b}'. The expected !bang was \`\${e}'.")"
}
warning_no_ext() {
    local f="$1"
    warn "$(eval_gettext "<file> argument, \`\${f}' has no extension, i.e., unknown source type.")"
}
error_no_file_arg() {
    usage >&2
    die "$(eval_gettext "Must give at least one <file> argument.")"
}
get_ext() { echo "$1" | sed -e 's/.*\.//' ; }
test_bang() {
    local test_bang_file="$1"
    local test_bang_bang="$2"
    local test_bang_wantedbang="$3"
    if test x"$test_bang_bang" != x"$test_bang_wantedbang" ; then
        warning_file_has_incorrect_bang "$test_bang_file" "$test_bang_bang" "$test_bang_wantedbang"
    fi
}
do_getopt() {
    if test -n "$getopt_long" ; then
        if (test $# -gt 1) && (test "$1" = "-l") ; then
            shift 2
        fi
    fi
    "$getopt" "$@"
}

main() {
    opts="$(do_getopt -l "help,env,bin" -o "heb" -n "$prog" -- "$@")"
    eval set -- "$opts"

    while test $# -gt 0 ; do
        case "$1" in
        -h|--help) help=1 ;;
        -e|--env) env=1 ;;
        -b|--bin) bin=1 ;;
        --) shift ; break ;;
        *) die "Unknown option: $1" ;;
        esac
        shift
    done
    if test -n "$help" ; then
        usage ; exit 0
    fi
    if test $# -eq 0 ; then
        error_no_file_arg
    fi

    for i in "$@" ; do
        if ! test -r "$i" ; then
            warning_not_readable "$i"
            continue
        fi
        sourcetype="$(echo "$(get_ext "$i")" | tr "[A-Z]" "[a-z]" )"
        if test -z "$sourcetype" ; then
            warning_no_ext "$i"
            continue
        fi
        bang="$(head -n1 "$i")"
        case "$sourcetype" in
        sh)
            exp="#!/bin/sh"
            test -z "$env" || exp="#!/usr/bin/env sh"
            test_bang "$i" "$bang" "$exp"
            ;;
        bash)
            exp="#!/bin/bash"
            test -z "$env" || exp="#!/usr/bin/env bash"
            test_bang "$i" "$bang" "$exp"
            ;;
        py)
            exp="#!/usr/bin/env python"
            test -z "$bin" || exp="#!/usr/bin/python"
            test_bang "$i" "$bang" "$exp"
            ;;
        pl)
            exp="#!/usr/bin/env perl"
            test -z "$bin" || exp="#!/usr/bin/perl"
            test_bang "$i" "$bang" "$exp"
            ;;
        hs)
            exp="#!/usr/bin/env runhaskell"
            test -z "$bin" || exp="#!/usr/bin/runhaskell"
            test_bang "$i" "$bang" "$exp"
            ;;
        txt)
            continue
            ;;
        *)
            warning_unknown_source_type "$i"
            ;;
        esac
    done
}
trap "echo Caught SIGINT ; exit 1 ;" INT
trap "echo Caught SIGTERM ; exit 1 ;" TERM
main "$@"
