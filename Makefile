SHELL=/usr/bin/env bash

all: build
.PHONY: all

CLEAN:=
BINS:=

TELEGRAF_PATH:=telegraf/
LOTUS_PATH:=lotus/
BUILD_PATH:=build/

#############
## BUILD
#############

build: telegraf lotus chainwatch
.PHONY: build

telegraf: deps build/telegraf
.PHONY: telegraf

build/telegraf:
	$(MAKE) -C $(TELEGRAF_PATH) telegraf
	cp $(TELEGRAF_PATH)telegraf build/telegraf
	@if [ ! -f ./build/telegraf.conf ]; then cp ./scripts/telegraf.conf.default build/telegraf.conf; fi;
BINS+=build/telegraf

lotus: deps build/lotus
.PHONY: lotus

build/lotus:
	$(MAKE) -C $(LOTUS_PATH) lotus
	cp $(LOTUS_PATH)lotus build/lotus
BINS+=build/lotus

chainwatch: deps build/chainwatch
.PHONY: chainwatch

build/chainwatch:
	$(MAKE) -C $(LOTUS_PATH) chainwatch
	cp $(LOTUS_PATH)chainwatch build/chainwatch
BINS+=build/chainwatch

deps: build/.init_submodules
.PHONY: deps

build/.init_submodules:
	git submodule update --init --recursive
	touch $@
CLEAN+=build/.init_submodules

#############
## EXECUTE
#############

run-docker:
	docker-compose up -d
.PHONY: run-docker

run-lotus:
	build/lotus daemon & echo $$! > ./build/.lotus.pid
.PHONY: run-lotus

run-telegraf:
	build/telegraf --config build/telegraf.conf --debug & echo $$! > ./build/.telegraf.pid
.PHONY: run-telegraf

LOTUS_DB ?= postgres://postgres:password@localhost:5432/postgres?sslmode=disabled
LOTUS_REPO ?= $(HOME)/.lotus
run-chainwatch:
	build/chainwatch --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run & echo $$! > ./build/.chainwatch.pid
.PHONY: run-chainwatch

stop-docker:
	docker-compose stop
.PHONY: stop-docker

stop-lotus:
	@if [ -a ./build/.lotus.pid ]; then kill -TERM $$(cat ./build/.lotus.pid); rm ./build/.lotus.pid || true; fi;
.PHONY: stop-lotus

stop-telegraf:
	@if [ -a ./build/.telegraf.pid ]; then kill -TERM $$(cat ./build/.telegraf.pid); rm ./build/.telegraf.pid || true; fi;
.PHONY: stop-telegraf

stop-chainwatch:
	@if [ -a ./build/.chainwatch.pid ]; then kill -TERM $$(cat ./build/.chainwatch.pid); rm ./build/.chainwatch.pid || true; fi;
.PHONY: stop-chainwatch

#############
## MANAGE
#############

install-services: install-telegraf-service install-chainwatch-service install-lotus-service install-sentinel-service
.PHONY: install-services

clean-services: clean-sentinel-service clean-lotus-service clean-chainwatch-service clean-telegraf-service
.PHONY: clean-services

install-sentinel-service: check-sudo
	mkdir -p /usr/local/lib/systemd/system
	install -C -m 0644 ./scripts/sentinel.service /usr/local/lib/systemd/system/sentinel.service
	systemctl daemon-reload
.PHONY: install-sentinel-service

clean-sentinel-service: check-sudo
	rm -f /usr/local/lib/systemd/system/sentinel.service
	systemctl daemon-reload
.PHONY: clean-sentinel-service

install-telegraf-service: check-sudo deps
	# linux-only package
	(cd ./telegraf && ./scripts/build.py --package --platform=linux --arch=amd64 -o ../build -n telegraf)
	dpkg -i build/telegraf*.deb
	cp ./build/telegraf.conf /etc/telegraf/telegraf.conf # matches deb pkg destination
	cp ./scripts/telegraf.service /lib/systemd/system/telegraf.service # matches deb pkg destination
	mkdir -p /etc/sentinel
	mkdir -p /var/log/sentinel
	@echo
	@echo "Telegraf service installed. Don't forget to edit /etc/telegraf/telegraf.conf or to"
	@echo "'systemctl enable telegraf' for it to be enabled on startup."
	@echo
.PHONY: install-telegraf-service

clean-telegraf-service: check-sudo
	sudo dpkg -r telegraf
.PHONY: clean-telegraf-service

install-lotus-service: check-sudo lotus
	install -C ./build/lotus /usr/local/bin/lotus
	mkdir -p /usr/local/lib/systemd/system
	install -C -m 0644 ./scripts/lotus-daemon.service /usr/local/lib/systemd/system/lotus-daemon.service
	systemctl daemon-reload
	mkdir -p /etc/sentinel
	mkdir -p /var/log/sentinel
	@echo
	@echo "Lotus service installed. Don't forget to 'systemctl enable lotus' for it to be enabled on startup."
	@echo
.PHONY: install-lotus-service

clean-lotus-service: check-sudo
	rm -f /usr/local/bin/lotus
	rm -f /usr/local/lib/systemd/system/lotus-daemon.service
	systemctl daemon-reload
.PHONY: install-lotus-service

install-chainwatch-service: check-sudo chainwatch
	install -C ./build/chainwatch /usr/local/bin/chainwatch
	mkdir -p /usr/local/lib/systemd/system
	install -C -m 0644 ./scripts/chainwatch.service /usr/local/lib/systemd/system/chainwatch.service
	systemctl daemon-reload
	mkdir -p /etc/sentinel
	@echo
	@echo "Chainwatch service installed. Don't forget to 'systemctl enable chainwatch' for it to be enabled on startup."
	@echo
.PHONY: install-chainwatch-service

clean-chainwatch-service: check-sudo
	rm -f /usr/local/bin/chainwatch
	rm -f /usr/local/lib/systemd/system/chainwatch.service
	systemctl daemon-reload
.PHONY: install-chainwatch-service

clean-state: check-state
	docker-compose down -v
.PHONY: clean

check-state:
	@( read -p "Removing saved data! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )
.PHONY: check-state

clean: check-uncommitted
	-$(MAKE) -C $(TELEGRAF_PATH) clean
	-$(MAKE) -C $(LOTUS_PATH) clean
	rm -rf $(CLEAN) $(BINS)
	git clean -xdff
	git submodule deinit --all -f
.PHONY: dist-clean

check-uncommitted:
	@( read -p "Removing uncommitted changes! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )
.PHONY: check-uncommitted

check-sudo:
	@runner=`whoami` ; \
	if [ $$runner != "root" ]; then \
		echo "Please run 'make $(MAKECMDGOALS)' with superuser privledges."; \
		exit 1; \
	fi
.PHONY: check-sudo

deploy-painnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-painnet:~/sentinel/
.PHONY: deploy-painnet

deploy-interopnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-interopnet:~/sentinel/
.PHONY: deploy-interopnet

deploy-testnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-testnet:~/sentinel/
.PHONY: deploy-testnet
