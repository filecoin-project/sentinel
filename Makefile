SHELL=/usr/bin/env bash

.PHONY: all
all: build

BINS:=
CLEAN:=

DRONE_PATH:=drone/
LOTUS_PATH:=lotus/
VISOR_PATH:=visor/

BUILD_PATH:=build/
CHAINWATCH_BUILD_PATH:=$(BUILD_PATH)chainwatch
DRONE_BUILD_PATH:=$(BUILD_PATH)drone
LOTUS_BUILD_PATH:=$(BUILD_PATH)lotus
VISOR_BUILD_PATH:=$(BUILD_PATH)visor

INSTALL_PATH:=/usr/local/bin/
CHAINWATCH_INSTALL_PATH:=$(INSTALL_PATH)lotus-chainwatch
LOTUS_INSTALL_PATH:=$(INSTALL_PATH)lotus
VISOR_INSTALL_PATH:=$(INSTALL_PATH)sentinel-visor
#DRONE_INSTALL_PATH:=NOTSET # managed by deb pkg installation

CONFIG_INSTALL_PATH:=/etc/sentinel/
LOG_INSTALL_PATH:=/var/log/sentinel/
SYSTEMD_INSTALL_PATH:=/usr/local/lib/systemd/system/

#############
## BUILD
#############

.PHONY: build
build: drone lotus chainwatch visor

.PHONY: drone
drone: deps $(DRONE_BUILD_PATH)

$(DRONE_BUILD_PATH):
	$(MAKE) -C $(DRONE_PATH) telegraf
	cp $(DRONE_PATH)telegraf $(DRONE_BUILD_PATH)
	@if [ ! -f ./build/drone.conf ]; then cp ./scripts/drone.conf.default build/drone.conf; fi;
BINS+=$(DRONE_BUILD_PATH)

.PHONY: lotus
lotus: deps $(LOTUS_BUILD_PATH)

$(LOTUS_BUILD_PATH):
	$(MAKE) -C $(LOTUS_PATH) deps lotus
	cp $(LOTUS_PATH)lotus $(LOTUS_BUILD_PATH)
BINS+=$(LOTUS_BUILD_PATH)

.PHONY: chainwatch
chainwatch: deps $(CHAINWATCH_BUILD_PATH)

$(CHAINWATCH_BUILD_PATH):
	$(MAKE) -C $(LOTUS_PATH) deps lotus-chainwatch
	cp $(LOTUS_PATH)lotus-chainwatch $(CHAINWATCH_BUILD_PATH)
BINS+=$(CHAINWATCH_BUILD_PATH)

.PHONY: visor
visor: deps $(VISOR_BUILD_PATH)

$(VISOR_BUILD_PATH):
	$(MAKE) -C $(VISOR_PATH) deps visor
	cp $(VISOR_PATH)visor $(VISOR_BUILD_PATH)
BINS+=$(VISOR_BUILD_PATH)

.PHONY: deps
deps:
	git submodule update --init --recursive

#############
## EXECUTE
#############

.PHONY: run-docker
run-docker:
	docker-compose up -d

.PHONY: run-docker-jaeger
run-docker-jaeger:
	docker-compose -f ./scripts/docker-compose-jaeger.yml up -d

.PHONY: run-lotus
run-lotus: $(LOTUS_BUILD_PATH)
	$(LOTUS_BUILD_PATH) daemon & echo $$! > ./build/.lotus.pid

.PHONY: run-drone
run-drone: $(DRONE_BUILD_PATH)
	$(DRONE_BUILD_PATH) --config build/drone.conf --debug & echo $$! > ./build/.drone.pid

LOTUS_DB ?= postgres://postgres:password@localhost:5432/postgres?sslmode=disable
LOTUS_REPO ?= $(HOME)/.lotus
.PHONY: run-chainwatch
run-chainwatch: $(CHAINWATCH_BUILD_PATH)
	$(CHAINWATCH_BUILD_PATH) --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run & echo $$! > ./build/.chainwatch.pid

.PHONY: run-visor-indexer
run-visor-indexer: $(VISOR_BUILD_PATH)
	$(VISOR_BUILD_PATH) --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run --scw 0 --asw 0 --mw 0 --gow 0 --indexhead-confidence 2 & echo $$! > ./build/.visor-indexer.pid

.PHONY: run-visor-processor
run-visor-processor: $(VISOR_BUILD_PATH)
	$(VISOR_BUILD_PATH) --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run --indexhistory=false --indexhead=false & echo $$! > ./build/.visor-processor.pid

.PHONY: run-visor
run-visor-processor: $(VISOR_BUILD_PATH)
	$(VISOR_BUILD_PATH) --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run & echo $$! > ./build/.visor.pid

.PHONY: stop-docker
stop-docker:
	docker-compose stop

.PHONY: stop-docker-jaeger
stop-docker-jaeger:
	docker-compose -f ./scripts/docker-compose-jaeger.yml stop

