.SUFFIXES:
SHELL = /bin/sh

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644

DESTDIR ?=

help:
	@echo "Targets: help install"

install-colordiffrc: $(DESTDIR)$(HOME) colordiffrc
	$(INSTALL_DATA) colordiffrc $(DESTDIR)$(HOME)/.colordiffrc
.PHONY: install-colordiffrc

install-minttyrc: $(DESTDIR)$(HOME) minttyrc
	$(INSTALL_DATA) minttyrc $(DESTDIR)$(HOME)/.minttyrc
.PHONY: install-minttyrc

install: install-colordiffrc install-minttyrc
.PHONY: install
