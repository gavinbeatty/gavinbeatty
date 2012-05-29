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
backup.sh \
bangcheck.sh \
battery.sh \
codepretty.py \
configure-git.sh \
cscope.sh \
ctags.sh \
doubleclick.sh \
find-src.sh \
findpid.sh \
findup.sh \
git-cvs-mirror.sh \
git-release \
giturl.sh \
gpg-add.sh \
ipof.sh \
isgitrepo.sh \
isiface.sh \
issvncheckout.sh \
issvnrepo.sh \
lsmaketargets.sh \
mathbang.sh \
merge.sh \
mydate.sh \
mydatetime.sh \
pager.sh \
rmbin.sh \
rmtmp.sh \
run.sh \
runq.sh \
sure.sh \
svnrepo.sh \
svnurl.sh \
term.sh \
tmpfile.sh \
tune.sh \
udevinfo.sh \
whatdebsneeded.sh \

help:
	@echo 'Targets: install'

install:
	@$(INSTALL_DIR) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL_EXE) $(SOURCES) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL_EXE) sure.sh $(DESTDIR)$(PREFIX)/bin/sureyes.sh
	$(INSTALL_EXE) sure.sh $(DESTDIR)$(PREFIX)/bin/sureno.sh

.PHONY: help install
