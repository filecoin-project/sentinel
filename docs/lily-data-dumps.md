# Sentinel Lily data dumps

```yaml
Last epoch: 1085999 (2021-09-05 EOD)
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

If you rely regularly
