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

#############
## BUILD
#############

build: telegraf build-services
.PHONY: build

build/.update_submodules:
	git submodule update --init --recursive
	touch $@
CLEAN+=build/.update_submodules

build-services:
	docker-compose build
.PHONY: build-services

build/telegraf:
	$(MAKE) -C ${TELEGRAF_PATH} telegraf
	mv ${TELEGRAF_PATH}telegraf build/telegraf
BINS+=build/telegraf

deps: build/.update_submodules
.PHONY: deps

telegraf: deps build/telegraf
.PHONY: telegraf

#############
## EXECUTE
#############

run: build/telegraf run-services run-telegraf
.PHONY: run
CLEAN+=.telegraf.pid

run-services:
	docker-compose up -d
.PHONY: run-services

run-telegraf:
	build/telegraf --config build/telegraf.conf --debug & echo $$! > .telegraf.pid
.PHONY: run-telegraf

stop: stop-telegraf stop-services
.PHONY: stop

stop-services:
	docker-compose stop
.PHONY: stop-services

stop-telegraf:
	@if [ -a .telegraf.pid ]; then kill -TERM $$(cat .telegraf.pid); rm .telegraf.pid || true; fi;
.PHONY: stop-telegraf

#############
## MANAGE
#############

install-telegraf-service:
	# linux-only package
	(cd ./telegraf && ./scripts/build.py --package --platform=linux --arch=amd64 -o ../build -n telegraf)
	dpkg -i build/telegraf*.deb
	cp ./build/telegraf.conf /etc/telegraf/telegraf.conf
	@echo
	@echo "Telegraf service installed. Don't forget to edit /etc/telegraf/telegraf.conf as needed."
.PHONY: install-telegraf-service

clean-telegraf-service:
	sudo dpkg -r telegraf
.PHONY: clean-telegraf-service

conf:
	@if [ -a build/telegraf.conf ]; then mv build/telegraf.conf build/telegraf.old || true; fi;
	build/telegraf --input-filter lotus --output-filter postgresql --section-filter agent:global_tags:outputs:inputs config > build/telegraf.conf
	@echo
	@echo "Produced default config file at ./build/telegraf.conf. Please edit with your changes before using."
.PHONY: conf

clean-state: state-check
	rm -rf $(CLEAN) $(BINS)
	-$(MAKE) -C $(TELEGRAF_PATH) clean
	docker-compose down -v
.PHONY: clean

state-check:
	@( read -p "Removing saved data! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )
.PHONY: danger-check

clean-all: uncommitted-check
	git clean -xdff
	git submodule deinit --all -f
.PHONY: dist-clean

uncommitted-check:
	@( read -p "Removing uncommitted changes! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )
.PHONY: danger-check

deploy-dev:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* ${PWD}/. sentinel-dev:~/sentinel/
.PHONY: deploy-dev

deploy-staging:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* ${PWD}/. sentinel-staging:~/sentinel/
.PHONY: deploy-dev

deploy-testnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* ${PWD}/. sentinel-testnet:~/sentinel/
.PHONY: deploy-dev
