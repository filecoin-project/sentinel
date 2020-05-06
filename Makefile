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

telegraf: build/.update_submodules
.PHONY: telegraf

build/telegraf: telegraf
	$(MAKE) -C ${TELEGRAF_PATH} telegraf
	mv ${TELEGRAF_PATH}telegraf build/telegraf
BINS+=build/telegraf

build: build/telegraf
.PHONY: build

run: telegraf
	build/telegraf --config telegraf.conf --debug & echo $$! > .telegraf.pid
.PHONY: run
CLEAN+=.telegraf.pid

stop:
	@if [ -a .telegraf.pid ]; then kill -TERM $$(cat .telegraf.pid); rm .telegraf.pid || true; fi;
.PHONY: stop

# MISC

conf: telegraf
	build/telegraf --input-filter lotus --output-filter postgresql --section-filter agent:global_tags:outputs:inputs config > telegraf.conf
.PHONY: conf

clean:
	rm -rf $(CLEAN) $(BINS)
	-$(MAKE) -C $(TELEGRAF_PATH) clean
.PHONY: clean

dist-clean:
	git clean -xdff
	git submodule deinit --all -f
.PHONY: dist-clean

print-%:
	@echo $*=$($*)
