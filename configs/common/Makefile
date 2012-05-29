.SUFFIXES:

INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m 0644
INSTALL_DIR ?= $(INSTALL) -d
INSTALL_PRIVATE_DATA ?= $(INSTALL) -m 0600
SED ?= sed
UNAME ?= uname
UNAME_OS ?= $(UNAME) -s
OS ?= $(shell $(UNAME_OS))
ifeq ($(OS),Darwin)
  TLS_TRUST_FILE ?= tls_trust_file /opt/local/share/curl/curl-ca-bundle.crt
else
  TLS_TRUST_FILE ?= tls_trust_file /etc/pki/tls/certs/ca-bundle.crt
endif
OPENSSH_INCLUDE_SUPPORT_COMMENT ?= \#

DESTDIR ?=

.PHONY: help configure config conf confclean install
help:
	@echo "Targets: help configure confclean clean install"

.msmtprc: msmtprc.in
	$(SED) -e 's#@TLS_TRUST_FILE@#$(TLS_TRUST_FILE)#g' msmtprc.in > .msmtprc
.ssh_config: ssh_config.in
	$(SED) -e 's/@OPENSSH_INCLUDE_SUPPORT_COMMENT@/$(OPENSSH_INCLUDE_SUPPORT_COMMENT)/g' ssh_config.in > .ssh_config
configure: .msmtprc .ssh_config
confclean:
	$(RM) .msmtprc .ssh_config
clean: confclean

config: configure
conf: configure

SOURCES = ackrc \
bashrc.aliases \
bash_completion \
bashrc.functions \
bash_logout \
bash_profile \
bashrc \
bashrc.darwin \
bashrc.msys \
cdargs \
cdargs.bash \
cshrc \
devscripts \
gitaliases \
gitignore \
hgrc \
mailcap \
.msmtprc \
muttrc \
muttrc.color \
muttrc.color-dark \
muttrc.gmail \
screenrc \
.ssh_config \
vimrc \
vimrc_abbreviations \
vimrc_bash \
vimrc_cpp \
vimrc_text \
vimrc_unicodemacros

install: $(SOURCES)
	@$(INSTALL_DIR) $(DESTDIR)$(HOME)
	$(INSTALL_DATA) ackrc $(DESTDIR)$(HOME)/.ackrc
	$(INSTALL_DATA) bashrc.aliases $(DESTDIR)$(HOME)/.bashrc.aliases
	$(INSTALL_DATA) bash_completion $(DESTDIR)$(HOME)/.bash_completion
	$(INSTALL_DATA) bashrc.functions $(DESTDIR)$(HOME)/.bashrc.functions
	$(INSTALL_DATA) bash_logout $(DESTDIR)$(HOME)/.bash_logout
	$(INSTALL_DATA) bash_profile $(DESTDIR)$(HOME)/.bash_profile
	$(INSTALL_DATA) bashrc $(DESTDIR)$(HOME)/.bashrc
	$(INSTALL_DATA) bashrc.darwin $(DESTDIR)$(HOME)/.bashrc.darwin
	$(INSTALL_DATA) bashrc.msys $(DESTDIR)$(HOME)/.bashrc.msys
	$(INSTALL_DATA) cdargs $(DESTDIR)$(HOME)/.cdargs
	$(INSTALL_DATA) cdargs.bash $(DESTDIR)$(HOME)/.cdargs.bash
	$(INSTALL_DATA) cshrc $(DESTDIR)$(HOME)/.cshrc
	$(INSTALL_DATA) devscripts $(DESTDIR)$(HOME)/.devscripts
	$(INSTALL_DATA) gitaliases $(DESTDIR)$(HOME)/.gitaliases
	$(INSTALL_DATA) gitignore $(DESTDIR)$(HOME)/.gitignore
	$(INSTALL_DATA) hgrc $(DESTDIR)$(HOME)/.hgrc
	$(INSTALL_DATA) mailcap $(DESTDIR)$(HOME)/.mailcap
	$(INSTALL_PRIVATE_DATA) .msmtprc $(DESTDIR)$(HOME)/.msmtprc
	$(INSTALL_DATA) muttrc $(DESTDIR)$(HOME)/.muttrc
	$(INSTALL_DATA) muttrc.color $(DESTDIR)$(HOME)/.muttrc.color
	$(INSTALL_DATA) muttrc.color-dark $(DESTDIR)$(HOME)/.muttrc.color-dark
	$(INSTALL_PRIVATE_DATA) muttrc.gmail $(DESTDIR)$(HOME)/.muttrc.gmail
	$(INSTALL_DATA) screenrc $(DESTDIR)$(HOME)/.screenrc
	$(INSTALL_PRIVATE_DATA) .ssh_config $(DESTDIR)$(HOME)/.ssh/config
	$(INSTALL_DATA) vimrc $(DESTDIR)$(HOME)/.vimrc
	$(INSTALL_DATA) vimrc_abbreviations $(DESTDIR)$(HOME)/.vimrc_abbreviations
	$(INSTALL_DATA) vimrc_bash $(DESTDIR)$(HOME)/.vimrc_bash
	$(INSTALL_DATA) vimrc_cpp $(DESTDIR)$(HOME)/.vimrc_cpp
	$(INSTALL_DATA) vimrc_text $(DESTDIR)$(HOME)/.vimrc_text
	$(INSTALL_DATA) vimrc_unicodemacros $(DESTDIR)$(HOME)/.vimrc_unicodemacros
