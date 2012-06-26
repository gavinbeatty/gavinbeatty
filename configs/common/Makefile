.SUFFIXES:
SHELL = /bin/sh

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644
INSTALL_DATA_PRIV ?= $(INSTALL) -m 0600
INSTALL_DIR ?= $(INSTALL) -d
INSTALL_DIR_PRIV ?= $(INSTALL) -d -m 0700
CHMOD ?= chmod
CHMOD_PRIV ?= $(CHMOD) 0600
TOUCH ?= touch
GREP ?= grep
SED ?= sed
CAT ?= cat
UNAME ?= uname
UNAME_OS ?= $(UNAME) -s
OS ?= $(shell $(UNAME_OS))
ifeq ($(OS),Darwin)
  TLS_TRUST_FILE ?= tls_trust_file /opt/local/share/curl/curl-ca-bundle.crt
else
  TLS_TRUST_FILE ?= tls_trust_file /etc/pki/tls/certs/ca-bundle.crt
endif

DESTDIR ?=

help:
	@echo "Targets: help configure confclean clean install"

.msmtprc: msmtprc.in
	$(SED) -e 's#@TLS_TRUST_FILE@#$(TLS_TRUST_FILE)#g' msmtprc.in > .msmtprc
configure: .msmtprc
confclean:
	$(RM) .msmtprc
clean: confclean

config: configure
conf: configure
.PHONY: help configure confclean clean config conf

$(DESTDIR)$(HOME):
	@$(INSTALL_DIR) $(DESTDIR)$(HOME)

install-ackrc: $(DESTDIR)$(HOME) ackrc
	$(INSTALL_DATA) ackrc $(DESTDIR)$(HOME)/.ackrc

install-bashrc: $(DESTDIR)$(HOME) bash_completion bash_logout bash_profile bashrc bashrc.alias.sh bashrc.func.sh bashrc.darwin.sh bashrc.msys.sh
	$(INSTALL_DATA) bash_completion $(DESTDIR)$(HOME)/.bash_completion
	$(INSTALL_DATA) bash_logout $(DESTDIR)$(HOME)/.bash_logout
	$(INSTALL_DATA) bash_profile $(DESTDIR)$(HOME)/.bash_profile
	$(INSTALL_DATA) bashrc $(DESTDIR)$(HOME)/.bashrc
	$(INSTALL_DATA) bashrc.alias.sh $(DESTDIR)$(HOME)/.bashrc.alias.sh
	$(INSTALL_DATA) bashrc.func.sh $(DESTDIR)$(HOME)/.bashrc.func.sh
	$(INSTALL_DATA) bashrc.darwin.sh $(DESTDIR)$(HOME)/.bashrc.darwin.sh
	$(INSTALL_DATA) bashrc.msys.sh $(DESTDIR)$(HOME)/.bashrc.msys.sh

install-cdargs: $(DESTDIR)$(HOME) cdargs cdargs.bash
	$(INSTALL_DATA) cdargs $(DESTDIR)$(HOME)/.cdargs
	$(INSTALL_DATA) cdargs.bash $(DESTDIR)$(HOME)/.cdargs.bash

install-cshrc: $(DESTDIR)$(HOME) cshrc
	$(INSTALL_DATA) cshrc $(DESTDIR)$(HOME)/.cshrc

install-devscripts: $(DESTDIR)$(HOME) devscripts
	$(INSTALL_DATA) devscripts $(DESTDIR)$(HOME)/.devscripts

install-gitconfig: $(DESTDIR)$(HOME) gitaliases gitignore
	$(INSTALL_DATA) gitaliases $(DESTDIR)$(HOME)/.gitaliases
	$(INSTALL_DATA) gitignore $(DESTDIR)$(HOME)/.gitignore

install-hgrc: $(DESTDIR)$(HOME) hgrc
	$(INSTALL_DATA) hgrc $(DESTDIR)$(HOME)/.hgrc

install-mailcap: $(DESTDIR)$(HOME) mailcap
	$(INSTALL_DATA) mailcap $(DESTDIR)$(HOME)/.mailcap

install-msmtprc: $(DESTDIR)$(HOME) .msmtprc
	$(INSTALL_DATA_PRIV) .msmtprc $(DESTDIR)$(HOME)/.msmtprc

install-muttrc: $(DESTDIR)$(HOME) muttrc muttrc.color muttrc.color-dark muttrc.gmail
	$(INSTALL_DATA) muttrc $(DESTDIR)$(HOME)/.muttrc
	$(INSTALL_DATA) muttrc.color $(DESTDIR)$(HOME)/.muttrc.color
	$(INSTALL_DATA) muttrc.color-dark $(DESTDIR)$(HOME)/.muttrc.color-dark
	$(INSTALL_DATA_PRIV) muttrc.gmail $(DESTDIR)$(HOME)/.muttrc.gmail

install-screenrc: $(DESTDIR)$(HOME) screenrc
	$(INSTALL_DATA) screenrc $(DESTDIR)$(HOME)/.screenrc

install-ssh_config: $(DESTDIR)$(HOME) ssh_config
	@$(INSTALL_DIR_PRIV) $(DESTDIR)$(HOME)/.ssh
	$(TOUCH) $(DESTDIR)$(HOME)/.ssh/config
	$(CHMOD_PRIV) $(DESTDIR)$(HOME)/.ssh/config
	if ! $(GREP) -q '^#\s*gavinbeatty:ssh_config$$' $(DESTDIR)$(HOME)/.ssh/config ; then $(CAT) ssh_config >> $(DESTDIR)$(HOME)/.ssh/config ; fi

install-tmux_conf: $(DESTDIR)$(HOME) tmux.conf
	$(INSTALL_DATA) tmux.conf $(DESTDIR)$(HOME)/.tmux.conf

install-vimrc: $(DESTDIR)$(HOME) vimrc vimrc.abbrev.vim vimrc.sh.vim vimrc.cpp.vim vimrc.txt.vim vimrc.unicode.vim
	$(TOUCH) $(DESTDIR)$(HOME)/.vimrc.pre.vim
	$(INSTALL_DATA) vimrc $(DESTDIR)$(HOME)/.vimrc
	$(TOUCH) $(DESTDIR)$(HOME)/.vimrc.post.vim
	$(INSTALL_DATA) vimrc.abbrev.vim $(DESTDIR)$(HOME)/.vimrc.abbrev.vim
	$(INSTALL_DATA) vimrc.sh.vim $(DESTDIR)$(HOME)/.vimrc.sh.vim
	$(INSTALL_DATA) vimrc.cpp.vim $(DESTDIR)$(HOME)/.vimrc.cpp.vim
	$(INSTALL_DATA) vimrc.txt.vim $(DESTDIR)$(HOME)/.vimrc.txt.vim
	$(INSTALL_DATA) vimrc.unicode.vim $(DESTDIR)$(HOME)/.vimrc.unicode.vim

install: install-ackrc install-bashrc install-cdargs install-cshrc install-devscripts install-gitconfig install-hgrc install-mailcap install-msmtprc install-muttrc install-screenrc install-ssh_config install-tmux_conf install-vimrc
.PHONY: install install-ackrc install-bashrc install-cdargs install-cshrc install-devscripts install-gitconfig install-hgrc install-mailcap install-msmtprc install-muttrc install-screenrc install-ssh_config install-tmux_conf install-vimrc

