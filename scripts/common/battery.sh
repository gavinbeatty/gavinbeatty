#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (C) 2007, 2008, 2009, 2012 by Gavin Beatty
# <gavinbeatty@gmail.com>
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
getopt="${getopt-getopt}"
verbose="${verbose-0}"
help="${help-}"

plat="${plat-}"
fxn="get_percentage"

die() { echo "error: $@" >&2 ; exit 1 ; }
usage() {
    echo "usage: $prog [-p] [-t]"
}
help() {
    cat << EOF
Copyright (C) 2007, 2008, 2009, 2012 by Gavin Beatty
<gavinbeatty@gmail.com>

Print details about the battery power remaining.

$(usage)
Options:
 -p:
  Print the percentage battery power remaining"
 -t:
  Print the estimated time remaining"
EOF
}

error_no_bat() {
    echo "This device has no battery, i.e., no file \`/proc/acpi/battery/BAT0'" >&2
    exit 1
}
get_state() {
    awk '{if(tolower($0)~/charging state/){print $3}}' < "${1}/state"
}
time_to_hh_mm() {
    local h="$(echo "scale=0; $1 / 1" | bc)"
    echo "${h}:$(echo "scale=0; $1 - $h" | bc | sed -e 's/^0//' -e 's/^\.//')"
}
get_percentage_darwin() {
    LC_ALL=C pmset -g batt \
        | LC_ALL=C awk '{if(tolower($0)~/battery/){gsub(/[^0-9]/,"",$2);print $2}}'
}
get_percentage_linux() {
    local percentage_fullbat=""
    local percentage_curbat=""
    local percentage_avg_tmp=""
    local percentage_total="0"
    local percentage_count="0"
    for percentage_i in "$@" ; do
        percentage_fullbat="$(grep 'last full capacity' "${percentage_i}/info" | awk '{ print $4 }')"
        percentage_curbat="$(grep 'remaining capacity' "${percentage_i}/state" | awk '{ print $3 }')"
        percentage_avg_tmp="$(expr "$(expr "${percentage_curbat}" \* 100)" / "${percentage_fullbat}")"
        echo "$(basename -- "${percentage_i}") $(state "$percentage_i") ${percentage_avg_tmp} percent"
        percentage_total="$(expr "$percentage_total" + "$percentage_avg_tmp")"
        percentage_count="$(expr "$percentage_count" + 1)"
    done
    if test "$percentage_count" -ne 1 ; then
        echo "$(gettext "Total"): $(expr "$percentage_total" / "$percentage_count")%"
    fi
}
get_time_darwin() {
    LC_ALL=C pmset -g batt | LC_ALL=C awk '{if(tolower($0)~/battery/){print $4}}'
}
get_time_linux() {
    local time_count="0"
    local time_cap_remaining=""
    local time_cap_rate=""
    local time_hrsleft=""
    for time_i in "$@" ; do
        time_cap_remaining="$(awk '{if(tolower($0)~/remaining capacity/){print $3}}' < "${time_i}/state")"
        time_cap_rate="$(grep '{if(tolower($0)~/present rate/){print $3}}' < "${time_i}/state")"
        time_hrsleft="$(echo "scale=2; ${time_cap_remaining}.0 / ${time_cap_rate}.0;" | bc)"
        echo "$(basename -- "$time_i") $(get_state "$time_i") $(time_to_hh_mm "$time_hrsleft") $(gettext "hrs")"
        time_count="$(expr "$time_count" + 1)";
    done
}

main() {
    opts="$("$getopt" -n "$prog" -o "ptdlh" -- "$@")"
    eval set -- "$opts"

    while test $# -gt 0 ; do
        case "$1" in
        -p) fxn="get_percentage" ;;
        -t) fxn="get_time" ;;
        -d) plat=darwin ;;
        -l) plat=linux ;;
        -h) help=1 ;;
        --) shift ; break ;;
        *) die "Unknown option: $1" ;;
        esac
        shift
    done
    test -z "$help" || { help ; exit 0 ; }
    if test -z "$fxn" ; then
        die "No command found!"
    fi
    if test -z "$plat" ; then
        plat="$(uname -s | tr '[A-Z]' '[a-z]')"
    fi

    case "$plat" in
    darwin)
        "${fxn}_darwin"
        ;;
    linux)
        if ! test -d "/proc/acpi/battery/BAT0" ; then
            error_no_bat
        fi
        "${fxn}_linux" /proc/acpi/battery/BAT*
        ;;
    *) die "Unsupported platform: ${plat-(none given)}" ;;
    esac
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