.PHONY: stop-lotus
stop-lotus:
	@if [ -a ./build/.lotus.pid ]; then kill -TERM $$(cat ./build/.lotus.pid); rm ./build/.lotus.pid || true; fi;

.PHONY: stop-drone
stop-drone:
	@if [ -a ./build/.drone.pid ]; then kill -TERM $$(cat ./build/.drone.pid); rm ./build/.drone.pid || true; fi;

.PHONY: stop-chainwatch
stop-chainwatch:
	@if [ -a ./build/.chainwatch.pid ]; then kill -TERM $$(cat ./build/.chainwatch.pid); rm ./build/.chainwatch.pid || true; fi;

.PHONY: stop-visor-indexer
stop-visor-indexer:
	@if [ -a ./build/.visor-indexer.pid ]; then kill -TERM $$(cat ./build/.visor-indexer.pid); rm ./build/.visor-indexer.pid || true; fi;

.PHONY: stop-visor-processor
stop-visor-processor:
	@if [ -a ./build/.visor-processor.pid ]; then kill -TERM $$(cat ./build/.visor-processor.pid); rm ./build/.visor-processor.pid || true; fi;

#############
## MANAGE
#############

.PHONY: install-services
install-services: install-drone-service install-chainwatch-service install-lotus-service install-sentinel-service

.PHONY: replace-services
replace-services: replace-lotus-service replace-chainwatch-service replace-drone-service

.PHONY: clean-services
clean-services: clean-sentinel-service clean-lotus-service clean-chainwatch-service clean-drone-service

.PHONY: install-sentinel-service
install-sentinel-service: check-sudo
	mkdir -p $(SYSTEMD_INSTALL_PATH)
	install -C -m 0644 ./scripts/sentinel.service $(SYSTEMD_INSTALL_PATH)sentinel.service
	systemctl daemon-reload

.PHONY: clean-sentinel-service
clean-sentinel-service: check-sudo
	rm -f $(SYSTEMD_INSTALL_PATH)sentinel.service
	systemctl daemon-reload

