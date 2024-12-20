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

The following is a snapshot of what is available as of 2023-01-06:

```yaml
Last epoch: 2456879 (2022-12-25 EOD)
Total Size: 2.4TiB
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
```

```yaml
Last epoch: 1160759 (2022-07-26 EOD)
Total Size: 9.7GiB
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
```

## GCP BigQuery

We now offer the BigQuery public dataset: `lily-data.lily`.

To be able to search for `lily-data.lily` in BigQuery, you need:

1. Make sure that billing is enabled for your Google Cloud project.
2. Have `roles/bigquery.jobUser` permission.
3. In the BigQuery Explorer pane, use the search bar: `Search BigQuery resources` to find dataset `lily-data.lily` .

For more Google BigQuery public dataset information, visit https://cloud.google.com/bigquery/public-data.

### Pricing
1. check the pricing in bigquery: https://cloud.google.com/bigquery/pricing

### Trouble Shooting
1. If you can not find the dataset in Bigquery console, set the location to `us-east4` in the query setting.
   1. Find the *More* icon <br></br> <img width="600" alt="bigquery_tutorial_4" src="https://github.com/user-attachments/assets/c89049f2-b45e-47a4-bfcd-3ef2933f7731" />
   2. Click the *Query setting* <br></br> <img width="600" alt="bigquery_tutorial_5" src="https://github.com/user-attachments/assets/1b0e7145-5921-458b-aea7-624a1473c050" />

   3. Set the *Location type* in *Advanced options* <br></br> <img width="600" alt="bigquery_tutorial_6" src="https://github.com/user-attachments/assets/f21ae82e-6c39-4bea-a7a8-27365ca25dfe" />
   4. Run the SQL <br></br> <img width="600" alt="bigquery_tutorial_7" src="https://github.com/user-attachments/assets/5229da9b-2bf0-461d-85d9-6bd8cef49d2a" />

