#!/bin/sh
# vi: set ft=sh et ts=4 sw=4:
# Copyright (c) 2012 Gavin Beatty <gavinbeatty@gmail.com>
# Licensed under the MIT license: http://www.opensource.org/licenses/MIT
set -e
set -u
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
cleanup() { true ; }
trap " echo Unexpected exit >&2 ; cleanup ; exit 1 ; " 0
prog="$(basename -- "$0")"
usage() { echo "usage: $prog [options] <file>..." ; }
pax() { trap ' cleanup ; ' 0 ; exit "$@" ; }
die() { echo "error: $@" >&2 ; pax 1 ; }
udie() { usage >&2 ; die "$@" ; }
warn() { echo "warn: $@" >&2 ; }
have() { type "$@" >/dev/null 2>&1 ; }

lf="
"
license_type_default="mit"
valid_source_types="py pl cpp cc hpp c h sh bash dash cmake hs"
valid_license_types="mit gpl2later gpl2 lgpl2p1 lgpl2p1later"
getopt="${GETOPT:-getopt}"
verbose="${VERBOSE:-0}"
source_type="${SOURCE_TYPE:-}"
license_type="${LICENSE_TYPE:-$license_type_default}"
patch="${PATCH:-}"
project="${PROJECT:-}"
author_name="${FULLNAME:-}"
author_email="${EMAIL:-}"
if test -n "${COPYRIGHT_WHO:-}" ; then
    author_name="$COPYRIGHT_WHO"
    author_email=
fi
year="${YEAR:-}"
check_already="${CHECK_ALREADY:-}"
strip_copyright="${STRIP_COPYRIGHT:-}"
strip_vi_modeline="${STRIP_VI_MODELINE:-}"
h_is_hpp="${H_IS_HPP:-}"
tmpdir="${TMPDIR:-}"
within="${WITHIN:-5}"
force_update="${FORCE_UPDATE:-}"
vi_within="${VI_MODELINE_WITHIN:-$within}"
one_line="${ONE_LINE:-}"
no_copyright="${NO_COPYRIGHT:-}"
no_project="${NO_PROJECT:-}"
vi="${VI_MODELINE:-}"
no_vi="${NO_VI_MODELINE:-}"
by="${BY:- }"
no_cleanup="${NO_CLEANUP:-}"

