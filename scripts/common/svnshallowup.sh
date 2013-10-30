#!/bin/sh
# vi: set ft=sh et sw=2 ts=2:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM

SVN_EXE=${SVN_EXE:-svn} ; export SVN_EXE
help=${help-}
getopt=${getopt:-getopt}
verbose=${verbose:-}
dry_run=${dry_run:-}
leaf_depth=${leaf_depth:-}

longopts_support=
e=0
"$getopt" -T >/dev/null 2>&1 || e=$?
test "$e" -eq 4 && longopts_support=1

prog="$(basename "$0")"
usage() {
  cat <<EOF
usage: $prog [-h]
   or: $prog <path>...
EOF
}
help() {
  cat <<EOF
Options:
 -h${longopts_support:+|--help}:
  Print this help message and exit.
 -l${longopts_support:+|--leaf-depth} <depth>
  On the leaf, use --depth=<depth> if it's not the empty string.
 -v${longopts_support:+|--verbose}
  Print the svn commands before execution.
 -n${longopts_support:+|--dry-run}
  Don't execute the svn commands. Implies -v.

Arguments:
 <path>:
  The path to update in a "shallow" manner. That is,
  \`svn up --depth=empty\` on all the branches, and \`svn up\` on the leaf.
EOF
}
error() { printf "error: %s\n" "$*" >&2 ; }
die() { error "$@" ; exit 1 ; }
getopt_works() { "$getopt" -n "test" -o "ab:c" -- -a -bc -c >/dev/null 2>&1 ; }

run() {
  if test -n "$verbose" ; then
    printf "%s\n" "$*"
  fi
  if test -z "$dry_run" ; then
    "$@"
  fi
}

# 1/2/3 echoes 2
dirlevels() {
  local n=0
  local next="$(dirname "$1")"
  while test "$next" != '.' ; do
    n=$(( $n + 1 ))
    next="$(dirname "$next")"
  done
  echo $n
}
dirnamelevel() {
  local n=$1
  local d="$2"
  while test $n -ne 0 ; do
    d="$(dirname "$d")"
    n=$(( $n - 1 ))
  done
  echo "$d"
}
svnshallowup() {
  local levels=$(dirlevels "$1")
  local n=$levels
  while test $n -ne 0 ; do
    run $SVN_EXE update --depth=empty "$(dirnamelevel $n "$1")"
    n=$(( $n - 1 ))
  done
  run $SVN_EXE update ${leaf_depth:+--depth=$leaf_depth} "$1"
}

main() {
  if getopt_works ; then
    longopts=
    test -n "$longopts_support" && longopts="-l help,leaf-depth:,depth:,verbose,dry-run"
    opts="$("$getopt" -n "$prog" -o "hlvn" $longopts -- "$@")"
    eval set -- $opts

    while test $# -gt 0 ; do
      case "$1" in
      -h|--help) help=1 ;;
      -l|--leaf-depth|--depth) leaf_depth="$2" ; shift ;;
      -v|--verbose) verbose=1 ;;
      -n|--dry-run) dry_run=1 ; verbose=1 ;;
      --) shift ; break ;;
      *) die "Unknown option: $1" ;;
      esac
      shift
    done
  fi
  if test -n "$help" ; then
    usage
    echo
    help
    exit 0
  fi
  if test $# -eq 0 ; then
    error "Must give 1 or more <path> arguments."
    usage >&2
    exit 1
  fi
  if ! LC_ALL=C $SVN_EXE info . >/dev/null 2>&1 ; then
    die "$1 is not an svn checkout!"
  fi

  for i in "$@" ; do
    svnshallowup "$i"
  done
}
main "$@"
