SHELL=/usr/bin/env bash

.PHONY: all
all: build

CLEAN:=
BINS:=

TELEGRAF_PATH:=telegraf/
LOTUS_PATH:=lotus/
VISOR_PATH:=sentinel-visor/
BUILD_PATH:=build/

#############
## BUILD
#############

.PHONY: build
build: telegraf lotus chainwatch visor

.PHONY: telegraf
telegraf: deps build/telegraf

build/telegraf:
	$(MAKE) -C $(TELEGRAF_PATH) telegraf
	cp $(TELEGRAF_PATH)telegraf build/telegraf
	@if [ ! -f ./build/telegraf.conf ]; then cp ./scripts/telegraf.conf.default build/telegraf.conf; fi;
BINS+=build/telegraf

.PHONY: lotus
lotus: deps build/lotus

build/lotus:
	$(MAKE) -C $(LOTUS_PATH) deps lotus
	cp $(LOTUS_PATH)lotus build/lotus
BINS+=build/lotus

.PHONY: chainwatch
chainwatch: deps build/chainwatch

build/chainwatch:
	$(MAKE) -C $(LOTUS_PATH) deps lotus-chainwatch
	cp $(LOTUS_PATH)lotus-chainwatch build/chainwatch
BINS+=build/chainwatch

.PHONY: visor
visor: deps build/visor

build/visor:
	$(MAKE) -C $(VISOR_PATH) deps sentinel-visor
	cp $(VISOR_PATH)sentinel-visor build/sentinel-visor
BINS+=build/sentinel-visor

.PHONY: deps
deps:
	git submodule update --init --recursive

#############
## EXECUTE
#############

.PHONY: run-docker
run-docker:
	docker-compose up -d

.PHONY: run-lotus
run-lotus: build/lotus
	build/lotus daemon & echo $$! > ./build/.lotus.pid

.PHONY: run-telegraf
run-telegraf: build/telegraf
	build/telegraf --config build/telegraf.conf --debug & echo $$! > ./build/.telegraf.pid

LOTUS_DB ?= postgres://postgres:password@localhost:5432/postgres?sslmode=disable
LOTUS_REPO ?= $(HOME)/.lotus
.PHONY: run-chainwatch
run-chainwatch: build/chainwatch
	build/chainwatch --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run & echo $$! > ./build/.chainwatch.pid

.PHONY: run-visor-indexer
run-visor-indexer: build/visor
	build/sentinel-visor --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run indexer & echo $$! > ./build/.visor-indexer.pid

.PHONY: run-visor-processor
run-visor-processor: build/visor
	build/sentinel-visor --db=$(LOTUS_DB) --repo=$(LOTUS_REPO) run processor & echo $$! > ./build/.visor-processor.pid

.PHONY: stop-docker
stop-docker:
	docker-compose stop

.PHONY: stop-lotus
stop-lotus:
	@if [ -a ./build/.lotus.pid ]; then kill -TERM $$(cat ./build/.lotus.pid); rm ./build/.lotus.pid || true; fi;

.PHONY: stop-telegraf
stop-telegraf:
	@if [ -a ./build/.telegraf.pid ]; then kill -TERM $$(cat ./build/.telegraf.pid); rm ./build/.telegraf.pid || true; fi;

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
install-services: install-telegraf-service install-chainwatch-service install-lotus-service install-sentinel-service

.PHONY: replace-services
replace-services: replace-lotus-service replace-chainwatch-service replace-telegraf-service

.PHONY: clean-services
clean-services: clean-sentinel-service clean-lotus-service clean-chainwatch-service clean-telegraf-service

.PHONY: install-sentinel-service
install-sentinel-service: check-sudo
	mkdir -p /usr/local/lib/systemd/system
	install -C -m 0644 ./scripts/sentinel.service /usr/local/lib/systemd/system/sentinel.service
	systemctl daemon-reload

.PHONY: clean-sentinel-service
clean-sentinel-service: check-sudo
	rm -f /usr/local/lib/systemd/system/sentinel.service
	systemctl daemon-reload

