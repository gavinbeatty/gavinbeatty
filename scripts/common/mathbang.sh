#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
###########################################################################
# Copyright (C) 2008, 2012 by Gavin Beatty
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

tmpdir=""
valid_sizes="tiny scriptsize footnotesize small normalsize large Large LARGE huge Huge"
size="Large"
open_tex_block="\\["
close_tex_block="\\]"

have() { type "$@" >/dev/null 2>&1 ; }
die() { echo "error: $@" >&2 ; exit 1 ; }
verbose() {
    if test "$1" -le "$verbose" ; then
        shift
        echo "$@"
    fi
}
is_elem() {
    local e="$1"
    shift
    for i in "$@" ; do
        test "$i" != "$e" || return 0
    done
    return 1
}
get_ext() { echo "$1" | sed -e 's/.*\.//' ; }

usage() {
    echo "usage: $prog [-i|-c] [-s <size>] <latex_formatted_math> <outputfile.extension>"
}
help() {
    cat <<EOF
Generate pretty math images using LaTeX.

$(usage)
Options:
 -h:
  Print this help message.
 -v:
  Give verbose information about what the script is doing. For example, print
  the commands used to create the math image. Supply this option multiple times
  to increase verbosity further.
 -i:
  Render the math inline.
 -c:
  Render the math centered and NOT inline.
 -s <size>:
  The LaTeX size to use. Valid sizes are: ${valid_sizes}.
EOF
}

cleanup() {
    if (test -n "$tmpdir") && (test -d "$tmpdir") ; then
        rm -rf -- "$tmpdir"
    fi
    return 0
}

write_tex() {
    write_tex_tex_arg="$1"
cat <<LATEX_EOF
\documentclass[12pt]{article}

\newif\ifpdf
\ifx\pdfoutput\undefined
  \pdffalse
\else
  \ifnum\pdfoutput=1
    \pdftrue
  \else
    \pdffalse
  \fi
\fi

% \usepackage{graphicx}                   % needed for including graphics e.g. EPS, PS
% \usepackage{epsfig}
\usepackage{amssymb}
\usepackage{amsmath}
\usepackage{amsfonts}
% \usepackage{amsthm}
\usepackage{array}
% \setlength{\extrarowheight}{0.12cm}     % useful for long division prettiness
\usepackage{enumerate}
\usepackage{polynom}

\usepackage[pdftex]{hyperref}
% \hypersetup{
%     bookmarks=true,           % show bookmarks bar?
%     unicode=false,            % non-Latin characters in Acrobat’s bookmarks
%     pdftoolbar=true,          % show Acrobat’s toolbar?
%     pdfmenubar=true,          % show Acrobat’s menu?
%     pdffitwindow=true,        % page fit to window when opened
%     pdftitle={My title},      % title
%     pdfauthor={Me Myself}, % author
%     pdfsubject={Subject},     % subject of the document
%     pdfnewwindow=true,        % links in new window
%     pdfkeywords={keywords},   % list of keywords
%     colorlinks=false,         % false: boxed links; true: colored links
%     linkcolor=red,            % color of internal links
%     citecolor=green,          % color of links to bibliography
%     filecolor=magenta,        % color of file links
%     urlcolor=cyan             % color of external links
% }

\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}

% \let\oldthedef\thedef         % Redefine thedef as oldthedef
%                               % e.g., \let\oldsqrt\sqrt

\newenvironment{proof}[1][Proof]{\begin{trivlist} %
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{definition}[1][Definition]{\begin{trivlist} %
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{example}[1][Example]{\begin{trivlist} %
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{remark}[1][Remark]{\begin{trivlist} %
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}


\newcommand{\qed}{\nobreak \ifvmode \relax \else %
      \ifdim\lastskip<1.5em \hskip-\lastskip %
      \hskip1.5em plus0em minus0.5em \fi \nobreak %
      \vrule height0.75em width0.5em depth0.25em\fi}

\pagestyle{empty}                       % no page numbers

% \renewcommand{\baselinestretch}{1.5}    % 1.5 spacing between lines
% \parindent 0pt                          % sets leading space for paragraphs

\begin{document}

{\\${size}
${open_tex_block}${write_tex_tex_arg}${close_tex_block}
}

\end{document}


LATEX_EOF
}

error_no_extension() {
    usage >&2
    die "<outputfile.extension> argument, \`$1' does not have an extension. e.g., .png , .jpg."
}
error_invalid_size() {
    usage >&2
    die "<size> option argument is invalid. See source for a list of valid sizes."
}
error_invalid_argument_count() {
    usage >&2
    die "Must give two arguments, <latex_formatted_math> and <outputfile.extension>."
}

main() {
    for i in "pdflatex" "pdfcrop" "convert" "tmpfile.sh" "tr" ; do
        if ! have "$i" ; then die "Please install $i" ; fi
    done

    opts="$("$getopt" -n "$prog" -o "hvs:ic" -- "$@")"
    eval set -- "$opts"

    while test $# -gt 0 ; do
        case "$1" in
        -v) verbose=$(( verbose + 1 )) ;;
        -s) size="$2" ; shift ;;
        -i) open_tex_block="$"
            close_tex_block="$"
            ;;
        -c) open_tex_block="\\["
            close_tex_block="\\]"
            ;;
        -h) help=1 ;;
        --) shift ; break ;;
        *) die "Unknown option: $1" ;;
        esac
    done
    test -z "$help" || { help ; exit 0 ; }
    if ! is_elem "$size" $valid_sizes ; then
        error_invalid_size "$size"
    fi
    if test $# -ne 2 ; then
        error_invalid_argument_count $#
    fi
    tex_arg="$1"
    output_arg="$2"

    output_ext="$(get_ext "$output_arg")"
    if test -z "$output_ext" ; then
        error_no_extension "$output_arg"
    fi

    tmpdir="$(tmpfile.sh -d)"
    verbose 1 "$(echo "mkdir -- \"${tmpdir}\"")"
    tmp_tex_src="${tmpdir}/math.tex"
    tmp_pdf="${tmpdir}/math.pdf"
    tmp_cropped_pdf="${tmpdir}/math-cropped.pdf"

    write_tex "$tex_arg" > "$tmp_tex_src"

    verbose 1 "$(echo "pdflatex --output-directory=\"${tmpdir}\" -- \"${tmp_tex_src}\" 1>/dev/null 2>/dev/null")"
    pdflatex --output-directory="$tmpdir" -- "$tmp_tex_src" 1>/dev/null 2>/dev/null

    verbose 1 "$(echo "pdfcrop --margins '4 4 4 4' -- \"${tmp_pdf}\" \"${tmp_cropped_pdf}\" 1>/dev/null 2>/dev/null")"
    pdfcrop --margins '4 4 4 4' -- "$tmp_pdf" "$tmp_cropped_pdf" 1>/dev/null 2>/dev/null
    if test x"$(echo ${output_ext}| tr "[A-Z]" "[a-z]")" = x"pdf" ; then
        verbose 1 "$(echo "cp -- \"${tmp_cropped_pdf}\" \"${output_arg}\"")"
        cp -- "$tmp_cropped_pdf" "$output_arg"
    else
        verbose 1 "$(echo "convert \"${tmp_cropped_pdf}\" \"${output_arg}\"")"
        convert "$tmp_cropped_pdf" "$output_arg"
    fi
}
trap " echo Caught SIGINT >&2 ; exit 1 ; " INT
trap " echo Caught SIGTERM >&2 ; exit 1 ; " TERM
trap "cleanup" 0
main "$@"
