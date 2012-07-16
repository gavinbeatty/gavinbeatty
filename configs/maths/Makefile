.SUFFIXES:
SHELL = /bin/sh

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644
INSTALL_DIR ?= $(INSTALL) -d
SED ?= sed
GREP ?= grep
CAT ?= cat

DESTDIR ?=

.PHONY: help install
help:
	@echo "Targets: help install"

SOURCES = Xresources \
bash_profile.maths \
bashrc.maths.sh \
cshrc.maths \
ratpoisonrc

install: $(SOURCES)
	@$(INSTALL_DIR) $(DESTDIR)$(HOME)
	$(INSTALL_DATA) Xresources $(DESTDIR)$(HOME)/.Xresources
	if ! $(GREP) -q '^#\s*gavinbeatty:bash_profile.maths.sh$$' $(DESTDIR)$(HOME)/.bash_profile ; then $(CAT) bash_profile.maths.sh >> $(DESTDIR)$(HOME)/.bash_profile ; fi
	if ! $(GREP) -q '^#\s*gavinbeatty:bashrc.maths.sh$$' $(DESTDIR)$(HOME)/.bashrc.post.sh ; then $(CAT) bashrc.maths.sh >> $(DESTDIR)$(HOME)/.bashrc.post.sh ; fi
	$(INSTALL_DATA) cshrc.maths $(DESTDIR)$(HOME)/.cshrc.maths
	$(INSTALL_DATA) ratpoisonrc $(DESTDIR)$(HOME)/.ratpoisonrc

