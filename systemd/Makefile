FS?=lock

help:
	@echo "targets: run-$$, install-$$, enable-$$"
	@echo "units: gitea-backup, zpool-import"
	@echo "variables: FS=$(FS)"
.PHONY: help

run-gitea-backup:
	sudo systemctl start gitea-backup@$(FS).service
.PHONY: run-gitea-backup

install-gitea-backup:
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/gitea-backup@.service" systemctl edit --full --force gitea-backup@.service
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/gitea-backup@.timer" systemctl edit --full --force gitea-backup@.timer
.PHONY: install-gitea-backup

enable-gitea-backup:
	sudo systemctl enable gitea-backup@$(FS).timer
.PHONY: enable-gitea-backup

run-zpool-import:
	sudo systemctl start zpool-import@$(FS).service
.PHONY: run-zpool-import

install-zpool-import:
	sudo env SYSTEMD_EDITOR="cp $$(pwd)/zpool-import@.service" systemctl edit --full --force zpool-import@.service
.PHONY: install-zpool-import

enable-zpool-import:
	sudo systemctl enable zpool-import@$(FS).service
.PHONY: enable-zpool-import