.PHONY: install-telegraf-pkg
install-telegraf-pkg: check-sudo deps
	# linux-only package
	rm -f build/*x86_64.rpm build/*amd64.tar.gz build/*amd64.deb
	(cd ./telegraf && ./scripts/build.py --package --platform=linux --arch=amd64 -o ../build -n telegraf)
	dpkg -i build/telegraf*.deb

.PHONY: install-telegraf-service
install-telegraf-service: check-sudo install-telegraf-pkg
	cp ./build/telegraf.conf /etc/telegraf/telegraf.conf # matches deb pkg destination
	cp ./scripts/telegraf.service /lib/systemd/system/telegraf.service # matches deb pkg destination
	mkdir -p /etc/sentinel
	mkdir -p /var/log/sentinel
	@echo
	@echo "Telegraf service installed. Don't forget to edit /etc/telegraf/telegraf.conf or to"
	@echo "'systemctl enable telegraf' for it to be enabled on startup."
	@echo

.PHONY: replace-telegraf-service
replace-telegraf-service: check-sudo telegraf
	# keep existing configuration
	@if [ -f /etc/telegraf/telegraf.conf ]; then \
			echo "Preserving /etc/telegraf/telegraf.conf..."; \
			cp /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.keep; \
		fi;
	@if [ -f /lib/systemd/system/telegraf.service ]; then \
			echo "Preserving /lib/systemd/system/telegraf.service..."; \
			cp /lib/systemd/system/telegraf.service /lib/systemd/system/telegraf.service.keep; \
		fi;
	-systemctl stop telegraf
	$(MAKE) install-telegraf-pkg
	systemctl daemon-reload
	systemctl start telegraf
	# restore existing configuration
	@if [ -f /etc/telegraf/telegraf.keep ]; then \
			echo "Restoring /etc/telegraf/telegraf.conf..."; \
			mv -f /etc/telegraf/telegraf.keep /etc/telegraf/telegraf.conf; \
		fi;
	@if [ -f /lib/systemd/system/telegraf.service.keep ]; then \
			echo "Restoring /lib/systemd/system/telegraf.service..."; \
			mv -f /lib/systemd/system/telegraf.service.keep /lib/systemd/system/telegraf.service; \
		fi;

.PHONY: clean-telegraf-service
clean-telegraf-service: check-sudo
	sudo dpkg -r telegraf

.PHONY: install-lotus-service
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

.PHONY: replace-lotus-service
replace-lotus-service: check-sudo lotus
	-systemctl stop lotus-daemon
	install -C ./build/lotus /usr/local/bin/lotus
	systemctl daemon-reload
	systemctl start lotus-daemon

.PHONY: clean-lotus-service
clean-lotus-service: check-sudo
	rm -f /usr/local/bin/lotus
	rm -f /usr/local/lib/systemd/system/lotus-daemon.service
	systemctl daemon-reload

.PHONY: install-chainwatch-service
install-chainwatch-service: check-sudo chainwatch
	install -C ./build/chainwatch /usr/local/bin/chainwatch
	mkdir -p /usr/local/lib/systemd/system
	install -C -m 0644 ./scripts/chainwatch.service /usr/local/lib/systemd/system/chainwatch.service
	systemctl daemon-reload
	mkdir -p /etc/sentinel
	@echo
	@echo "Chainwatch service installed. Don't forget to 'systemctl enable chainwatch' for it to be enabled on startup."
	@echo

.PHONY: replace-chainwatch-service
replace-chainwatch-service: check-sudo chainwatch
	-systemctl stop chainwatch
	install -C ./build/chainwatch /usr/local/bin/chainwatch
	systemctl daemon-reload
	systemctl start chainwatch

.PHONY: clean-chainwatch-service
clean-chainwatch-service: check-sudo
	rm -f /usr/local/bin/chainwatch
	rm -f /usr/local/lib/systemd/system/chainwatch.service
	systemctl daemon-reload

.PHONY: install-visor-indexer-service
install-visor-indexer-service: check-sudo visor
	install -C ./build/sentinel-visor /usr/local/bin/sentinel-visor
	mkdir -p /usr/local/lib/systemd/system
	install -C -m 0644 ./scripts/visor-indexer.service /usr/local/lib/systemd/system/visor-indexer.service
	systemctl daemon-reload
	mkdir -p /etc/sentinel
	@echo
	@echo "Visor indexer service installed. Don't forget to 'systemctl enable visor-indexer' for it to be enabled on startup."
	@echo

.PHONY: replace-visor-indexer-service
replace-visor-indexer-service: check-sudo visor
	-systemctl stop visor-indexer
	install -C ./build/sentinel-visor /usr/local/bin/sentinel-visor
	systemctl daemon-reload
	systemctl start visor-indexer

.PHONY: clean-visor-indexer-service
clean-visor-indexer-service: check-sudo
	rm -f /usr/local/lib/systemd/system/visor-indexer.service
	systemctl daemon-reload

.PHONY: install-visor-processor-service
install-visor-processor-service: check-sudo visor
	install -C ./build/sentinel-visor /usr/local/bin/sentinel-visor
	mkdir -p /usr/local/lib/systemd/system
	install -C -m 0644 ./scripts/visor-processor.service /usr/local/lib/systemd/system/visor-processor.service
	systemctl daemon-reload
	mkdir -p /etc/sentinel
	@echo
	@echo "Visor processor service installed. Don't forget to 'systemctl enable visor-processor' for it to be enabled on startup."
	@echo

.PHONY: replace-visor-processor-service
replace-visor-processor-service: check-sudo visor
	-systemctl stop visor-processor
	install -C ./build/sentinel-visor /usr/local/bin/sentinel-visor
	systemctl daemon-reload
	systemctl start visor-processor

.PHONY: clean-visor-processor-service
clean-visor-processor-service: check-sudo
	rm -f /usr/local/lib/systemd/system/visor-processor.service
	systemctl daemon-reload

.PHONY: clean-state
clean-state: check-state
	docker-compose down -v

.PHONY: check-state
check-state:
	@( read -p "Removing saved data! Sure? [y/N]: " ans && case "$$ans" in [yY]) true;; *) false;; esac )

.PHONY: clean
clean: check-uncommitted
	-$(MAKE) -C $(TELEGRAF_PATH) clean
	-$(MAKE) -C $(LOTUS_PATH) clean
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
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-painnet:~/sentinel/

.PHONY: deploy-interopnet
deploy-interopnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-interopnet:~/sentinel/

.PHONY: deploy-testnet
deploy-testnet:
	rsync -rv --include=.* --exclude=build/telegraf --exclude=telegraf/plugins/inputs/lotus/extern/* $(PWD)/. sentinel-testnet:~/sentinel/
