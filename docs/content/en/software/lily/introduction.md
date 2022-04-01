---
title: "Lily"
linkTitle: "Introduction"
description: "Lily, is a wrapped Lotus node designed specifically for indexing the Filecoin blockchain."
lead: "Lily, is a wrapped Lotus node designed specifically for indexing the Filecoin blockchain. Lily includes instrumentation for structured data extraction into a PostgresSQL/TimescaleDB database or CSV dumps for later query and analysis."
toc: true 
menu:
  software:
    parent: "lily"
    identifier: "introduction"
weight: 10
---

[Lily](https://github.com/filecoin-project/lily) is made for users who wish to extract or inspect pieces of the Filecoin chain. A few of the things things that Lily can do:

  * Indexing Blocks, Messages, and Receipts.
  * Deriving a view of on-chain Consensus.
  * Extracting miner sectors life-cycle events: Pre-Commit Add, Sector Add, Extend, Fault, Recovering, Recovered, Expiration, and Termination.
  * Collecting Internal message sends not appearing on chain. For example, Multisig actor sends, Cron Event Ticks, Block and Reward Messages.
  * etc. For a full list of data extracted by Lily see the [models](models.md).
