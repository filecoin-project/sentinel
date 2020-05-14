SHELL=/usr/bin/env bash

all: build
.PHONY: all

CLEAN:=
BINS:=

TELEGRAF_PATH:=telegraf/
BUILD_PATH:=build/

ldflags=-X=github.com/filecoin-project/lotus/build.CurrentCommit='+git$(subst -,.,$(shell git describe --always --match=NeVeRmAtCh --dirty 2>/dev/null || git rev-parse --short HEAD 2>/dev/null))'
ifneq ($(strip $(LDFLAGS)),)
	ldflags+=-extldflags=$(LDFLAGS)
endif

## MAIN BINARIES

build/.update_submodules:
	git submodule update --init --recursive
	touch $@
CLEAN+=build/.update_submodules

deps: build/.update_submodules
.PHONY: deps

build-services:
	docker-compose build
.PHONY: build-services

telegraf: build/.update_submodules build/telegraf
.PHONY: telegraf

build/telegraf:
	$(MAKE) -C ${TELEGRAF_PATH} telegraf
	mv ${TELEGRAF_PATH}telegraf build/telegraf
BINS+=build/telegraf

build: telegraf build-services
.PHONY: build

run: build/telegraf
	docker-compose up -d
	build/telegraf --config telegraf.conf --debug & echo $$! > .telegraf.pid
.PHONY: run
CLEAN+=.telegraf.pid

stop:
	@if [ -a .telegraf.pid ]; then kill -TERM $$(cat .telegraf.pid); rm .telegraf.pid || true; fi;
	docker-compose stop
.PHONY: stop

## MISC

conf: telegraf
	build/telegraf --input-filter lotus --output-filter postgresql --section-filter agent:global_tags:outputs:inputs config > telegraf.conf
.PHONY: conf

clean:
	rm -rf $(CLEAN) $(BINS)
	-$(MAKE) -C $(TELEGRAF_PATH) clean
	docker-compose down -v
.PHONY: clean

dist-clean: danger-check
	git clean -xdff
	git submodule deinit --all -f
.PHONY: dist-clean

danger-check:
	@( read -p "Are you sure?! Remove uncommitted changes? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )
.PHONY: danger-check

deploy-dev:
	rsync -rv --include=.* --exclude=telegraf/plugins/inputs/lotus/extern/* ${PWD}/. sentinel-dev:~/sentinel/
.PHONY: deploy-dev
