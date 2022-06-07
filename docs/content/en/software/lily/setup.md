---
title: "Lily Setup"
linkTitle: "Setup"
description: "Build, initialize, configure, start and sync a Lily node."
lead: "Lily is a Go application which embeds a Lotus node.  Therefore, a lot of the setup process (build, init, sync) resembles that of a Lotus node."
menu:
  software:
    parent: "lily"
    identifier: "setup"
weight: 20
toc: true
---

---

## Basic help

The Lily binary is self-documented and should be used to obtain specific help about flags:

```bash
lily help overview # A high-level description of how Lily works
lily help # List all available subcommands
lily <subcommand> --help # Show help for subcommand and subcommand flags
```

Flags usually have an environment variable equivalent.

---

## Dependencies

You will need the same dependencies as for Lotus. See the [Lotus installation instructions](https://lotus.filecoin.io/lotus/install/prerequisites/) for the installation commands for each distribution.

---

## Build

Once you have all the dependencies, you can checkout the Lily repository and build the binary:


1. Clone the Repo

```bash
git clone https://github.com/filecoin-project/lily.git
cd ./lily
```

2. Checkout a [release](https://github.com/filecoin-project/lily/releases)

```bash
git checkout <release_tag>
```

3. Build Lily

For Mainnet:

```bash
export CGO_ENABLED=1
make clean all
```

For Calibration-Net:

```bash
export CGO_ENABLED=1
make clean calibnet
```

(Check the Makefile for eventual support for additional networks).

4. Install Lily (optional)

```bash
cp ./lily /usr/local/bin/lily
```

#### M1-based Macs

Because of the novel architecture of the M1-based Mac computers, some specific environment variables must be set before creating the lily executable:

```console
export GOARCH=arm64
export CGO_ENABLED=1
export LIBRARY_PATH=/opt/homebrew/lib
export FFI_BUILD_FROM_SOURCE=1
```

Make sure these are defined before running the `make` commands above.

---

## Initialize

Typical initialization and startup for Lily starts with initialization which
establishes the datastore, params, and boilerplate config. This is equivalent
to how a Lotus node works. For example, you can run:

```bash
lily init --repo=$HOME/.lily --config=$HOME/.lily/config.toml --import-snapshot minimal.car
```

The `--repo` and `--config` flag are optionals for custom repository/config
locations. They will need to be passed to `daemon` command too, when used. The
repository folder contains chain/block data, keys, configuration, and other
operational data. This folder is portable and can be relocated as needed. Note
that it can grow significantly as it contains the Lotus state and the chain.

When using Lily against Filecoin Mainnet, we highly recommend
[initializing Lily from a chain snapshot](https://docs.filecoin.io/get-started/lotus/chain/#syncing),
which should be downloaded in advance (same as in Lotus).

---

## Configure

The configuration file is the same configuration file as Lotus, but it also contains additional `Storage` and `Queue` sections that are specific to Lily.

### Notifier & Worker Queue Definitions

Lily may be configured to use Redis as a distributed task queue to distribute work across multiple lily instances. When configured this way the system of lily nodes can consist of multiple `Workers` and a single `Notifier` :

* The `Notifier` puts tasks into a queue for execution by a `Worker`.
* The `Workers` remove tasks from the queue and execute them.
* Tasks are processed concurrently by multiple workers.

The `Notifier` and `Workers` should be enumerated with a unique `[Name]` which will be used as an argument (via `--queue`) when starting a `[watch|walk|fill] notify` or `tipset-worker` job.

An example of the `Queue` section:

```toml
[Queue]
  [Queue.Notifiers]
    [Queue.Notifiers.Notifier1]
      Network = "tcp"
      Addr = "localhost:6379"
      Username = "default"
      PasswordEnv = "LILY_REDIS_PASSWORD"
      DB = 0
      PoolSize = 0
  [Queue.Workers]
    [Queue.Workers.Worker1]
      [Queue.Workers.Worker1.RedisConfig]
        Network = "tcp"
        Addr = "localhost:6379"
        Username = "default"
        PasswordEnv = "LILY_REDIS_PASSWORD"
        DB = 0
        PoolSize = 0
      [Queue.Workers.Worker1.WorkerConfig]
        Concurrency = 1
        LoggerLevel = "debug"
        WatchQueuePriority = 5
        FillQueuePriority = 3
        IndexQueuePriority = 1
        WalkQueuePriority = 1
        StrictPriority = false
        ShutdownTimeout = 30000000000

```

This should be modified to meet your needs.

### Storage definitions

Lily can deliver scraped data to multiple PostgreSQL and File destinations on a per-Task basis. Each destination should be enumerated with a unique `[Name]` which will be used as an argument (via `--storage`) when starting a Task.

An example of the `Storage` section:

```toml
[Storage]
  [Storage.Postgresql]
    [Storage.Postgresql.Name1]
      URL = "postgres://postgres:password@localhost:5432/primarydatabase"
      ApplicationName = "lily"
      SchemaName = "public"
      PoolSize = 20
      AllowUpsert = false
    [Storage.Postgresql.Name2]
      URL = "postgres://postgres:password@localhost:5432/anotherdatabase"
      ApplicationName = "lily"
      SchemaName = "public"
      PoolSize = 10
      AllowUpsert = false
  [Storage.File]
    [Storage.File.CSV]
      Format = "CSV"
      Path = "/tmp"
      OmitHeader = false
      FilePattern = "{table}.csv"
    [Storage.File.CSV2]
      Format = "CSV"
      Path = "/output"
      OmitHeader = false
      FilePattern = "{table}.csv"
```

This should be modified to meet your needs.

### Database schemas

Before starting, you need to ensure that the Postgres backend is correctly initialized with the necessary schema at the correct version.

For this you will need to run the `lily migrate` command with the right options (should match your Storage configuration). For example:

```bash
lily migrate --db="postgres://postgres:password@localhost:5432/postgres?sslmode=disable" --latest --schema lily-analysis --name lily
```

You can additionally verify the version:

```bash
lily migrate --db="postgres://postgres:password@localhost:5432/postgres?sslmode=disable"
```
```
INFO    lily/commands   commands/setup.go:126   Lily version:demo
INFO    lily/commands   commands/migrate.go:114 current database schema is version 1.3, latest is 1.3
INFO    lily/commands   commands/migrate.go:120 database schema is supported by this version of lily
```

---

## Start and Sync

With all the above, the Lily daemon should be ready to launch and start following the chain:

```bash
lily daemon
```

You should wait until Lily is fully synced. As in Lotus, you can track the current status with:

```bash
lily sync status
```

You can interactively wait for the sync to complete with:

```bash
lily sync wait
```

Once Lily is running and fully synced, you can [start launching jobs](operation.md).
