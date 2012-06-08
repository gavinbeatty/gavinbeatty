# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
if test -n "${bashrc_functions_guard-}" ; then return 0 ; fi
bashrc_functions_guard=1
iecho ".bashrc.functions"

r() { "$@" >/dev/null 2>&1 & ; }
o() { r xdg-open "$@" ; }
e() {
    if test -f cscope.out ; then
        vim "+cscope add Gav_fnameescape('$(pwd)/cscope.out')" "$@"
    else vim "$@"
    fi
}
p() { if test $# -gt 0 ; then "$@" | "$PAGER" ; fi ; }
today() { date +"%Y%m%d" ; }
todaytime() { date +"%Y%m%d-%H%M%S" ; }

cdlink() { cd "$(readlink "$1")" ; }
h() { p history ; }
hlast() {
    if test $# -eq 0 ; then set -- 10 ; fi
    history | tail -n "$(expr "$1" + 1)" | head -n "$1"
}

doin() {
    if test $# -lt 2 ; then
        echo "usage: in <dir> <command> [<args>...]" >&2
        return 1
    fi
    local d="$1"
    shift
    (cd -- "$d" && "$@")
}

grepcpp() { find-src.sh -0fc | xargs -r0 grep -Hn "$@" ; }
greppy() { find-src.sh -0f -t python | xargs -r0 grep -Hn "$@" ; }
# note it's actually for .bash and .sh extensions
grepsh() { find-src.sh -0f -t bash | xargs -r0 grep -Hn "$@" ; }
grepsrc() { find-src.sh -0f | xargs -r0 grep -Hn "$@" ; }

svnl() { p ${SVN_EXE:-svn} "$@" ; }
svngext() {
    if test $# -eq 0 ; then set -- . ; fi
    ${SVN_EXE:-svn} pg svn:externals "$@"
}
svneext() {
    if test $# -eq 0 ; then set -- . ; fi
    ${SVN_EXE:-svn} pe svn:externals "$@"
}
svnst() { ${SVN_EXE:-svn} st --ignore-externals "$@" | grep -v '^X  ' ; }
svnlog() { svnl log -vgr HEAD:1 "$@" ; }
svndiff() { ${SVN_EXE:-svn} diff "$@" | "$PAGER" ; }
svnlogcopies() { svnl log -v --stop-on-copy "$@" ; }
svnurl() { LC_ALL=C ${SVN_EXE:-svn} info "$@" | sed -n 's/^URL: //p' ; }
svntags() { svnlist.sh -t "$@" ; }
svnbr() { svnlist.sh -b "$@" ; }
svntr() { svnlist.sh -T "$@" ; }

bj() {
    local testfile="/tmp/gavinbeatty-bjtestcap-$(uuidgen)"
    bjam -j6 --verbose-test "$@" 2>&1 | tee -- "$testfile"
    local e="${PIPESTATUS[0]}"
    cat <<EOF
XXXXXXXXXXXXXXXXXXX
XXX TEST OUTPUT XXX
XXXXXXXXXXXXXXXXXXX
EOF
    local ge=0
    grep -E -- '^(\*\*passed\*\*|\.\.\.failed)' "$testfile" || ge=$?
    case $ge in
        0|1) ;;
        *) return $ge ; ;;
    esac
    rm -- "$testfile" || return $?
    return $e
}
bjin() {
    test $# -eq 0 && { echo "usage: bjin <dir> [<args>...]" >&2 ; return 1; }
    local d=$1
    shift
    doin "$d" bj "$@"
}
bjerrs() {
    local errsfile="/tmp/gavinbeatty-bjerrs-$(uuidgen)"
    bj "$@" | tee -- "$errsfile"
    local e="${PIPESTATUS[0]}"
    fgrep error: -- "$errsfile" | wc -l
    local ge="${PIPESTATUS[0]}"
    local we="${PIPESTATUS[1]}"
    rm -- "$errsfile" || return $?
    test $e -ne 0 && return $e
    test $ge -ne 0 && return $ge
    test $we -ne 0 && return $we
    return 0
}
xxxs() {
    local xxxsfile="/tmp/gavinbeatty-xxxs-$(uuidgen)"
    sfgrep XXX | tee -- "$xxxsfile"
    wc -l < "$xxxsfile"
    rm -- "$xxxsfile" || :
}

if (! type --  >/dev/null 2>&1) && (test -x "/Applications/Vim.app/Contents/MacOS/Vim") ; then
    gvim() {
        "/Applications/Vim.app/Contents/MacOS/Vim" -g "$@"
    }
fi

ismounted() { mount | grep -Fq " on ${1} type " ; }

for i_ in $HOSTS ; do
    if test -r "${HOME}/.bashrc.func.${i_}.sh" ; then
        . "${HOME}/.bashrc.func.${i_}.sh"
    fi
done
unset i_
