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
AWK ?= awk
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
VIMUNDER ?= .
ifeq ($(LOCALAPPDATA),)
XDG_CONFIG_HOME ?= $(HOME)/.config
else
XDG_CONFIG_HOME ?= $(LOCALAPPDATA)
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
.PHONY: install-ackrc

install-venv: $(DESTDIR)$(HOME) venv
	$(INSTALL_DATA) venv $(DESTDIR)$(HOME)/.venv
.PHONY: install-venv

install-zshrc: $(DESTDIR)$(HOME) zshrc.zsh
	$(INSTALL_DATA) zshrc.zsh $(DESTDIR)$(HOME)/.zshrc
	$(INSTALL_DATA) zshrc.pre-oh-my-zsh.zsh $(DESTDIR)$(HOME)/.zshrc.pre-oh-my-zsh
	$(INSTALL_DATA) p10k.zsh $(DESTDIR)$(HOME)/.p10k.zsh
.PHONY: install-zshrc

install-bashrc: $(DESTDIR)$(HOME) bash_logout.sh bash_profile.sh bashrc.sh
	$(INSTALL_DATA) bash_logout.sh $(DESTDIR)$(HOME)/.bash_logout
	$(INSTALL_DATA) bash_profile.sh $(DESTDIR)$(HOME)/.bash_profile
	$(INSTALL_DATA) bashrc.sh $(DESTDIR)$(HOME)/.bashrc
.PHONY: install-bashrc

install-clang-format: $(DESTDIR)$(HOME) clang-format.yaml
	$(INSTALL_DATA) clang-format.yaml $(DESTDIR)$(HOME)/.clang-format
.PHONY: install-clang-format

install-devscripts: $(DESTDIR)$(HOME) devscripts
	$(INSTALL_DATA) devscripts $(DESTDIR)$(HOME)/.devscripts
.PHONY: install-devscripts

install-gemrc: $(DESTDIR)$(HOME) gemrc
	$(INSTALL_DATA) gemrc $(DESTDIR)$(HOME)/.gemrc
.PHONY: install-gemrc

install-ghcconfig: $(DESTDIR)$(HOME) ghci.conf
	$(INSTALL_DIR) $(DESTDIR)$(HOME)/.ghc
	$(INSTALL_DATA) ghci.conf $(DESTDIR)$(HOME)/.ghc/ghci.conf
.PHONY: install-ghcconfig

install-gitconfig: $(DESTDIR)$(HOME) gitaliases gitattributes gitignore
	$(INSTALL_DATA) gitaliases $(DESTDIR)$(HOME)/.gitaliases
	$(INSTALL_DATA) gitattributes $(DESTDIR)$(HOME)/.gitattributes
	$(INSTALL_DATA) gitignore $(DESTDIR)$(HOME)/.gitignore
.PHONY: install-gitconfig

install-hgrc: $(DESTDIR)$(HOME) hgrc
	$(INSTALL_DATA) hgrc $(DESTDIR)$(HOME)/.hgrc
.PHONY: install-hgrc

install-mailcap: $(DESTDIR)$(HOME) mailcap
	$(INSTALL_DATA) mailcap $(DESTDIR)$(HOME)/.mailcap
.PHONY: install-mailcap

install-msmtprc: $(DESTDIR)$(HOME) .msmtprc
	$(INSTALL_DATA_PRIV) .msmtprc $(DESTDIR)$(HOME)/.msmtprc
.PHONY: install-msmtprc

install-muttrc: $(DESTDIR)$(HOME) muttrc muttrc.color muttrc.color-dark muttrc.gmail
	$(INSTALL_DATA) muttrc $(DESTDIR)$(HOME)/.muttrc
	$(INSTALL_DATA) muttrc.color $(DESTDIR)$(HOME)/.muttrc.color
	$(INSTALL_DATA) muttrc.color-dark $(DESTDIR)$(HOME)/.muttrc.color-dark
	$(INSTALL_DATA_PRIV) muttrc.gmail $(DESTDIR)$(HOME)/.muttrc.gmail
.PHONY: install-muttrc

install-ocamlinit: $(DESTDIR)$(HOME) ocamlinit
	$(INSTALL_DATA) ocamlinit $(DESTDIR)$(HOME)/.ocamlinit
