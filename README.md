# Sentinel

The Sentinel Team provides Filecoin chain monitoring and analysis tools.

## Projects

### Lily (former sentinel-visor)

Performs chain data extraction and indexing, exporting to TimescaleDB or CSV.

URL: https://lilium.sh/software/lily/introduction/

### Sentinel-drone

Provides a bridge between prometheus metrics exported by Lotus and Postgres/Timescale DB.

URL: https://github.com/filecoin-project/sentinel-drone


### Sentinel-tick

Collects Filecoin pricing and volume information from exchanges and inserts it into Postgres/Timescale DB.

URL: https://github.com/filecoin-project/sentinel-tick

### Sentinel-locations

Uses Lily-extracted miner data to create a table mapping miner_ids to geographical locations.

URL: https://github.com/filecoin-project/sentinel-locations

## Documentation and support

Visit https://lilium.sh for the latest documentation on the software.

For questions and support, we are available in the `#fil-sentinel` on Filecoin's slack (https://filecoin.io/slack/).

## Code of Conduct

Sentinel follows the [Filecoin Project Code of Conduct](https://github.com/filecoin-project/community/blob/master/CODE_OF_CONDUCT.md). Before contributing, please acquaint yourself with our social courtesies and expectations.


## License

The Filecoin Project and Sentinel projects are dual-licensed under Apache 2.0 and MIT terms:

- Apache License, Version 2.0, ([LICENSE-APACHE](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](https://github.com/filecoin-project/sentinel/blob/master/LICENSE-MIT) or http://opensource.org/licenses/MIT)
