# Sentinel

> The Filecoin Network Monitoring and Analysis System

[![CircleCI](https://circleci.com/gh/filecoin-project/sentinel.svg?style=svg&circle-token=6dee046c14c81af4e1c526fa36ebcb486677be69)](https://app.circleci.com/pipelines/github/filecoin-project/sentinel)

Sentinel is a collection of services which monitor the health and function of the Filecoin network. 

A **Visor** process collects _permenant_ Filecoin chain meterics from a [**Lotus**](https://github.com/filecoin-project/lotus/) daemon, and writes them to a [**TimescaleDB**](https://github.com/timescale/timescaledb), a time-series and relational datastore.

Many [**Drone**](https://github.com/filecoin-shipyard/sentinel-drone) instances collect _ephemeral_, node-specific Lotus metrics and write them to the same TimescaleDB.

The metrics are displayed in [**Grafana**](https://github.com/grafana/grafana). A set of _very important queries_ are captured in Grafana to track and alert on critical performance and economic health indicators over time.

![sentinel architecture diagram](https://user-images.githubusercontent.com/58871/92904320-ae5ed900-f41a-11ea-8c92-fd28c0223b74.png)

## Getting Started (tl;dr)

This will setup Lotus to run against mainnet. Syncing the network will take a long time and will not be quick. Access to a fully synced node may be achieved this way if there is sufficient time to wait for sync to complete.

1. `git clone git@github.com:filecoin-project/sentinel.git`
2. `cd sentinel`
3. `make deps`
4. `make run-lotus`
5. (In another window) `build/lotus sync wait` which blocks until lotus finishes syncing the chain.
6. `make run-docker` to start Docker services
7. (In separate windows) `make run-drone` and `make run-visor`.

## Getting Started Step-by-Step

Clone the repo and fetch the submodules. `make` will help you out:

```console
$ git clone git@github.com:filecoin-project/sentinel.git
$ cd sentinel
$ make deps
git submodule update --init --recursive
...
```

Now we need to get Lotus built and syncing the chain.

### Lotus

Sentinel requires a running lotus daemon that has completed synching the chain locally. A full sync of the [Mainnet](https://network.filecoin.io/#mainnet) takes days. You can test against the [Nerpa network](https://network.filecoin.io/#nerpa) to try Sentinel out.

Follow the [Lotus install and setup instructions](https://docs.filecoin.io/get-started/lotus/installation), to install the dependencies, check out the branch for the network you want to join, (e.g. `ntwrk-nerpa`), and build a local copy of lotus. If you need to test against mainnet, see [Testing against Mainnet](#testing-against-mainnet).

Run Lotus to start syncing.
```console
$ lotus daemon
```

In a sperate shell, ask lotus to tell us when it has finished syncing.
```console
$ lotus sync wait
lotus sync wait
Worker 0: Target Height: 9099	Target: [bafy2bzacecqrt46shkioecxkt6mrdvi5xd73wh2gonrp3bhxfut6szc2labj6]	State: complete	Height: 9099
Done!
```

Now let's set up the Database.

### TimescaleDB

A [`docker-compose`](./docker-compose.yml) file is provided that will spin up a TimescaleDB and a Grafana instance to query it. Check that you have `docker` and `docker-compose` installed. [Docker Desktop](https://docs.docker.com/desktop/) is relatively painless. 

```console
$ make run-docker
```

Note that TimescaleDB is packaged as an Postgres extension, so some other components will refer to it as Postgres.

Now we need to generate some data with Visor and Drone

### Visor

In a new shell run Visor. [By default](https://github.com/filecoin-project/sentinel/blob/d1623b47649113c12aa53c943b4ddb60401f4632/Makefile#L93-L94) it will read Lotus data from `$(HOME)/.lotus` and writes to the local TimescaleDB container we just started at `localhost:5432`.

```console
$ make run-visor
```

If there are no `ERROR`s then it is now writing filecoin chain metrics to the database.

### Drone

In another shell, run Drone. [By default](./scripts/telegraf.conf.default) it reads the Lotus data dir at `$(HOME)/.lotus` and Lotus Prometheus metrics from http://127.0.0.1:1234/debug/metrics and writes to the TimescaleDB container at `localhost:5432`. Edit `build/telegraf.conf` if you need to customise those values.

```console
$ make run-drone
...
2020-09-18T11:24:22Z D! [agent] Successfully connected to outputs.postgresql
2020-09-18T11:24:31Z D! [outputs.postgresql] Wrote batch of 38 metrics in 588.361501ms
2020-09-18T11:24:32Z D! [inputs.lotus] Recorded lotus info
2020-09-18T11:24:32Z D! [inputs.lotus] Recorded pending mpool messages
2020-09-18T11:24:32Z I! [inputs.lotus] Service workers started
...
```

Verify that it connects to postgres (TimescaleDB is a postgres extention) and is able to read data from lotus without errors.

### Grafana

Grafana and a set of Sentinel dashboards are provisioned in a container along with the TimescaleDB as part of the `make run-docker` target.

Visit http://localhost:3000 to open Grafana and login with username and password as `admin`. You should now see a `sentinel` folder with dashboards in. Have an explore, and make some more! Look at [`./grafana/provisioning/dashboards/dashboards.yml`](./grafana/provisioning/dashboards/dashboards.yml) to see how the existing dashboards are provisioned. You can export new dashboards as JSON from the grafana UI and update that file to add new ones.

## Managing Sentinel

### Build

Note: Build artifacts are put into `./build` path. If you want to force building without `make clean`ing first, you can also `make -B <target>`.

`make` - produces all build targets (lotus, visor, and drone binaries)

`make lotus` - only builds the lotus daemon binary

`make visor` - only builds the visor binary

`make drone` - only builds the Sentinel Drone agent binary

### Run/Stop

`make run-drone` - start development Sentinel Drone process with debug output (uses configuration at `build/drone.conf`)

`make run-lotus` - start lotus daemon with default settings (lotus repo at `$(HOME)/.lotus`)

`make run-visor` - start visor binary. The database and repo path can be changed from default via `LOTUS_DB` and `LOTUS_REPO` environment variables. (Defaults to `LOTUS_DB ?= postgres://postgres:password@localhost:5432/postgres?sslmode=disabled` and `LOTUS_REPO ?= $(HOME)/.lotus`.

`make run-docker` - start docker services (currently TimescaleDB, Grafana)

`make stop-drone` - stop development Sentinel Drone process

`make stop-visor` - stop visor process

`make stop-lotus` - stop lotus daemon process

`make stop-docker` - stop all docker services

### Management/Installation

`make install-services` - Install lotus-daemon, sentinel-drone, sentinel-visor as systemd services

`make replace-services` - Build lotus-daemon, sentinel-drone, sentinel-visor and replace existing binaries without deploying configuration files

`make clean-services` - Uninstall lotus-daemon, sentinel-drone, sentinel-visor as systemd services (not logs or configuration)

Install individual services:

`make install-drone-service`

`make install-lotus-service`

`make install-visor-service`

Replace individual services:

`make replace-drone-service`

`make replace-lotus-service`

`make replace-visor-service`

Also works with their `make clean-*-service` counterparts.

`make clean` - removes build artifacts

`make clean-state` - stops and destroys docker service volumes (which resets TimescaleDB and Grafana settings and configuration)

## Testing against Mainnet

A complete local sync of `Mainnet` takes a long time. To complete it in a reasonable time you need a copy of an already sync'd lotus data dir from a friendly filecoin operator. (NOTE: At present, regular chain snapshots, as described in https://docs.filecoin.io/get-started/lotus/chain-snapshots don't work for chainwatch because they are incomplete exports.)

To take a full copy of a Lotus data dir

- shutdown existing lotus
- run lotus daemon on your new box for just a moment (to initialize the repo path)
- tar/copy/transport .../.lotus/datastore into the same path on your destination
- start old and new daemons
- 🎉


## Code of Conduct

Sentinel follows the [Filecoin Project Code of Conduct](https://github.com/filecoin-project/community/blob/master/CODE_OF_CONDUCT.md). Before contributing, please acquaint yourself with our social courtesies and expectations.


## Contributing

Welcoming [new issues](https://github.com/filecoin-project/sentinel/issues/new) and [pull requests](https://github.com/filecoin-project/sentinel/pulls).


## License

The Filecoin Project and Sentinel is dual-licensed under Apache 2.0 and MIT terms:

- Apache License, Version 2.0, ([LICENSE-APACHE](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-MIT) or http://opensource.org/licenses/MIT)
