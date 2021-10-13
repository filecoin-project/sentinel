# Sentinel Lily documentation

[Lily](https://github.com/filecoin-project/lily), is a wrapped
[Lotus](https://github.com/filecoin-project/lotus) node designed specifically
for indexing the Filecoin blockchain. Lily includes instrumentation for
structured data extraction into a PostgresSQL/TimescaleDB database or CSV
dumps for later query and analysis.

Lily is made for users who wish to extract or inspect pieces of the Filecoin chain. A few of the things things that Lily can do:

  * Indexing Blocks, Messages, and Receipts.
  * Deriving a view of on-chain Consensus.
  * Extracting miner sectors life-cycle events: Pre-Commit Add, Sector Add, Extend, Fault, Recovering, Recovered, Expiration, and Termination.
  * Collecting Internal message sends not appearing on chain. For example, Multisig actor sends, Cron Event Ticks, Block and Reward Messages.
  * etc. For a full list of data extracted by Lily see the [models](models.md).

You can find all the information about how to run and operate Lily in the following guides:

  * [Setup: Build, install, initialize and sync](setup.md)
  * [Operation: Jobs, Watches, Walks, Tasks and Gap-filling](operation.md)
  * [Hardware requirements](hardware.md)
  * [Deployment: using `docker-compose` (testing, non-mainnet networks)](deployment-docker.md)
  * [Deployment: using Helm/Kubernetes (production)](deployment-k8s.md)
  * [Data models: tables, columns and descriptions](models.md)
  * [Data dumps download](data-dumps.md)
