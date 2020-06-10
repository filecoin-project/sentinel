# Sentinel

A Filecoin Network Monitoring and Analysis System


## Background

Sentinel is a collection of services which monitor the health and function of the Filecoin network. The system consists of TimescaleDB, a time-series and relational datastore, which captures metrics from interesting parts of the network and is exposed via Grafana, which presents the data via helpful and informative graphs and provides alerting and annotating for real-time monitoring.

The metrics are pushed to TimescaleDB from Telegraf-based remote-host agents and a centralized data processing pipeline. [Lotus](https://github.com/filecoin-project/lotus/) is attached to the processing pipeline as a source of truth for immutable network state.


## Setup

### Build and Start Sentinel

0. Start lotus daemon.
1. `git clone git@github.com:filecoin-project/sentinel.git`
2. `cd sentinel`
3. `make run`

### Configure Grafana Datasource

Note: This process will eventually be automatically provisioned on startup.

4. Visit [http://localhost:3000](http://localhost:3000) to open Grafana.
5. Login with username and password as `admin`. Change the admin password.
6. Follow prompt to setup a PostgreSQL Datasource with the following setttings:

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

7. Click Save and Test.

### Configure Grafana Dashboards

8. Return to Home and follow prompt to add new dashboards. Find the Import option in the top right of the screen.
9. Upload the desired dashboard JSON from the available dashboard payloads found in [grafana/provisioning/dashboards/](https://github.com/filecoin-project/sentinel/tree/master/grafana/provisioning/dashboards).
10. Click Import (or if you already have the dashboard imported with this name, select Overwrite).


## Managing Sentinel

`make` - produces the telegraf agent binary and any docker services which are not prebuilt images

`make telegraf` - only builds the telegraf agent

`make run` - starts the collection agent and related services

`make run-telegraf` - start development Telegraf process with debug output (uses configuration at `build/telegraf.conf`)

`make run-services` - start all docker services (currently TimescaleDB, Grafana)

`make stop` - stops the collection agent and related services

`make stop-telegraf` - stop development Telegraf process

`make stop-services` - stop all docker services

`make clean` - removes build artifacts

`make clean-state` - stops and destroys docker service volumes (which resets TimescaleDB and Grafana settings and configuration)


## Maintainers

- [@placer14](https://github.com/placer14)


## Code of Conduct

Sentinel follows the [Filecoin Project Code of Conduct](https://github.com/filecoin-project/community/blob/master/CODE_OF_CONDUCT.md). Before contributing, please acquaint yourself with our social courtesies and expectations.


## Contributing

Welcoming [new issues](https://github.com/filecoin-project/sentinel/issues/new) and [pull requests](https://github.com/filecoin-project/sentinel/pulls).


## License

The Filecoin Project and Sentinel is dual-licensed under Apache 2.0 and MIT terms:

- Apache License, Version 2.0, ([LICENSE-APACHE](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-MIT) or http://opensource.org/licenses/MIT)
