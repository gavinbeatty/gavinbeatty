#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
#/***************************************************************************
# *   Copyright (C) 2010 by Gavin Beatty                                    *
# *   gavinbeatty@gmail.com                                                 *
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# *   This program is distributed in the hope that it will be useful,       *
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *   GNU General Public License for more details.                          *
# *                                                                         *
# *   You should have received a copy of the GNU General Public License     *
# *   along with this program; if not, write to the                         *
# *   Free Software Foundation, Inc.,                                       *
# *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
# ***************************************************************************/
set -u
set -e
usage() {
    echo "Usage: merge.sh <result> <splitfile01> <splitfile02>..."
}
main() {
    if test $# -lt 3 ; then
        usage >&2
        exit 1
    fi
    result="$1"
    shift
    for i in "$@" ; do
        cat -- "$i" >> "$result"
        rm -- "$i"
    done
}
trap "echo Caught SIGINT >&2 ; exit 1 ; " INT
trap "echo Caught SIGTERM >&2 ; exit 1 ; " TERM
main "$@"
