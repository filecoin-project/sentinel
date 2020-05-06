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

deps:
	git submodule update --init --recursive
.PHONY: deps

telegraf: deps
	@$(MAKE) -C ${TELEGRAF_PATH} telegraf
	mv ${TELEGRAF_PATH}telegraf build/telegraf
.PHONY: telegraf
BINS+=build/telegraf

build: telegraf
.PHONY: build

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
