#!/bin/sh
# vi: set ft=sh et sw=2 ts=2:
set -e
set -u
trap 'echo Caught SIGINT >&2 ; exit 1 ; ' INT
trap 'echo Caught SIGTERM >&2 ; exit 1 ; ' TERM
say() { printf "%s\n" "$*" ; }
die() { printf "%s\n" "$*" >&2 ; exit 1 ; }
prog="$(basename "$0")"
getopt="${getopt:-getopt}"
has_longopts=
e=0
"$getopt" -T >/dev/null 2>&1 || e=$?
test "$e" -eq 4 && has_longopts=1
usage() {
  printf "usage: %s [-r] [-R] [-t|-m] [--] <branch-url> [<log-args>...]\n" "$prog"
  printf "   or: %s [-r] [-R] [-t|-m] [--] <source-url>..<branch-url> [<log-args>...]\n" "$prog"
  printf "   or: %s [-r] [-R] [-t|-m] [--] <source-url>...<branch-url> [<log-args>...]\n" "$prog"
}
SVN_EXE="${SVN_EXE:-svn}"
svnurl() {
  local info=
  if info="$(LC_ALL=C $SVN_EXE info -- "$1" 2>/dev/null)" ; then
    echo "$info" | LC_ALL=C awk 'BEGIN {FS=": " } /^URL: / {print $2}'
  else
    printf "error: %s is an invalid <url|path>\n" "$1" >&2
    usage >&2
    exit 1
  fi
}

show=eligible
revsonly=
reverse=
done=
longopts=
test -z "$has_longopts" || longopts="-l help,theirs,eligible,mine,merged,revs,reverse"
opts="$("$getopt" -n "$prog" -o "htmrR" $longopts -- "$@")"
eval set -- $opts
while test $# -gt 0 ; do
  case "$1" in
    -h|--help) usage ; exit 0 ;;
    -t|--theirs|--eligible) show=eligible ;;
    -m|--mine|--merged) show=merged ;;
    -r|--revs) revsonly=1 ;;
    -R|--reverse) reverse=1 ;;
    --) shift ; break ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done
if test $# -lt 1 ; then usage >&2 ; exit 1 ; fi
url="$1" ; shift
if ! say "$url" | grep -F -q '..' ; then # handles "..." as well
  src="$(svnurl .)" || die "Could not infer <source-url>."
  branch="$url"
else
  src="$(say "$url" | sed 's/\.\..*$//')"
  branch="$(say "$url" | sed 's/^.*\.\.//')"
  if test "${src}..$branch" != "$url" && test "${src}...$branch" != "$url" ; then
    die "Cannot split <branch-url> unambiguously."
  fi
fi
test -n "$src" || die "<source-url> is empty."
test -n "$branch" || die "<branch-url> is empty."

mergeinfo() {
  $SVN_EXE mergeinfo --show-revs $show -- "$1" "$2"
}
all() {
  mergeinfo "$1" "$2"
  mergeinfo "$2" "$1"
}
disjointunion() {
  sort | uniq -c | sed 's/^\s*//' | awk '{if($1==1){sub(/^[^[:space:]]*[[:space:]]*/,"");print;}}'
}
ordering() {
  if test -n "$reverse" ; then sort | uniq | tac
  else sort | uniq ; fi
}
show() {
  if test -n "$revsonly" ; then cat
  else
    local e=
    local out=
    while read rev ; do
      # when using disjointunion, it could be from $src
      e=0
      out="$($SVN_EXE log -c "$rev" --incremental "$@" "$branch" 2>/dev/null)" || e=$?
      if test -n "$out" ; then
        say "$out" ; return $e
      else
        $SVN_EXE log -c "$rev" --incremental "$@" "$src"
      fi
    done
  fi
}
if say "$url" | grep -F -q '...' ; then
  all "$branch" "$src" | disjointunion | ordering | show "$@"
else
  mergeinfo "$branch" "$src" | ordering | show "$@"
fi