help() {
    cat <<EOF
Copyright (c) 2012 Gavin Beatty <gavinbeatty@gmail.com>
Licensed under the MIT license: http://www.opensource.org/licenses/MIT

Adds license, #! and vi mode settings.

$(usage)
    -h, --help          prints this help message
    -v, --verbose       print a message when files are newly or already patched
    -s <source-type>    don't infer the source type - explicitly use <source_type>
                        valid <source_type>s are (case insensitive): ${valid_source_types}
    -l <license-type>   override the default license type, ${license_type_default}
                        valid <license_type>s are (case insensitive): ${valid_license_types}
    -p, --patch         patch the file with the changes
    -n <project-name>   the name of the project: defaults to the filename
    -a <author-name>    the name of the author: defaults to the value of \${FULLNAME}
    -e <author-email>   the e-mail address of the author: defaults to the value of \${EMAIL}
    -y <year>           use the given <year> instead of finding it using \`date\`
    -A, --check-already check if it already has a copyright, and if so, skip
    -S, --strip-copyright
                        strips existing copyright line if it exists (see <within>)
    -M, --strip-vi-modeline
                        strips existing vi-modeline line if it exists (see <vi-modeline-within>)
    -H, --h-is-hpp      header files are now assumed to be C++
    -t <tmpdir>         use the given <tmpdir>: defaults to either \${TMPDIR} or \`tmpfile.sh -d\`
    -w <within>         searches for existing copyright in the first <within> lines
    --vi-modeline-within <vi-modeline-within>
                        searches for existing vi modeline within so many lines
    -f, --force-update  equivalent to -w 0
    -1, --one-line      put the copyright in a one line comment
    -C, --no-copyright  don't add any copyright line
    -N, --no-project    don't default the <project-name> to be the filename: implies -n ""
    -m <vi-modeline>    use the given modeline after setting ft=...
    -V, --no-vi-modeline
                        don't add the modeline for vi(m)
    -B, --by            say by <author-name>, instead of just <author-name>
    --no-cleanup        don't clean up the temporary files and directories
EOF
}
verbose() {
    if test "$1" -le "$verbose" ; then
        shift
        echo "$@"
    fi
}
cleanup() {
    if test -z "$no_cleanup" ; then
        rm -rf -- "$tmpdir" || true
    fi
}

copyright() {
    if test -z "$no_copyright" ; then
        local s="${project}${project:+$lf}Copyright (c) ${year}"
        echo "${s}${by:- }${author_name}${author_email:+$lf}${author_email}"
    fi
}

mit() {
    cat <<EOF
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

noejoin() {
    local sep_="$1"
    local sep=
    local i=
    local s=
    shift
    for i in "$@" ; do
        if test -n "$i" ; then
            s="${s}${sep}$i"
            sep="$sep_"
        fi
    done
    echo "$s"
}

# <bang>
# <modeline>
# <copyright>
# <license>
hs_license() {
    local m=
    local c="$(copyright)"
    if test -n "$c" ; then c="$(printf "%s\n" "$c" | sed 's/^/-- /')" ; fi
    local l=
    if test -n "$license_type" ; then l="$("$license_type")" ; fi
    if test -n "$l" ; then l="{-${lf}${l}${lf}-}" ; fi
    local v="${vi:+ }${vi:- et sw=4 ts=4}"
    if test -z "$no_vi" ; then m="-- vi: set ft=haskell${v}:" ; fi
    noejoin "$lf" "$m" "$c" "$l" | sed -e 's/^{-\s*-}$//' -e 's/^--\s\s*$//'
}
hash_license_() {
    local b="$1"
    local ft="$2"
    shift 2
    local m=
    local c="$(copyright)"
    if test -n "$c" ; then c="$(echo "$c" | sed 's/^/# /')" ; fi
    local l=
    if test -n "$license_type" ; then l="$("$license_type" | sed 's/^/# /')" ; fi
    if test -n "$has_bang" ; then b= ; fi
    local v="${vi:+ }${vi:- et sw=4 ts=4}"
    if test -z "$no_vi" ; then m="# vi: set ft=${ft}${v}:" ; fi
    noejoin "$lf" "$b" "$m" "$c" "$l" | sed 's/^#\s\s*$/#/'
}
sh_license() { hash_license_ "#!/bin/sh" sh ; }
bash_license() { hash_license_ "#!/usr/bin/bash" sh ; }
dash_license() { hash_license_ "#!/usr/bin/dash" sh ; }
py_license() { hash_license_ "#!/usr/bin/python" python ; }
pl_license() { hash_license_ "#!/usr/bin/perl" perl ; }
c_license() {
    local m=
    local c="$(copyright)"
    if test -n "$c" ; then c="$(echo "$c" | sed 's#\(.*\)#/* \1 */#')" ; fi
    local l=
    if test -n "$license_type" ; then l="$("$license_type")" ; fi
    if test -n "$l" ; then l="/*${lf}${l}${lf}*/" ; fi
    local v="${vi:+ }${vi:- et sw=4 ts=4}"
    if test -z "$no_vi" ; then m="/* vi: set ft=c${v}: */" ; fi
    noejoin "$lf" "$m" "$c" "$l" | sed 's#^/\*\s*\*/$##'
}
cpp_license() {
    local m=
    local c="$(copyright)"
    if test -n "$c" ; then c="$(echo "$c" | sed 's#^#// #')" ; fi
    local l=
    if test -n "$license_type" ; then l="$("$license_type")" ; fi
    if test -n "$l" ; then l="/*${lf}${l}${lf}*/" ; fi
    local v="${vi:+ }${vi:- et sw=4 ts=4}"
    if test -z "$no_vi" ; then m="// vi: set ft=cpp${v}:" ; fi
    noejoin "$lf" "$m" "$c" "$l" | sed -e 's#^/\*\s*\*/$##' -e 's#^//\s\s*$##'
}
cc_license() { cpp_license ; }
cxx_license() { cpp_license ; }
hpp_license() { cpp_license ; }
hxx_license() { cpp_license ; }
ixx_license() { cpp_license ; }
h_license() {
    if test -n "$h_is_hpp" ; then cpp_license
    else c_license ; fi
}
cmake_license() { hash_license_ "" cmake ; }

get_ext() { echo "$1" | sed 's/.*\.//' ; }
get_source_type() {
    local ext="$(get_ext "$1")"
    if test -n "$ext" ; then
        if have "${ext}_license" ; then
            echo "$ext"
            return 0
        elif test "$ext" = "in" ; then
            ext="$(get_ext "$(echo "$1" | sed "s/\\.${ext}\$//")")"
            if have "${ext}_license" ; then
                echo "$ext"
                return 0
            fi
        fi
    fi
    if test "$1" = "CMakeLists.txt" ; then
        echo "cmake"
        return 0
    fi
    return 0
}
warning_unable_to_calculate_source_type_for() {
    warn "unable to infer <source_type> for the file, $1"
}
warning_empty_source_type() {
    warn "empty <source_type> for <file>, $1"
}
warning_unknown_source_type() {
    warn "unknown source type $1"
}
warning_unknown_license_type() {
    warn "unknown license type $1"
}
warn_not_patching_and_not_readable() {
    warn "cannot read $1"
}
error_no_file_arg() {
    udie "no <file> argument given"
}
error_unknown_source_type() {
    udie "don't know the <source_type> $1"
}
error_unknown_license_type() {
    udie "don't know the <license_type> $1"
}

strip_copyright_filter() {
    if test -n "$strip_copyright" ; then
        awk -v n="$within" ' { if(NR>n || tolower($0)!~/\<copyright\>/){print;} } '
    else
        cat
    fi
}
strip_vi_filter() {
    if test -n "$strip_vi_modeline" ; then
        case "$vi_within" in
        infinity|infty|x|omega) awk \
            ' { if(tolower($0)!~/\<(vi|vim|ex)[^[:alpha:]]*:/){print;} } '
        ;;
        *) awk -v n="$vi_within" \
            ' { if(NR>n || tolower($0)!~/\<(vi|vim|ex)[^[:alpha:]]*:/){print;} } '
        ;;
        esac
    else
        cat
    fi
}
concat_license_with() {
    if test -n "$has_bang" ; then
        head -n 1 -- "$1"
        local s="$("${source_type}_license")"
        if test -n "$s" ; then echo "$s" ; fi
        sed '1d' "$1" | strip_copyright_filter | strip_vi_filter
    else
        local s="$("${source_type}_license")"
        if test -n "$s" ; then echo "$s" ; fi
        cat -- "$1" | strip_copyright_filter | strip_vi_filter
    fi
}

main() {
    longopts=
    e=0
    "$getopt" -T >/dev/null 2>&1 || e=$?
    if test "$e" -eq 4 ; then
        longopts="-l help,verbose,patch,license-type:,source-type:"
        longopts="${longopts},project:,project-name:,author-name:"
        longopts="${longopts},author-email:,year:,check-already"
        longopts="${longopts},strip-copyright,strip-existing-copyright"
        longopts="${longopts},strip-vi-modeline,strip-vim-modeline"
        longopts="${longopts},strip-existing-vi-modeline,strip-existing-vim-modeline"
        longopts="${longopts},h-is-hpp,tmpdir:"
        longopts="${longopts},within:,copyright-within:"
        longopts="${longopts},vi-modeline-within:,vim-modeline-within:"
        longopts="${longopts},oneline,one-line"
        longopts="${longopts},force,force-update"
        longopts="${longopts},no-copyright,no-project"
        longopts="${longopts},vi:,vim:,vi-modeline:,vim-modeline:"
        longopts="${longopts},no-vi,no-vim,no-vi-modeline,no-vim-modeline"
        longopts="${longopts},no-by,no-cleanup,no-clean-up"
    fi
    opts="$("$getopt" -n "$prog" -o "hvpl:s:n:a:e:y:ASMHt:w:1fCNm:VB" $longopts -- "$@")"
    eval set -- "$opts"
    while true ; do
        case "$1" in
        -h|--help) help ; pax ;;
        -v|--verbose) verbose=$(( verbose + 1 )) ;;
        -p|--patch) patch=1 ;;
        -l|--license-type) license_type="$2" ; shift ;;
        -s|--source-type) source_type="$2" ; shift ;;
        -n|--project|--project-name) project="$2" ; shift ;;
        -a|--author-name) author_name="$2" ; shift ;;
        -e|--author-email) author_email="$2" ; shift ;;
        -y|--year) year="$2" ; shift ;;
        -A|--check-already) check_already=1 ;;
        -S|--strip-copyright|--strip-existing-copyright) strip_copyright=1 ;;
        -M|--strip-vi-modeline|--strip-vim-modeline|--strip-existing-vi-modeline|--strip-existing-vim-modeline)
            strip_vi_modeline=1 ;;
        -H|--h-is-hpp) h_is_hpp=1 ;;
        -t|--tmpdir) tmpdir="$2" ; shift ;;
        -w|--within|--copyright-within) within="$2" ; shift ;;
        --vi-modeline-within|--vim-modeline-within) vi_within="$2" ; shift ;;
        -f|--force|--force-update) force_update=0 ;;
        -1|--oneline|--one-line) one_line=1 ;;
        -C|--no-copyright) no_copyright=1 ;;
        -N|--no-project) no_project=1 ; project= ;;
        -m|--vi|--vim|--vi--modeline|--vim-modeline) vi="$2" ; shift ;;
        -V|--no-vi|--no-vim|--no-vi-modeline|--no-vim-modeline) no_vi=1 ;;
        -B|--no-by) by=" by " ;;
        --no-cleanup|--no-clean-up) no_cleanup=1 ;;
        --) shift ; break ;;
        *) udie "unknown option $1" ;;
        esac
        shift
    done
    if test -z "$patch" && ! have diff ; then
        die "diff is required when not using -p, --patch"
    fi
    license_type="$(echo "$license_type" | tr "[A-Z]" "[a-z]")"
    if test -n "$license_type" ; then
        if ! have "$license_type" ; then
            error_unknown_license_type "$license_type"
        fi
    fi
    source_type="$(echo "$source_type" | tr "[A-Z]" "[a-z]")"
    if test -n "$source_type" ; then
        if ! have "${source_type}_license" ; then
            error_unknown_source_type "$source_type"
        fi
    fi
    if test $# -eq 0 ; then
        error_no_file_arg
    fi
    if test -z "$year" ; then year="$(date +"%Y")" ; fi
    if test -z "$tmpdir" ; then
        if ! have tmpfile.sh ; then
            die "tmpfile.sh is required when <tmpdir> is not set"
        else
            tmpdir="$(tmpfile.sh -d -p "${TMPDIR:-/tmp}/${prog}-")" ; fi
        fi
    type=
    haveproject=
    if test -n "$project" || test -n "$no_project" ; then haveproject=1 ; fi
    fixed_source_type="$source_type"
    for f in "$@" ; do
        if test -z "$haveproject" ; then project="$(basename -- "$f")" ; fi
        if test -n "$check_already" \
                && test "$within" -gt 0 \
                && head -n "$within" -- "$f" | grep -qi copyright ; then
            verbose 1 "${f} already has a license"
            continue
        fi
        if test -z "$fixed_source_type" ; then
            source_type="$(get_source_type "$f")"
        fi
        verbose 2 "${f}: ${source_type}"
        if test -z "$source_type" ; then
            warning_unable_to_calculate_source_type_for "$f"
            continue
        fi
        if test -z "$patch" && ! test -r "$f" ; then
            warn_not_patching_and_not_readable "$f"
            continue
        fi
        has_bang=
        if head -n 1 -- "$f" | grep -q '^#!' ; then has_bang=1 ; fi
        if test -n "$patch" ; then
            i_prepended="$(tmpfile.sh -p "${tmpdir}/prepended-")"
            concat_license_with "$f" > "$i_prepended"
            mv -- "$i_prepended" "$f"
            verbose 1 "patched file ${f}"
        else
            releditedfile="new/$f"
            reltmporigfile="old/$f"
            editedfile="${tmpdir}/${releditedfile}"
            tmporigfile="${tmpdir}/${reltmporigfile}"
            editedfile_dirtree="$(dirname -- "$editedfile")"
            tmporigfile_dirtree="$(dirname -- "$tmporigfile")"
            test -d "$editedfile_dirtree" || mkdir -p -- "$editedfile_dirtree"
            test -d "$tmporigfile_dirtree" || mkdir -p -- "$tmporigfile_dirtree"
            cp -- "$f" "$tmporigfile"
            # copy this here so permission are same
            # when it's overwritten
            cp -- "$f" "$editedfile"   
            concat_license_with "$f" > "$editedfile"
            (cd -- "$tmpdir" && diff -Nur -- "$reltmporigfile" "$releditedfile" || true)
        fi
    done
}
main "$@"
pax $?
