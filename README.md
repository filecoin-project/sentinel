# Sentinel

The Sentinel Team provides Filecoin chain monitoring and analysis tools.

## Projects
- [Lily](https://lilium.sh/software/lily/introduction/): Performs chain data extraction and indexing, exporting to TimescaleDB or CSV.
- [Sentinel-tick](https://github.com/filecoin-project/sentinel-tick): Collects Filecoin pricing and volume information from exchanges and inserts it into Postgres/Timescale DB.
- [Sentinel-locations](https://github.com/filecoin-project/sentinel-locations): Uses Lily-extracted miner data to create a table mapping miner_ids to geographical locations.
- [Filcryo](https://github.com/filecoin-project/filcryo): Create archival-grade snapshots as used by the Sentinel/Data Engineering Team at Protocol Labs for further processing.

## Data
- BigQuery dataset: [protocol-labs-data.lily](console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1sprotocol-labs-data!2slily)
- Batch dump data: gs://fil-mainnet-archive
- Daily archival snapshots: gs://fil-mainnet-archival-snapshots

## Communications
- [Filecoin slack](https://filecoin.io/slack)
    - team channel: [#fil-sentinel](https://filecoinproject.slack.com/archives/C0174P5M11T)
    - group mention: `@sentinel-team`
- [Request for collaboration](https://github.com/filecoin-project/sentinel/blob/master/REQUEST.md)

## Documentation and support

Visit https://lilium.sh for the latest documentation on the software.

- For questions and support, we are available in the `#fil-sentinel` on Filecoin's slack (https://filecoin.io/slack/).

To build the documentation site locally, you need:
- [Hugo](https://gohugo.io/getting-started/installing/), `>=v0.9.0`.
- [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm), `>=v8.5.0`

To run the Hugo server locally:

```
$ cd docs
$ npm install
$ hugo server
```

## Code of Conduct

Sentinel follows the [Filecoin Project Code of Conduct](https://github.com/filecoin-project/community/blob/master/CODE_OF_CONDUCT.md). Before contributing, please acquaint yourself with our social courtesies and expectations.


## License

The Filecoin Project and Sentinel projects are dual-licensed under Apache 2.0 and MIT terms:

- Apache License, Version 2.0, ([LICENSE-APACHE](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-MIT) or http://opensource.org/licenses/MIT)
