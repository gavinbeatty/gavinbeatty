FS?=lock

help:
	@echo "targets: install-$$, enable-$$, start-$$, stop-$$"
	@echo "units: gitea-backup, zpool-import, zpool-scrub"
	@echo "variables: FS=$(FS)"
.PHONY: help

install-gitea-backup:
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/gitea-backup@.service" systemctl edit --full --force gitea-backup@.service
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/gitea-backup@.timer" systemctl edit --full --force gitea-backup@.timer
.PHONY: install-gitea-backup

enable-gitea-backup:
	sudo systemctl enable gitea-backup@$(FS).timer
.PHONY: enable-gitea-backup

start-gitea-backup:
	sudo systemctl start gitea-backup@$(FS).service
.PHONY: start-gitea-backup

stop-gitea-backup:
	sudo systemctl stop gitea-backup@$(FS).service
.PHONY: stop-gitea-backup

install-zpool-import:
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/zpool-import@.service" systemctl edit --full --force zpool-import@.service
.PHONY: install-zpool-import

enable-zpool-import:
	sudo systemctl enable zpool-import@$(FS).service
.PHONY: enable-zpool-import

start-zpool-import:
	sudo systemctl start zpool-import@$(FS).service
.PHONY: start-zpool-import

stop-zpool-import:
	sudo systemctl stop zpool-import@$(FS).service
.PHONY: stop-zpool-import

install-zpool-scrub:
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/zpool-scrub@.service" systemctl edit --full --force zpool-scrub@.service
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/zpool-scrub@.timer" systemctl edit --full --force zpool-scrub@.timer
.PHONY: install-zpool-scrub

enable-zpool-scrub:
	sudo systemctl enable zpool-scrub@$(FS).timer
.PHONY: enable-zpool-scrub

start-zpool-scrub:
	sudo systemctl start zpool-scrub@$(FS).service
.PHONY: start-zpool-scrub

stop-zpool-scrub:
	sudo systemctl stop zpool-scrub@$(FS).service
.PHONY: stop-zpool-scrub
