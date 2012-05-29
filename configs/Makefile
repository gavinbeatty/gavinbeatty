.SUFFIXES:
.PHONY: help configure config conf install
help:
	@echo "Targets: help configure install"

configure:
	$(MAKE) -C common configure
	#$(MAKE) -C maths configure
config: configure
conf: configure

install:
	$(MAKE) -C common install
	#$(MAKE) -C maths install

