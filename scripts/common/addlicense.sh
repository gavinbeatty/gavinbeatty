#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (C) 2007, 2008, 2011 by Gavin Beatty
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
prefix="${GAV_PREFIX-$HOME}"
lf="
"
getopt="${getopt-getopt}"
verbose="${verbose-0}"

have() { type -- "$@" >/dev/null 2>&1 ; }

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

licensetype_default="mit"
valid_sourcetypes="py cpp hpp c h xml sh bash cmake hs"
valid_licensetypes="gpl2later gpl2 lgpl2p1 lgpl2p1later"

sourcetype="${sourcetype-}"
licensetype="${licensetype-$licensetype_default}"
project="${project-}"
patch="${patch-}"
year="${year-}"
tmpdir="${tmpdir-}"

new_author="${FULLNAME-}"
new_email="${EMAIL-}"

usage() {
    cat << EOF
$(eval_gettext "usage: \${prog} [-s <source_type>] [-l <license_type>] \\\${lf}           [-n <project_name>] [-p] [-a <author_name>] [-e <author_email>] \\\${lf}           [-y <year>] [-t <tmpdir>] <file> ...")
EOF
}
help() {
    local name="\${FULLNAME}"
    local email="\${EMAIL}"
    cat <<EOF
$(gettext "Copyright (C) 2007, 2008, 2011 Gavin Beatty <gavinbeatty@gmail.com>")
$(gettext "Licensed under the MIT license: http://www.opensource.org/licenses/MIT")

$(gettext "Adds license, #! and vi mode settings.")

$(usage)
$(gettext "Options:")
 -h:
   $(gettext "Prints this help message.")
 -v:
   $(gettext "Print a message when files are newly or already patched.")
 -s <source_type>:
   $(eval_gettext "Don't infer the source type - explicitly use <source_type>.\${lf}   Valid <source_type>s are (case insensitive):\${lf}     \${valid_sourcetypes}")
 -l <license_type>:
   $(eval_gettext "Override the default license type, \`\${licensetype_default}'.\${lf}   Valid <license_type>s are (case insensitive):\${lf}     \${valid_licensetypes}")
 -p:
   $(gettext "Patch the file with the changes.")
 -n <project_name>:
   $(gettext "The name of the project. Defaults to the filename.")
 -a <author_name>:
   $(eval_gettext "The name of the author. Defaults to the value of\${lf}   \${name}.")
 -e <author_email>:
   $(eval_gettext "The e-mail address of the author. Defaults to the\${lf}   value of \${email}.")
 -y <year>:
   $(gettext "Use the given <year> instead of finding it using date.")
 -t <tmpdir>:
   $(eval_gettext "Use the given <tmpdir> instead of generating one using\${lf}   \`tmpfile.sh -d\`.")
EOF
}
verbose() {
    if test "$1" -le "$verbose" ; then
        shift
        echo "$@"
    fi
}

cleanup() {
    if test -d "$tmpdir" ; then
        rm -rf -- "$tmpdir" || true
    fi
}

