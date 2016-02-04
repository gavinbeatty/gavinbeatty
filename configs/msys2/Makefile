.SUFFIXES:
SHELL = /bin/sh

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644

DESTDIR ?=

help:
	@echo "Targets: help install"

install-bashrc: $(DESTDIR)$(HOME) bashrc.sh
	$(INSTALL_DATA) bashrc.sh $(DESTDIR)$(HOME)/.bashrc
.PHONY: install-bashrc

install-colordiffrc: $(DESTDIR)$(HOME) colordiffrc
	$(INSTALL_DATA) colordiffrc $(DESTDIR)$(HOME)/.colordiffrc
.PHONY: install-colordiffrc

install: install-bashrc install-colordiffrc
.PHONY: install
