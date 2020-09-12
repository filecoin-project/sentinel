# Sentinel

> The Filecoin Network Monitoring and Analysis System

[![CircleCI](https://circleci.com/gh/filecoin-project/sentinel.svg?style=svg&circle-token=6dee046c14c81af4e1c526fa36ebcb486677be69)](https://app.circleci.com/pipelines/github/filecoin-project/sentinel)

Sentinel is a collection of services which monitor the health and function of the Filecoin network. 

A **Visor** process collects _permenant_ Filecoin chain meterics from a [**Lotus**](https://github.com/filecoin-project/lotus/) daemon, and writes them to a [**TimescaleDB**](https://github.com/timescale/timescaledb), a time-series and relational datastore.

Many [**Drone**](https://github.com/filecoin-shipyard/sentinel-drone) instances collect _ephemeral_, node-specific Lotus metrics and write them to the same TimescaleDB.

The metrics are displayed in [**Grafana**](https://github.com/grafana/grafana). A set of _very important queries_ are captured in Grafana to track and alert on critical performance and economic health indicators over time.

![sentinel architecture diagram](https://user-images.githubusercontent.com/58871/92904320-ae5ed900-f41a-11ea-8c92-fd28c0223b74.png)

## Setup

### Build and Start Sentinel

Follow the [Lotus installation instructions](https://lotu.sh/en+getting-started) to install dependencies for your operating system.

0. Start lotus daemon.
1. `git clone git@github.com:filecoin-project/sentinel.git`
2. `cd sentinel`
3. `make deps`
4. `make run-lotus`
5. (In another window) `build/lotus sync wait` which blocks until lotus finishes syncing the chain.
6. `make run-docker` to start Docker services
7. (In separate windows) `make run-telegraf` and `make run-chainwatch`.

### Configure Grafana

1. Visit [http://localhost:3000](http://localhost:3000) to open Grafana.
2. Login with username and password as `admin`. Change the admin password.

The datasource and dashboards are provisioned by the config in 

- `grafana/provisioning/dashboards/dashboards.yml`
- `grafana/provisioning/datasources/timescaledb.yml`

## Managing Sentinel

### Build

Note: Build artifacts are put into `./build` path. If you want to force building without `make clean`ing first, you can also `make -B <target>`.

`make` - produces all build targets (lotus, chainwatch, and telegraf)

`make lotus` - only builds the lotus daemon binary

`make chainwatch` - only builds the chainwatch binary

`make telegraf` - only builds the telegraf agent binary

### Run/Stop

`make run-telegraf` - start development Telegraf process with debug output (uses configuration at `build/telegraf.conf`)

`make run-lotus` - start lotus daemon with default settings (lotus repo at `$(HOME)/.lotus`)

`make run-chainwatch` - start chainwatch binary. The database and repo path can be changed from default via `LOTUS_DB` and `LOTUS_REPO` environment variables. (Defaults to `LOTUS_DB ?= postgres://postgres:password@localhost:5432/postgres?sslmode=disabled` and `LOTUS_REPO ?= $(HOME)/.lotus`.

`make run-docker` - start docker services (currently TimescaleDB, Grafana)

`make stop-telegraf` - stop development Telegraf process

`make stop-chainwatch` - stop chainwatch process

`make stop-lotus` - stop lotus daemon process

`make stop-docker` - stop all docker services

### Management/Installation

`make install-services` - Install lotus, telegraf, chainwatch as systemd services

`make upgrade-services` - Build lotus, telegraf, chainwatch and replace existing binaries without deploying configuration files

`make clean-services` - Uninstall lotus, telegraf, chainwatch as systemd services (not logs or configuration)

Install individual services:

`make install-telegraf-service`

`make install-lotus-service`

`make install-chainwatch-service`

Upgrade individual services:

`make upgrade-telegraf-service`

`make upgrade-lotus-service`

`make upgrade-chainwatch-service`

Also works with their `make clean-*-service` counterparts.

`make clean` - removes build artifacts

`make clean-state` - stops and destroys docker service volumes (which resets TimescaleDB and Grafana settings and configuration)

## Maintainers

- [@placer14](https://github.com/placer14)
- [@frrist](https://github.com/frrist)

## Code of Conduct

Sentinel follows the [Filecoin Project Code of Conduct](https://github.com/filecoin-project/community/blob/master/CODE_OF_CONDUCT.md). Before contributing, please acquaint yourself with our social courtesies and expectations.


## Contributing

Welcoming [new issues](https://github.com/filecoin-project/sentinel/issues/new) and [pull requests](https://github.com/filecoin-project/sentinel/pulls).


## License

The Filecoin Project and Sentinel is dual-licensed under Apache 2.0 and MIT terms:

- Apache License, Version 2.0, ([LICENSE-APACHE](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-MIT) or http://opensource.org/licenses/MIT)
