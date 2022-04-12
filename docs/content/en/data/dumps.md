---
title: "Lily data dumps"
description: "The Sentinel team provides data dumps as produced by Lily so that users do not need to re-process the Filecoin chain (a slow process)."
lead: "The Sentinel team provides data dumps as produced by Lily so that users do not need to re-process the Filecoin chain (a slow process). The dumps can be imported into your database or tooling of choice."
toc: true
menu:
  data:
    parent: "data"
    identifier: "dumps"
weight: 20
---

---

## Latest data dump

Dumps are added daily. The following is a snapshot of what is available as of 2022-03-31:

```yaml
Last epoch: 1680348 (2022-03-31 EOD)
Total Size: 1.6TiB
Tables:
  - actor_states
  - actors
  - block_headers
  - block_messages
  - block_parents
  - chain_consensus
  - chain_economics
  - chain_powers
  - chain_rewards
  - derived_gas_outputs
  - drand_block_entries
  - id_addresses
  - internal_messages
  - internal_parsed_messages
  - market_deal_proposals
  - market_deal_states
  - message_gas_economy
  - messages
  - miner_current_deadline_infos
  - miner_fee_debts
  - miner_infos
  - miner_locked_funds
  - miner_pre_commit_infos
  - miner_sector_deals
  - miner_sector_events
  - miner_sector_infos
  - miner_sector_posts
  - multisig_approvals
  - multisig_transactions
  - parsed_messages
  - power_actor_claims
  - receipts
  - verified_registry_verified_clients
  - verified_registry_verifiers
Networks:
  - mainnet
  - calibnet
```

## S3 bucket

Full archives of filecoin network data are available at the following bucket (**requester pays**):

`https://fil-archive.s3.us-east-2.amazonaws.com`

The data is partitioned into separate **tables** defined by the [Lily schema](https://github.com/filecoin-project/lily/tree/master/schemas).
Archive files for each table are produced daily, covering a 24 hour period from midnight UTC. 
Production will be delayed until at least one finality (900 epochs) after the end of the period. 
Normally extraction starts at 07:30 UTC and may take up to 24 hours to complete and be shipped to the S3 bucket. 
Currently archive files are available as CSV compressed using gzip.

Archive files are organised in a directory hierarchy following the pattern `network/format/schema/table/year`

 - Top level is the network name (for example: mainnet)
 - Second level is the format of the data (for example: csv)
 - Third level is the major schema version number being used for the extract (for example: 1)
 - Fourth level is the name of table (for example: messages)
 - Fifth level is the four digit year (for example: 2021)

File names in each directory use following pattern: `table-year-month-day.format.compression`

Example of file in directory hierarchy: 

`https://fil-archive.s3.us-east-2.amazonaws.com/mainnet/csv/1/messages/2021/messages-2021-08-02.csv.gz`

An import script to import from S3 into TimescaleDB is available in the same
bucket: 

`https://fil-archive.s3.us-east-2.amazonaws.com/import_from_fil_archive.sh`


Header files providing column names for each table are in each table's folder. For example:

`https://fil-archive.s3.us-east-2.amazonaws.com/mainnet/csv/1/messages/messages.header`

For help converting between epochs and date, see the import script linked above.

The data layout can be previewed with the AWS CLI:

```sh 
aws s3 ls "s3://fil-archive/" # See items root folder
aws s3 ls "s3://fil-archive/mainnet/csv/1/" # See tables available for schema version 1
aws s3 ls "s3://fil-archive/mainnet/csv/1/messages/2022/" # List CSV files for messages table in 2022.
```
