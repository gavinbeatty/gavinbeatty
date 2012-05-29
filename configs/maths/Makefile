.SUFFIXES:

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644
INSTALL_DIR ?= $(INSTALL) -d
SED ?= sed

DESTDIR ?=

.PHONY: help install
help:
	@echo "Targets: help install"

SOURCES = Xresources \
bash_profile.maths \
bashrc.aliases.maths \
bashrc.maths \
cshrc.maths \
ratpoisonrc

install: $(SOURCES)
	@$(INSTALL_DIR) $(DESTDIR)$(HOME)
	$(INSTALL_DATA) Xresources $(DESTDIR)$(HOME)/.Xresources
	$(INSTALL_DATA) bash_profile.maths $(DESTDIR)$(HOME)/.bash_profile.maths
	$(INSTALL_DATA) bashrc.aliases.maths $(DESTDIR)$(HOME)/.bashrc.aliases.maths
	$(INSTALL_DATA) bashrc.maths $(DESTDIR)$(HOME)/.bashrc.maths
	$(INSTALL_DATA) cshrc.maths $(DESTDIR)$(HOME)/.cshrc.maths
	$(INSTALL_DATA) ratpoisonrc $(DESTDIR)$(HOME)/.ratpoisonrc

