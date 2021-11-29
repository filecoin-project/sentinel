# Sentinel Lily data dumps

The Sentinel team provides data dumps as produced by Lily so that users do not
need to re-process the Filecoin chain (a slow process).

The dumps can be imported into your database or tooling of choice.

* [Information and tables included in the latest data dump](#latest-data-dump)
* Download:
  * [S3 Bucket (CSV)](#s3-bucket)
  * IPFS (TBD)


## Latest data dump

```yaml
Last epoch: 1235759 (2021-10-27 EOD)
Total Size: 14.5TiB
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
```

## S3 bucket

CSV data dumps are available at the following bucket (**requester pays**):

`https://lily-data.s3.us-east-2.amazonaws.com`

Import script to import from S3 into TimescaleDB is available in the same
bucket: https://lily-data.s3.us-east-2.amazonaws.com/import_from_s3.sh.

Header files providing column names for each table are in the root folder. The
CSV data dumps are organized by epoch intervals inside folders the form
`data/<start_epoch>__<end_epoch>/`. For help converting between epochs and
date, see the import script linked above.

Data layout can be previewed with the AWS CLI:

```sh 
aws s3 ls "s3://lily-data/" # See items root folder
aws s3 ls "s3://lily-data/data/1051440__1054319/" # List CSV files for available tables.
```
