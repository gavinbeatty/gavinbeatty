.SUFFIXES:

SHELL = /bin/sh

INSTALL_EXE ?= install -m 0755
INSTALL_DIR ?= install -m 0755 -d

DESTDIR ?=
PREFIX ?= /usr/local

SOURCES = findershowall.sh

help:
	@echo 'Targets: install'

install:
	@$(INSTALL_DIR) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL_EXE) $(SOURCES) $(DESTDIR)$(PREFIX)/bin

.PHONY: help install
