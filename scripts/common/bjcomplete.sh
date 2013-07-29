#!/bin/sh
# vi: set ft=sh et sw=4 ts=4:
set -e
set -u
rollback() { true ; }
trap " rollback ; " 0
trap " echo 'Caught SIGINT' >&2 ; rollback ; exit 1 ; " INT
trap " echo 'Caught SIGTERM' >&2 ; rollback ; exit 1 ; " TERM
die() { echo "error: $@" >&2 ; exit 1 ; }
vdo() { echo "\$ $@" ; "$@" ; }
root=
getroot() { 
    for i in Jamroot* project-root.jam ; do
        if test -f "$i" ; then root="$i" ; return ; fi
    done
    return 1
}
while test "$(pwd)" != / ; do
    if getroot ; then break
    else cd .. ; fi
done
getroot || die "jam root not found"
e=
if type bear >/dev/null 2>&1 ; then
    bear -- bjam "$@" || e=$?
fi
# XXX use perl instead of gawk: needs word boundaries
gawk 'BEGIN{using=0}{
  if(using == 0 && /^(using$|using\y|[^#]*\yusing\y)/){using=1}
  printf("%s%s\n", using == 1 ? "#" : "", $0);
  if(/^(|[^#]*[^\\]);/){using=0}
}' "$root" > "${root}.complete"
echo 'using gcc : complete : cc_args.py g++ ;' >> "${root}.complete"
rollback() {
    mv "${root}.complete.orig" "$root" 2>/dev/null || true
}
mv "$root" "${root}.complete.orig"
cp "${root}.complete" "$root"
vdo bjam "$@" || e=$?
c=".clang_complete"
if test -f "$c" ; then
    { rm $c && sort | uniq | awk '!/^[[:space:]]*$/{print}' > $c ; } < $c
fi
exit $e
