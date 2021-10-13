# Lily Setup

Lily is a Go application which embeds a Lotus node.  Therefore, a lot of the setup process (build, init, sync) resembles that of a Lotus node.

The Lily binary is self-documented and should be used to obtain specific help about flags:

```bash
lily help overview # A high-level description of how Lily works
lily help # List all available subcommands
lily <subcommand> --help # Show help for subcommand and subcommand flags
```

Flags usually have an environment variable equivalent.

This guide is organized in the following sections:

* [Dependencies](#dependencies)
* [Build](#build)
* [Initialize](#initialize)
* [Configure](#configure)
* [Start and Sync](#start-and-sync)

---

## Dependencies

You will need the same dependencies as for Lotus. See the [Lotus installation instructions](https://docs.filecoin.io/get-started/lotus/installation/#software-dependencies) for the installation commands for each distribution.

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
make clean all
```

For Calibration-Net:

```bash
make clean calibnet
```

(Check the Makefile for eventual support for additional networks).

4. Install Lily (optional) 

```bash
cp ./lily /usr/local/bin/lily
```

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

### Storage definitions

The configuration file the [same configuration file as Lotus], but it contains
an additional `Storage` section that is specific to Lily.

Lily can deliver scraped data to multiple PostgreSQL and File destinations on
a per-Task basis. Each destination should be enumerated with a unique `[Name]`
which will be used as an argument (via `--storage`) when starting a Task.

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
