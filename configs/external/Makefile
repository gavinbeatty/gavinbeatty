.SUFFIXES:
SHELL = /bin/sh

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644
INSTALL_DIR ?= $(INSTALL) -d -m 0755

DESTDIR ?=

help:
	@echo Targets: install

install: install-git-prompt.sh

install-git-prompt.sh: git-prompt.sh
	@$(INSTALL_DIR) $(DESTDIR)$(HOME)
	$(INSTALL_DATA) $< $(DESTDIR)$(HOME)/.$<

.PHONY: help install install-git-prompt.sh
