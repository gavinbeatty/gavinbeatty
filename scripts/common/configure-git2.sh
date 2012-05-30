#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
trap " echo 'Caught SIGINT' >&2 ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; exit 1 ; " TERM
default_name="Gavin Beatty"
default_email="gavinbeatty@gmail.com"
default_work_email="gavinbeatty@optiver.com"
default_excludesfile="~/.gitignore"

no_getopt_warning=${no_getopt_warning-}
getopt=${getopt-getopt}

help=${help-}
verbose=${verbose-0}
list=${list-}
name=${name-$default_name}
email=${email-$default_email}
work=${work-}
excludesfile=${excludesfile-$default_excludesfile}
sections=${sections-all}
configfile=${configfile-}
configtype=${configtype---global}

prog="$(basename -- "$0")"

longopts_support=
e=0
"$getopt" -T >/dev/null 2>&1 || e=$?
if test "$e" -eq 4 ; then
    longopts_support=1
fi
unset e

usage() {
    cat <<EOF
usage: $prog [-h]
   or: $prog [-v] [-L]
   or: $prog [-S <sections>] [-s|-l|-f <configfile>] [-x <excludesfile>] [-n <name>] [-e <email>] [-w]
EOF
}
help() {
    cat <<EOF
Options:
 -h${longopts_support:+|--help}:
  Prints this help message.
 -v${longopts_support:+|--verbose}:
  Be more verbose.
 -L${longopts_support:+|--list}:
  Prints the list of accepted <sections> and exits. The list printed is the
  equivalent to the special section, "all".
 -S${longopts_support:+|--sections} <sections>:
  Configures only the given <sections>, which is a comma-separated list.
 -s${longopts_support:+|--system}:
  Configures the "system" git config file. If none of -s, -l, -f <configfile>
  are given, the "global" git config file is used.
 -l${longopts_support:+|--local}:
  Configures the "local" git config file. If none of -s, -l, -f <configfile>
  are given, the "global" git config file is used.
 -f${longopts_support:+|--configfile} <configfile>:
  Configures the given <configfile>. If none of -s, -l, -f <configfile> are
  given, the "global" git config file is used.
 -x${longopts_support:+|--excludesfile} <excludesfile>:
  Configure the given <excludesfile> as the global exclude file, instead of the
  default, $default_excludesfile.
 -n${longopts_support:+|--name} <name>:
  Use the given <name> instead of the default, $default_name.
 -e${longopts_support:+|--email}:
  Use the given <email> instead of the default, $default_email.
 -w${longopts_support:+|--work}:
  Use the "work" variant of e-mail, $default_work_email.
EOF
}
getopt_works() {
    "$getopt" -n "test" -o "ab:c" -- -abc -c -b -c >/dev/null 2>&1
}
parseopts() {
    long=
    if test -n "$longopts_support" ; then
        long="-l help,verbose,list,name:,email:,work,excludesfile:,sections:,system,local,configfile:"
    fi
    if getopt_works ; then
        local opts="$(getopt -n "$prog" -o "hvLn:e:wx:S:slf:" $long -- "$@")"
        eval set -- $opts

        while test $# -gt 0 ; do
            case "$1" in
            -h|--help)
                help=1
                ;;
            -v|--verbose)
                verbose=1
                ;;
            -L|--list)
                list=1
                ;;
            -n|--name)
                name=$2
                shift
                ;;
            -e|--email)
                email=$2
                shift
                ;;
            -w|--work)
                email=$default_work_email
                ;;
            -x|--excludesfile)
                excludesfile=$2
                shift
                ;;
            -S|--sections)
                sections=$2
                shift
                ;;
            -s|--system)
                configtype=--system
                ;;
            -l|--local)
                configtype=--local
                ;;
            -f|--configfile)
                configfile=$2
                ;;
            --)
                shift
                break
                ;;
            *)
                die "Unknown option: $1"
                ;;
            esac
            shift
        done
    elif test -z "$no_getopt_warning" ; then
        warning "getopt \`$getopt' does not work. Options taken from environment."
    fi
}
error() {
    echo "error: $@" >&2
}
warning() {
    echo "warning: $@" >&2
}
die() {
    error "$@"
    exit 1
}
verbose() {
    if test "$verbose" -ge "$1" ; then
        shift
        echo "verbose: $@" >&2
    fi
}
have() {
    type -- "$@" >/dev/null 2>&1
}
gitconfig() {
    if test -n "$configfile" ; then
        verbose 1 git config -f "$configfile" -- "$@"
        git config -f "$configfile" -- "$@"
    else
        verbose 1 git config "$configtype" -- "$@"
        git config "$configtype" -- "$@"
    fi
}
user_section() {
    gitconfig user.name "$name"
    gitconfig user.email "$email"
}
color_section() {
    gitconfig color.ui "auto"
}
core_section() {
    gitconfig core.excludesfile "$excludesfile"
}
alias_section() {
    gitconfig alias.st "status"
    gitconfig alias.a "add -v"
    gitconfig alias.co "checkout"
    gitconfig alias.ci "commit"
    gitconfig alias.cia "commit -a"
    gitconfig alias.br "branch -v"
    gitconfig alias.cdiff "diff --cached"
    gitconfig alias.unstage "reset HEAD --"
    gitconfig alias.sm "submodule"
    gitconfig alias.r "remote -v"
    gitconfig alias.ll "log --stat"
    gitconfig alias.l "log --oneline --decorate=short"
    gitconfig alias.gl "log --graph --oneline --decorate --stat"
    gitconfig alias.lol "log --graph --oneline --decorate --abbrev-commit"
    gitconfig alias.lola "log --graph --oneline --decorate --abbrev-commit --all"
}

main() {
    parseopts "$@"

    if test -n "$help" ; then
        usage
        echo
        help
        exit 0
    fi
    if test -n "$list" ; then
        echo "user,color,core,alias"
        exit 0
    fi

    sections=$(echo "$sections" | tr '[A-Z]' '[a-z]' | sed -e 's/[ 	]*[,+|][ 	]*/ /g')
    for sec in $sections ; do
        case "$sec" in
        user)
            user_section
            ;;
        color)
            color_section
            ;;
        core)
            core_section
            ;;
        alias)
            alias_section
            ;;
        all)
            user_section
            color_section
            core_section
            alias_section
            ;;
        *)
            die "Unknown section: $sec"
            ;;
        esac
    done
}
main "$@"
