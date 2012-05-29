#!/bin/sh
# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:

set -e
set -u

usage() {
    cat <<EOF
Usage: git-cvs-mirror.sh new <module> [ ... ]
   or: git-cvs-mirror.sh update <module> [ ... ]
EOF
}

if test $# -lt 2 ; then
    usage >&2
    exit 1
fi

command="$1"
shift

# deny push access on master
deny_push_master() {
    hook="${1}/hooks/pre-receive"
    cat > "$hook" << PRE_EOF
#!/bin/sh

while read oldsha newsha ref ; do
    if test "\$ref" = "refs/heads/master" ; then
        echo "Denying push access to refs/heads/master." >&2
        exit 1
    fi
done
exit 0

PRE_EOF
    chmod +x "$hook"
}
update_mirror() {
    for i in "$@" ; do
        git cvsimport -vC "$i" -akmio master "$i" || { echo "FAILED!" ; exit 1 ; }
        GIT_DIR="$i"/.git git gc
    done
}
new_mirror() {
    for i in "$@" ; do
        update_mirror "$i"
        ln -s "$i"/.git "$i".git
        GIT_DIR="$i".git git config core.bare true
        GIT_DIR="$i".git git config core.sharedRepository true
        GIT_DIR="$i".git git config receive.denyNonFastForwards true
        deny_push_master "${i}.git"
    done
}
export CVSROOT
echo "CVSROOT=$CVSROOT"

set -x
case "$command" in
new)
    new_mirror "$@"
    ;;
update)
    update_mirror "$@"
    ;;
*)
    usage >&2
    exit 1
    ;;
esac


