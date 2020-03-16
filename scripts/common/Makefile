.SUFFIXES:
default: help
SHELL = /bin/sh

INSTALL_EXE ?= install -m 0755
DASHINSTALL_EXE ?= ./dashinstall.sh -m 0755
INSTALL_DIR ?= install -m 0755 -d

DESTDIR ?=
PREFIX ?= /usr/local

SOURCES = 7zipper.sh \
abspath.py \
addlicense.sh \
asciitable.sh \
bangcheck.sh \
battery.sh \
bits.py \
bj.bash \
bjcomplete.sh \
buf.sh \
cc-defines.sh \
cc-includes.sh \
codepretty.py \
configure-git.sh \
cscope.sh \
csv-kv2hdr.py \
cs-csproj-mismatch.sh \
cs-has-tests.sh \
cs-name-check.sh \
ctags.sh \
cxx-test.sh \
daemonize.sh \
dashify.sh \
dashinstall.sh \
differ.sh \
dnsnameexists.sh \
doubleclick.sh \
example-xml.sh \
export-git.sh \
findpid.sh \
find-src.sh \
findup.sh \
git-cvs-mirror.sh \
git-export.sh \
git-news.sh \
git-release.sh \
git-remotebranch.sh \
git-thisbranch.sh \
giturl.sh \
gitwcroot.sh \
gpg-add.sh \
ifnargs.sh \
ipof.sh \
isgitrepo.sh \
isiface.sh \
issvncheckout.sh \
issvnrepo.sh \
jamroot.sh \
kde-plot.py \
killpid.sh \
logstamp.sh \
logto.sh \
lsmaketargets.sh \
mathbang.sh \
merge.sh \
move-home.sh \
net-check.sh \
pager.sh \
poke.sh \
p0.sh \
rec2fld.pl \
rmbin.sh \
rmgcov.sh \
rmr.sh \
rmtmp.sh \
runq.sh \
run.sh \
shify.sh \
stats.py \
strerror.sh \
stripcolor.sh \
svnaddcopyright.bash \
svnblamefirst.sh \
svndepth.sh \
svndiffadaptor.sh \
svngitdiff.py \
svngrep.sh \
svngrepprop.sh \
svnhasprop.sh \
svnlastcommit.sh \
svnlist.sh \
svnmergerevs.sh \
svnpeggedexternals.sh \
svnrelnotes.sh \
svnrepairmv.sh \
svnrepo.sh \
svnrepowalk.sh \
svnresolve.sh \
svnshallowup.sh \
svnsort.sh \
svnswitch.sh \
svnurl.sh \
svnwcroot.sh \
tcp-proxy.sh \
tee.awk \
term.sh \
tmpfile.sh \
tune.sh \
udevinfo.sh \
use-clang.sh \
use-colorgcc.sh \
videodur.sh \
vimpatch.sh \
whatdebsneeded.sh

help:
	@echo 'Targets: install uninstall'
install:
	@$(INSTALL_DIR) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL_EXE) $(SOURCES) $(DESTDIR)$(PREFIX)/bin/
	if dash="$$(which dash)" ; then ./shify.sh "$$dash" $(addprefix $(DESTDIR)$(PREFIX)/bin/,$(SOURCES)) ; fi
	$(INSTALL_EXE) sure.bash $(DESTDIR)$(PREFIX)/bin/sureyes.bash
	$(INSTALL_EXE) sure.bash $(DESTDIR)$(PREFIX)/bin/sureno.bash
uninstall:
	rm -f -- $(addprefix $(DESTDIR)$(PREFIX)/bin/,$(SOURCES)) ; done
	rm -f -- $(DESTDIR)$(PREFIX)/bin/sureyes.bash $(DESTDIR)$(PREFIX)/bin/sureno.bash
.PHONY: default help install uninstall