.PHONY: install-drone-pkg
install-drone-pkg: check-sudo deps
	# linux-only package
	rm -f build/*x86_64.rpm build/*amd64.tar.gz build/*amd64.deb
	(cd $(DRONE_PATH) && ./scripts/build.py --package --platform=linux --arch=amd64 -o ../build -n telegraf)
	dpkg -i build/telegraf*.deb

.PHONY: install-drone-service
install-drone-service: check-sudo install-drone-pkg
	cp ./build/drone.conf /etc/telegraf/telegraf.conf # overwrite deb pkg default config
	rm /lib/systemd/system/telegraf.service # rm deb pkg default service
	cp ./scripts/drone.service /lib/systemd/system/sentinel-drone.service
	systemctl daemon-reload
	mkdir -p $(CONFIG_INSTALL_PATH)
	mkdir -p $(LOG_INSTALL_PATH)
	@echo
	@echo "Sentinel Drone service installed. Don't forget to edit /etc/telegraf/telegraf.conf or to"
	@echo "'systemctl enable sentinel-drone' for it to be enabled on startup."
	@echo

.PHONY: replace-drone-service
replace-drone-service: check-sudo drone
	# keep existing configuration
	@if [ -f /etc/telegraf/telegraf.conf ]; then \
			echo "Preserving /etc/telegraf/telegraf.conf..."; \
			cp /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.keep; \
		fi;
	@if [ -f /lib/systemd/system/telegraf.service ]; then \
			# TODO: Remove legacy service path
			echo "Migrating legacy service path (/lib/systemd/system/telegraf.service -> /lib/systemd/system/sentinel-drone.service)..."; \
			cp /lib/systemd/system/telegraf.service /lib/systemd/system/sentinel-drone.service; \
		fi;
	@if [ -f /lib/systemd/system/sentinel-drone.service ]; then \
			echo "Preserving /lib/systemd/system/sentinel-drone.service..."; \
			cp /lib/systemd/system/sentinel-drone.service /lib/systemd/system/sentinel-drone.service.keep; \
		fi;
	# TODO: Remove legacy service name
	-systemctl stop telegraf sentinel-drone
	$(MAKE) install-drone-pkg
	# restore existing configuration
	@if [ -f /etc/telegraf/telegraf.keep ]; then \
			echo "Restoring /etc/telegraf/telegraf.conf..."; \
			mv -f /etc/telegraf/telegraf.keep /etc/telegraf/telegraf.conf; \
		fi;
	@if [ -f /lib/systemd/system/sentinel-drone.service.keep ]; then \
			echo "Restoring /lib/systemd/system/sentinel-drone.service..."; \
			mv -f /lib/systemd/system/sentinel-drone.service.keep /lib/systemd/system/sentinel-drone.service; \
		fi;
	systemctl daemon-reload
	systemctl start sentinel-drone

.PHONY: clean-drone-service
clean-drone-service: check-sudo
	sudo dpkg -r telegraf

.PHONY: install-lotus-service
install-lotus-service: check-sudo lotus
	install -C $(LOTUS_BUILD_PATH) $(LOTUS_INSTALL_PATH)
	mkdir -p $(SYSTEMD_INSTALL_PATH)
	install -C -m 0644 ./scripts/lotus-daemon.service $(SYSTEMD_INSTALL_PATH)lotus-daemon.service
	systemctl daemon-reload
	mkdir -p $(CONFIG_INSTALL_PATH)
	mkdir -p $(LOG_INSTALL_PATH)
	@echo
	@echo "Lotus service installed. Don't forget to 'systemctl enable lotus' for it to be enabled on startup."
	@echo

.PHONY: replace-lotus-service
replace-lotus-service: check-sudo lotus
	-systemctl stop lotus-daemon
	install -C $(LOTUS_BUILD_PATH) $(LOTUS_INSTALL_PATH)
	systemctl daemon-reload
	systemctl start lotus-daemon

.PHONY: clean-lotus-service
clean-lotus-service: check-sudo
	rm -f $(LOTUS_INSTALL_PATH)
	rm -f $(SYSTEMD_INSTALL_PATH)lotus-daemon.service
	systemctl daemon-reload

.PHONY: install-chainwatch-service
install-chainwatch-service: check-sudo chainwatch
	install -C $(CHAINWATCH_BUILD_PATH) $(CHAINWATCH_INSTALL_PATH)
	mkdir -p $(SYSTEMD_INSTALL_PATH)
	install -C -m 0644 ./scripts/chainwatch.service $(SYSTEMD_INSTALL_PATH)chainwatch.service
	systemctl daemon-reload
	mkdir -p $(CONFIG_INSTALL_PATH)
	@echo
	@echo "Chainwatch service installed. Don't forget to 'systemctl enable chainwatch' for it to be enabled on startup."
	@echo

.PHONY: replace-chainwatch-service
replace-chainwatch-service: check-sudo chainwatch
	-systemctl stop chainwatch
	install -C $(CHAINWATCH_BUILD_PATH) $(CHAINWATCH_INSTALL_PATH)
	systemctl daemon-reload
	systemctl start chainwatch

.PHONY: clean-chainwatch-service
clean-chainwatch-service: check-sudo
	rm -f $(CHAINWATCH_INSTALL_PATH)
	rm -f $(SYSTEMD_INSTALL_PATH)chainwatch.service
	systemctl daemon-reload

.PHONY: install-visor-service
install-visor-service: check-sudo visor
	install -C $(VISOR_BUILD_PATH) $(VISOR_INSTALL_PATH)
	mkdir -p $(SYSTEMD_INSTALL_PATH)
	install -C -m 0644 ./scripts/sentinel-visor.service $(SYSTEMD_INSTALL_PATH)sentinel-visor.service
	systemctl daemon-reload
	mkdir -p $(CONFIG_INSTALL_PATH)
	@echo
	@echo "Visor indexer service installed. Don't forget to 'systemctl enable sentinel-visor' for it to be enabled on startup."
	@echo

.PHONY: replace-visor-service
replace-visor-service: check-sudo visor
	-systemctl stop sentinel-visor
	install -C $(VISOR_BUILD_PATH) $(VISOR_INSTALL_PATH)
	systemctl daemon-reload
	systemctl start sentinel-visor

.PHONY: clean-visor-service
clean-visor-service: check-sudo
	rm -f $(SYSTEMD_INSTALL_PATH)sentinel-visor.service
	systemctl daemon-reload

.PHONY: clean-state
clean-state: check-state
	docker-compose down -v

.PHONY: check-state
check-state:
	@( read -p "Removing saved data! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )

.PHONY: clean
clean: check-uncommitted
	-$(MAKE) -C $(DRONE_PATH) clean
	-$(MAKE) -C $(LOTUS_PATH) clean
	-$(MAKE) -C $(VISOR_PATH) clean
	rm -rf $(CLEAN) $(BINS)
	git clean -xdff
	git submodule deinit --all -f

.PHONY: check-uncommitted
check-uncommitted:
	@( read -p "Removing uncommitted changes! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )

.PHONY: check-sudo
check-sudo:
	@runner=`whoami` ; \
	if [ $$runner != "root" ]; then \
		echo "Please run 'make $(MAKECMDGOALS)' with superuser privledges."; \
		exit 1; \
	fi

.PHONY: deploy-painnet
deploy-painnet:
	rsync -rv --include=.* --exclude=build --exclude=drone/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-painnet:~/sentinel/

.PHONY: deploy-interopnet
deploy-interopnet:
	rsync -rv --include=.* --exclude=build --exclude=drone/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-interopnet:~/sentinel/

.PHONY: deploy-testnet
deploy-testnet:
	rsync -rv --include=.* --exclude=build --exclude=drone/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-testnet:~/sentinel/
