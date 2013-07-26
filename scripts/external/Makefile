.SUFFIXES:
SHELL = /bin/sh

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644
INSTALL_EXE ?= $(INSTALL) -m 0755
INSTALL_DIR ?= $(INSTALL) -d -m 0755

DESTDIR ?=
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

help:
	@echo Targets: install

SOURCES = \
cc_args.py \
checkbashisms \
colordiff \
colorgcc.pl \
fix-outlook-quoting.rb \
mutt_bgrun \
256colors2.pl

install: $(SOURCES)
	@$(INSTALL_DIR) $(DESTDIR)$(BINDIR)
	$(INSTALL_EXE) $(SOURCES) $(DESTDIR)$(BINDIR)

.PHONY: help install
