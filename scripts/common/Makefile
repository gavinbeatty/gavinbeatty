.SUFFIXES:

SHELL = /bin/sh

INSTALL_EXE ?= install -m 0755
INSTALL_DIR ?= install -m 0755 -d

DESTDIR ?=
PREFIX ?= /usr/local

SOURCES = 7zipper.sh \
abspath.py \
addlicense.sh \
asciitable.sh \
bangcheck.sh \
battery.sh \
buf.sh \
codepretty.py \
configure-git.sh \
cscope.sh \
ctags.sh \
daemonize.sh \
differ.sh \
dnsnameexists.sh \
doubleclick.sh \
example-xml.sh \
export-git.sh \
findpid.sh \
find-src.sh \
findup.sh \
git-cvs-mirror.sh \
git-release \
giturl.sh \
gitwcroot.sh \
gpg-add.sh \
ifnargs.sh \
ipof.sh \
isgitrepo.sh \
isiface.sh \
issvncheckout.sh \
issvnrepo.sh \
killpid.sh \
logstamp.sh \
logto.sh \
lsmaketargets.sh \
mathbang.sh \
merge.sh \
move-home.sh \
mydate.sh \
mydatetime.sh \
net-check.sh \
pager.sh \
poke.sh \
rmbin.sh \
rmgcov.sh \
rmr.sh \
rmtmp.sh \
runq.sh \
run.sh \
stripcolor.sh \
svnaddcopyright.sh \
svnblamefirst.sh \
svndiffadaptor.sh \
svnlastcommit.sh \
svnlist.sh \
svnpeggedexternals.sh \
svnrelnotes.sh \
svnrepo.sh \
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
vimpatch.sh \
whatdebsneeded.sh

help:
	@echo 'Targets: install'

install:
	@$(INSTALL_DIR) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL_EXE) $(SOURCES) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL_EXE) sure.sh $(DESTDIR)$(PREFIX)/bin/sureyes.sh
	$(INSTALL_EXE) sure.sh $(DESTDIR)$(PREFIX)/bin/sureno.sh

.PHONY: help install