############################
## User created functions ##
############################
warning_unable_to_calculate_source_type_for() {
    f="$1"
    echo "$(eval_gettext "warning: Unable to infer <source_type> for the file, \`\${f}'.")" >&2
}
warning_empty_source_type() {
    s="$1"
    echo "$(eval_gettext "warning: Empty <source_type> for <file>, \`\${s}'.")" >&2
}
warning_unknown_source_type() {
    s="$1"
    echo "$(eval_gettext "warning: Unknown source type \`\${l}'.")" >&2
}
warning_unknown_license_type() {
    l="$1"
    echo "$(eval_gettext "warning: Unknown license type \`\${l}'.")" >&2
}

mit() {
    cat <<EOF
${project}
Copyright (C) ${year} by ${new_author}
${new_email}

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
}

gpl2later() {
    cat <<EOF
${project}
Copyright (C) ${year} by ${new_author}
${new_email}

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the
Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
EOF
}

gpl2() {
    cat <<EOF
${project}
Copyright (C) ${year} by ${new_author}
${new_email}

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the
Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
EOF
}

lgpl2p1later() {
    cat <<EOF
${project}
Copyright (C) ${year} by ${new_author}
${new_email}

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the
Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA.
EOF
}

lgpl2p1() {
    cat <<EOF
${project}
Copyright (C) ${year} by ${new_author}
${new_email}

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the
Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA.
EOF
}

hs_license() {
    cat <<EOF
#!/usr/bin/env runhaskell
{- vi: set ft=haskell expandtab shiftwidth=4 tabstop=4: -}
{--------------------------------------------------------------------------
$(eval "$1")
--------------------------------------------------------------------------}
EOF
}

sh_license() {
    cat <<EOF
#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
###########################################################################
$(eval "$1" | sed -e 's/^/# /')
###########################################################################
EOF
}
bash_license() {
    cat <<EOF
#!/usr/bin/env bash
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
###########################################################################
$(eval "$1" | sed -e 's/^/# /')
###########################################################################
EOF
}

py_license() {
    cat <<EOF
#!/usr/bin/env python
# vi: set ft=python expandtab shiftwidth=4 tabstop=4:
###########################################################################
$(eval "$1" | sed -e 's/^/# /')
###########################################################################
EOF
}

c_license() {
    cat <<EOF
/* vi: set ft=c expandtab shiftwidth=4 tabstop=4: */
/**************************************************************************
$(eval "$1")
**************************************************************************/
EOF
}
cpp_license() {
    cat <<EOF
/* vi: set ft=cpp expandtab shiftwidth=4 tabstop=4: */
/**************************************************************************
$(eval "$1")
**************************************************************************/
EOF
}
hpp_license() { cpp_license "$1" ; }
# use cpp_license - no harm
h_license() { cpp_license "$1" ; }

xml_license() {
    cat <<EOF
<!-- vi: set ft=xml expandtab shiftwidth=2 tabstop=2: -->
<!--
$(eval "$1")
-->


EOF
}

cmake_license() {
    cat <<EOF
# vi: set ft=cmake expandtab shiftwidth=4 tabstop=4:
###########################################################################
$(eval "$1" | sed -e 's/^/# /')
###########################################################################


EOF
}

get_ext() { echo "$1" | sed -e 's/.*\.//' ; }
get_source_type() {
    get_source_type_sourcefile="$1"

    get_source_type_ext="$(get_ext "$get_source_type_sourcefile")"
    if test -n "$get_source_type_ext" ; then
        if have "${get_source_type_ext}_license" ; then
            echo "$get_source_type_ext"
            return 0
        elif test x"$get_source_type_ext" = x"in" ; then
            get_source_type_ext="$(get_ext "$(echo "$get_source_type_sourcefile" | sed -e "s/\\.${get_source_type_ext}\$//")")"
            if have "${get_source_type_ext}_license" ; then
                echo "$get_source_type_ext"
                return 0
            fi
        fi
    fi
    if test x"$get_source_type_sourcefile" = x"CMakeLists.txt" ; then
        echo "cmake"
        return 0
    fi
    return 0
}
error_no_file_arg() {
    echo "$(eval_gettext "error: No <file> argument given.")" >&2
    usage >&2
    exit 1
}
error_unknown_source_type() {
    local s="$1"
    echo "$(eval_gettext "error: Don't know the <source_type> \`\${s}'.")" >&2
    usage >&2
    exit 1
}
error_unknown_license_type() {
    local l="$1"
    echo "$(eval_gettext "error: Don't know the <license_type> \`\${l}'.")" >&2
    usage >&2
    exit 1
}

concat_license_with() {
    local sourcet="$1"
    local licenset="$2"
    local file="$3"
    eval "${sourcet}_license \"${licenset-gpl2later}\""
    cat -- "$file" || true
}


main() {
    missing=
    sep=
    for i in "tmpfile.sh" "diff" "dirname" "abspath.py" "date" "checklicensed.sh" ; do
        if ! have "$i" ; then
            missing="${missing}${sep}${i}"
            sep=", "
        fi
    done
    if test -n "$missing" ; then
        echo "$(eval_gettext "error: The following programs are required: \${missing}.")" >&2
        exit 1
    fi

    opts="$("$getopt" -n "$prog" -o "hvpl:s:n:a:e:y:t:" -- "$@")"
    eval set -- "$opts"

    while true ; do
        case "$1" in
        -v) verbose=$(( $verbose + 1 )) ; ;;
        -p) patch=1 ; ;;
        -l) licensetype="$2" ; shift ; ;;
        -s) sourcetype="$2" ; shift ; ;;
        -n) project="$2" ; shift ; ;;
        -a) author_name="$2" ; shift ; ;;
        -e) author_email="$2" ; shift ; ;;
        -y) year="$2" ; shift ; ;;
        -t) tmpdir="$2" ; shift ; ;;
        -h) help ; exit 0 ; ;;
        --) shift ; break ; ;;
        *) echo "$(eval_gettext "error: unknown option \${o}.")" >&2 ; exit 1 ; ;;
        esac
        shift
    done
    licensetype="$(echo "$licensetype" | tr "[A-Z]" "[a-z]")"
    if test -n "$licensetype" ; then
        if ! have "$licensetype" ; then
            error_unknown_license_type "$licensetype"
        fi
    fi

    sourcetype="$(echo "$sourcetype" | tr "[A-Z]" "[a-z]")"
    if test -n "$sourcetype" ; then
        if ! have "${sourcetype}_license" ; then
            error_unknown_source_type "$sourcetype"
        fi
    fi

    if test $# -eq 0 ; then
        error_no_file_arg
    fi

    if test -z "$year" ; then year="$(date +"%Y")" ; fi
    if test -z "$TMPDIR" ; then TMPDIR="/tmp" ; fi
    if test -z "$tmpdir" ; then tmpdir="$(tmpfile.sh -d -p "${TMPDIR}/${prog}-")" ; fi

    type=""
    haveproject=
    if test -n "$project" ; then haveproject=1 ; fi
    for i in "$@" ; do
        if test -z "$haveproject" ; then project="$(basename -- "$i")" ; fi
        if test -z "$(checklicensed.sh -- "$i")" ; then
            verbose 1 "$(eval_gettext "The file, \`\${i}', already has a license. Skipping.")"
            continue
        fi

        if test -z "$sourcetype" ; then
            sourcetype="$(get_source_type "$i")"
        fi

        echo "${i}: ${sourcetype}"
        if test -z "$sourcetype" ; then
            warning_unable_to_calculate_source_type_for "$i"
            continue
        fi

        if test -n "$patch" ; then
            i_prepended="$(tmpfile.sh -p "${tmpdir}/prepended-")"
            concat_license_with "$sourcetype" \
                "$licensetype" "$i" > "$i_prepended"
            mv -- "$i_prepended" "$i"
            verbose 1 "$(eval_gettext "Patched file \`\${i}'.")"
        else
            editedfile="${tmpdir}/new$(abspath.py -- ${i})"
            tmporigfile="${tmpdir}/old$(abspath.py -- ${i})"

            editedfile_dirtree="$(dirname -- "$editedfile")"
            tmporigfile_dirtree="$(dirname -- "$tmporigfile")"
            test -d "$editedfile_dirtree" || mkdir -p -- "$editedfile_dirtree"
            test -d "$tmporigfile_dirtree" || mkdir -p -- "$tmporigfile_dirtree"

            cp -- "$i" "$tmporigfile"
            cp -- "$i" "$editedfile"   # copy this here so permission are same
                                                        #  when it's overwritten
            concat_license_with "$sourcetype" \
                "$licensetype" "$tmporigfile" > "$editedfile"
            diff -Nur -- "$tmporigfile" "$editedfile" && true
        fi
    done
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
trap "cleanup" 0
main "$@"
