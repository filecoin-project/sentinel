# Sentinel

A Filecoin Network Monitoring and Analysis System


## Background

Sentinel is a collection of services which monitor the health and function of the Filecoin network. The system consists of TimescaleDB, a time-series and relational datastore, which captures metrics from interesting parts of the network and is exposed via Grafana, which presents the data via helpful and informative graphs and provides alerting and annotating for real-time monitoring.

The metrics are pushed to TimescaleDB from Telegraf-based remote-host agents and a centralized data processing pipeline. [Lotus](https://github.com/filecoin-project/lotus/) is attached to the processing pipeline as a source of truth for immutable network state.


## Setup

### Build and Start Sentinel

_TODO: Add missing build dep installation steps._

0. Start lotus daemon.
1. `git clone git@github.com:filecoin-project/sentinel.git`
2. `cd sentinel`
3. `make run-lotus`
4. (In another window) `build/lotus sync wait` which blocks until lotus finishes syncing the chain.
5. `make run-docker` to start Docker services
6. (In separate windows) `make run-telegraf` and `make run-chainwatch`.

### Configure Grafana Datasource

Note: This process will eventually be automatically provisioned on startup.

7. Visit [http://localhost:3000](http://localhost:3000) to open Grafana.
8. Login with username and password as `admin`. Change the admin password.
9. Follow prompt to setup a PostgreSQL Datasource with the following setttings:

#### PostgreSQL Connection

- Name (optional): `TimescaleDB`
- Host: `timescaledb:5432`
- Database: `postgres`
- User: `postgres`
- Password: `password`
- SSL Mode: `disabled`

#### PostgreSQL details

- Version: `10`
- TimescaleDB: `true`
- Min Time Interval: `1s`

10. Click Save and Test.

### Configure Grafana Dashboards

11. Return to Home and follow prompt to add new dashboards. Find the Import option in the top right of the screen.
12. Upload the desired dashboard JSON from the available dashboard payloads found in [grafana/provisioning/dashboards/](https://github.com/filecoin-project/sentinel/tree/master/grafana/provisioning/dashboards).
13. Click Import (or if you already have the dashboard imported with this name, select Overwrite).


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

`make run-chainwatch` - start chwinatch binary. The database and repo path can be changed from default via `LOTUS_DB` and `LOTUS_REPO` environment variables. (Defaults to `LOTUS_DB ?= postgres://postgres:password@localhost:5432/postgres?sslmode=disabled` and `LOTUS_REPO ?= $(HOME)/.lotus`.

`make run-docker` - start docker services (currently TimescaleDB, Grafana)

`make stop-telegraf` - stop development Telegraf process

`make stop-chainwatch` - stop chainwatch process

`make stop-lotus` - stop lotus daemon process

`make stop-docker` - stop all docker services

### Management/Installation

`make install-services` - Install lotus, telegraf, chainwatch as systemd services

`make clean-services` - Uninstall lotus, telegraf, chainwatch as systemd services (not logs or configuration)

Install individual services like so:

`make install-telegraf-service`

`make install-lotus-service`

`make install-chainwatch-service`

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
