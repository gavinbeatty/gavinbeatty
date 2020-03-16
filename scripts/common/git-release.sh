#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
set -u
set -e
if (test $# -lt 2) || (test $# -gt 3) ; then
    echo "usage: $(basename -- "$0") <tag> <prefix> [<output>]" >&2
    exit 1
fi

tag="$1"
prefix="$2"
output="../$prefix"
if test $# -gt 2 ; then
    output="$3"
fi
set -x
git archive --format tar --prefix="${prefix}/" "$tag" --output "$output".tar
bzip2 -9 "$output".tar
git archive --format zip --prefix="${prefix}/" "$tag" --output "$output".zip

