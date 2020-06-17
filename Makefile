SHELL=/usr/bin/env bash

all: build
.PHONY: all

CLEAN:=
BINS:=

TELEGRAF_PATH:=telegraf/
BUILD_PATH:=build/

#############
## BUILD
#############

build: build-services
.PHONY: build

build-services: telegraf
	docker-compose build
.PHONY: build-services

telegraf: deps build/telegraf
.PHONY: telegraf

build/telegraf:
	$(MAKE) -C ${TELEGRAF_PATH} telegraf
	mv ${TELEGRAF_PATH}telegraf build/telegraf
	@if [ ! -f ./build/telegraf.conf ]; then cp ./telegraf.default build/telegraf.conf; fi;
BINS+=build/telegraf

deps:
	git submodule update --init --recursive
.PHONY: deps

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

clean-state: state-check
	docker-compose down -v
.PHONY: clean

state-check:
	@( read -p "Removing saved data! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )
.PHONY: danger-check

clean: uncommitted-check
	rm -rf $(CLEAN) $(BINS)
	-$(MAKE) -C $(TELEGRAF_PATH) clean
	git clean -xdff
	git submodule deinit --all -f
.PHONY: dist-clean

uncommitted-check:
	@( read -p "Removing uncommitted changes! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )
.PHONY: danger-check

deploy-painnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* ${PWD}/. sentinel-painnet:~/sentinel/
.PHONY: deploy-painnet

deploy-interopnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* ${PWD}/. sentinel-interopnet:~/sentinel/
.PHONY: deploy-interopnet

deploy-testnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* ${PWD}/. sentinel-testnet:~/sentinel/
.PHONY: deploy-testnet