.PHONY: install-ocamlinit

install-screenrc: $(DESTDIR)$(HOME) screenrc
	$(INSTALL_DATA) screenrc $(DESTDIR)$(HOME)/.screenrc
.PHONY: install-screenrc

install-ssh_config: $(DESTDIR)$(HOME) ssh_config
	@$(INSTALL_DIR_PRIV) $(DESTDIR)$(HOME)/.ssh || echo $(INSTALL_DIR_PRIV) ~/.ssh failed >&2
	$(TOUCH) $(DESTDIR)$(HOME)/.ssh/config
	$(CHMOD_PRIV) $(DESTDIR)$(HOME)/.ssh/config || echo $(CHMOD_PRIV) on ~/.ssh/config failed >&2
	$(AWK) 'BEGIN{f=0}{if(/^#[[:space:]]*gavinbeatty:ssh_config[[:space:]]*$$/){f=(f==0);next;}if(f==0){print}}' $(DESTDIR)$(HOME)/.ssh/config | $(CAT) - ssh_config > $(DESTDIR)$(HOME)/.ssh/config.tmp && mv $(DESTDIR)$(HOME)/.ssh/config.tmp $(DESTDIR)$(HOME)/.ssh/config
.PHONY: install-ssh_config

install-tmux_conf: $(DESTDIR)$(HOME) tmux.conf
	$(INSTALL_DATA) tmux.conf $(DESTDIR)$(HOME)/.tmux.conf
.PHONY: install-tmux_conf

install-nvim-init: $(DESTDIR)$(HOME) nvim-init.vim
	@$(INSTALL_DIR) $(DESTDIR)$(XDG_CONFIG_HOME)/nvim
	$(INSTALL_DATA) nvim-init.vim $(DESTDIR)$(XDG_CONFIG_HOME)/nvim/init.vim
.PHONY: install-nvim-init

install-vimrc: $(DESTDIR)$(HOME) vimrc.vim
	$(INSTALL_DATA) vimrc.vim $(DESTDIR)$(HOME)/$(VIMUNDER)vimrc
.PHONY: install-vimrc

install-vimsupport: $(DESTDIR)$(HOME) vim/ftplugin/cpp.vim vim/ftplugin/cs.vim vim/ftplugin/haskell.vim vim/ftplugin/txt.vim vim/ftplugin/xml.vim
	$(TOUCH) $(DESTDIR)$(HOME)/.vimrc.pre.vim
	$(TOUCH) $(DESTDIR)$(HOME)/.vimrc.post.vim
	@$(INSTALL_DIR) $(DESTDIR)$(HOME)/.vim
	@$(INSTALL_DIR) $(DESTDIR)$(HOME)/.vim/ftplugin
	$(INSTALL_DATA) vim/ftplugin/cpp.vim $(DESTDIR)$(HOME)/.vim/ftplugin/cpp.vim
	$(INSTALL_DATA) vim/ftplugin/cs.vim $(DESTDIR)$(HOME)/.vim/ftplugin/cs.vim
	$(INSTALL_DATA) vim/ftplugin/haskell.vim $(DESTDIR)$(HOME)/.vim/ftplugin/haskell.vim
	$(INSTALL_DATA) vim/ftplugin/txt.vim $(DESTDIR)$(HOME)/.vim/ftplugin/txt.vim
	$(INSTALL_DATA) vim/ftplugin/xml.vim $(DESTDIR)$(HOME)/.vim/ftplugin/xml.vim
.PHONY: install-vimsupport

install-colordiffrc: $(DESTDIR)$(HOME) colordiffrc
	$(INSTALL_DATA) colordiffrc $(DESTDIR)$(HOME)/.colordiffrc
.PHONY: install-colordiffrc

install: install-ackrc install-venv install-zshrc install-bashrc install-clang-format install-devscripts install-gemrc install-ghcconfig install-gitconfig install-hgrc install-mailcap install-msmtprc install-muttrc install-ocamlinit install-screenrc install-ssh_config install-tmux_conf install-nvim-init install-vimrc install-vimsupport install-colordiffrc
.PHONY: install

