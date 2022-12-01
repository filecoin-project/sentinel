---
title: "Actor Models"
description: "Lily relational data is formatted per the Lily data models."
lead: "Lily relational data format is defined according to the following models, each corresponding to a table."
menu:
  data:
    parent: "data"
    identifier: "actor models"
weight: 10
toc: true

---

---

## Raw Actor States

### actor_states
Actor states that were changed at an epoch. Associates actors states as single-level trees with CIDs pointing to complete state tree with the root CID (head) for that actor's state.
- Task Name: `actor_state`
- Supported Epochs: [1 - ∞)

| Column | Description                                         |
|--------|-----------------------------------------------------|
| height | Epoch when this actor was created or updated.       |
| head   | CID of the root of the state tree for the actor.    |
| code   | CID identifier for the type of the actor.           |
| state  | Top level of state data erialized as a JSON object. |

<details>
<summary>Model Schema</summary>

```postgresql
create table actor_states
(
  height bigint not null,
  head   text   not null,
  code   text   not null,
  state  jsonb  not null,
  primary key (height, head, code)
);
```
</details>

### actors
Actors on chain that were added or updated at an epoch. Associates the actor's state root CID (head) with the chain state root CID for which it changed.
- Task Name: `actor`
- Supported Epochs: [1 - ∞)

| Column     | Description                                               |
|------------|-----------------------------------------------------------|
| height     | Epoch when this actor was created or updated.             |
| state_root | StateRoot when this actor was created or updated.         |
| id         | Actor address.                                            |
| code       | Human readable identifier for the type of the actor.      |
| head       | CID of the root of the state tree for the actor.          |
| nonce      | The next actor nonce that is expected to appear on chain. |
| balance    | Actor balance in attoFIL.                                 |

<details>
<summary>Model Schema</summary>

```postgresql
create table actors
(
  height     bigint not null,
  id         text   not null,
  code       text   not null,
  head       text   not null,
  nonce      bigint not null,
  balance    text   not null,
  state_root text   not null,
  primary key (height, id, state_root)
);
```
</details>

## Datacap Actor

### data_cap_balances
Changes in the Datacap Actors Balances map.
- Task Name: `data_cap_balance`
- Supported Epochs: [2383680 - ∞)

| Column     | Description                                                                                    |
|------------|------------------------------------------------------------------------------------------------|
| height     | Epoch when this actors balances map was modified.                                              |
| state_root | StateRoot when this actor balances map was modified.                                           |
| address    | Address of the actor whose balance was created or modified.                                    |
| data_cap   | Datacap of the actor with `address` after it was created or modified.                          |       
| event      | Event identifiying how an actors balance was modified. (One of: `ADDED`, `REMOVED`,`MODIFIED`) |

<details>
<summary>Model Schema</summary>

```postgresql
create table data_cap_balances
(
  height     bigint                      not null,
  state_root text                        not null,
  address    text                        not null,
  data_cap   numeric                     not null,
  event      data_cap_balance_event_type not null,
  primary key (height, state_root, address)
);
create type data_cap_balance_event_type as enum ('ADDED', 'REMOVED', 'MODIFIED');
```
</details>

## Init Actor

### id_addresses
Mapping of IDs to robust addresses from the init actor's state.
- Task Name: `id_addresses`
- Supported Epochs: [1 - ∞)

| Column     | Description                                                           |
|------------|-----------------------------------------------------------------------|
| height     | Epoch at which this address mapping was added.                        |
| id         | ID of the actor.                                                      |
| address    | Robust address of the actor.                                          |
| state_root | CID of the parent state root at which this address mapping was added. |


## Storage Market Actor

### market_deal_proposals
Changes to the [Storage Market Actors](https://spec.filecoin.io/#section-systems.filecoin_markets.onchain_storage_market.storage_market_actor) Deal Proposals array.
- Task Name: `market_deal_proposal`
- Supported Epochs: [1 - ∞)

| Column                  | Description                                                                                                                  |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------|
| height                  | Epoch at which this deal proposal was added or modified.                                                                     |
| state_root              | StateRoot at which this deal proposal was added or modified.                                                                 |
| deal_id                 | Identifier for the deal.                                                                                                     |
| piece_cid               | CID of a sector piece. A Piece is an object that represents a whole or part of a File.                                       |
| padded_piece_size       | The piece size in bytes with padding.                                                                                        |
| unpadded_piece_size     | The piece size in bytes without padding.                                                                                     |
| is_verified             | Deal is with a verified provider.                                                                                            |
| client_id               | Address of the actor proposing the deal.                                                                                     |
| provider_id             | Address of the actor providing the services.                                                                                 |
| start_epoch             | The nominal epoch at which this deal starts.                                                                                 |
| end_epoch               | The epoch at which this deal with end.                                                                                       |
| slashed_epoch           | The epoch at which this deal was slashed or null.                                                                            |
| storage_price_per_epoch | The amount of FIL (in attoFIL) that will be transferred from the client to the provider every epoch this deal is active for. |
| provider_collateral     | The amount of FIL (in attoFIL) the provider has pledged as collateral.                                                       |
| client_collateral       | The amount of FIL (in attoFIL) the client has pledged as collateral.                                                         |
| label                   | An arbitrary client chosen label to apply to the deal.                                                                       |

### market_deal_states
Changes to the [Storage Market Actors](https://spec.filecoin.io/#section-systems.filecoin_markets.onchain_storage_market.storage_market_actor) Deal States array.
- Task Name: `market_deal_state`
- Supported Epochs: [1 - ∞)

| Column             | Description                                                                               |
|--------------------|-------------------------------------------------------------------------------------------|
| height             | Epoch at which this deal was added or modified.                                           |
| state_root         | StateRoot at which this deal state was added or modified.                                 |
| deal_id            | Identifier for the deal.                                                                  |
| sector_start_epoch | Epoch this deal was included in a proven sector. -1 if not yet included in proven sector. |
| last_update_epoch  | Epoch this deal was last updated at. -1 if deal state never updated.                      |
| slash_epoch        | Epoch this deal was slashed at. -1 if deal was never slashed.                             |

## Storage Miner Actor

### miner_current_deadline_infos
Deadline refers to the window during which proofs may be submitted.
- Task Name: `miner_current_deadline_info`
- Supported Epochs: [1 - ∞)

| Column         | Description                                                                    |
|----------------|--------------------------------------------------------------------------------|
| height         | Epoch at which this info was calculated.                                       |
| state_root     | StateRoot at which this info was calculated.                                   |
| miner_id       | Address of the miner this info relates to.                                     |
| deadline_index | A deadline index, in [0..d.WPoStProvingPeriodDeadlines) unless period elapsed. |
| period_start   | First epoch of the proving period (<= CurrentEpoch).                           |
| open           | First epoch from which a proof may be submitted (>= CurrentEpoch).             |
| close          | First epoch from which a proof may no longer be submitted (>= Open).           |
| challenge      | Epoch at which to sample the chain for challenge (< Open).                     |
| fault_cutoff   | First epoch at which a fault declaration is rejected (< Open).                 |

### miner_fee_debts
Miner debts per epoch from unpaid fees.
- Task Name: `miner_fee_debt`
- Supported Epochs: [1 - ∞)

| Column     | Description                                                         |
|------------|---------------------------------------------------------------------|
| height     | Epoch at which this debt applies.                                   |
| state_root | StateRoot at which this debt applied.                               |
| miner_id   | Address of the miner that owes fees.                                |
| fee_debt   | Absolute value of debt this miner owes from unpaid fees in attoFIL. |

### miner_infos
Information not related to sectors extracted from the storage miners Info structure.
- Task Name: `miner_info`
- Supported Epochs: [1 - ∞)

| Column                    | Description                                                                                                                                                   |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| height                    | Epoch at which this miner info was added/modified.                                                                                                            |
| state_root                | StateRoot at which this miner info was added/modified.                                                                                                        |
| miner_id                  | Address of miner this info applies to.                                                                                                                        |
| owner_id                  | Address of actor designated as the owner.                                                                                                                     | 
| worker_id                 | Address of actor designated as the worker.                                                                                                                    |
| new_worker                | Address of a new worker address that will become effective at worker_change_epoch.                                                                            |
| worker_change_epoch       | Epoch at which a new_worker address will become effective.                                                                                                    |
| consensus_faulted_elapsed | The next epoch this miner is eligible for certain permissioned actor methods and winning block elections as a result of being reported for a consensus fault. |
| peer_id                   | Current libp2p Peer ID of the miner.                                                                                                                          |
| control_address           | JSON array of control addresses.                                                                                                                              |
| multi_address             | JSON array of multiaddrs at which this miner can be reached.                                                                                                  |
| sector_size               | The sector size used by this miner.                                                                                                                           |

### miner_locked_funds
Details of Miner funds.
- Task Name: `miner_locked_fund`
- Supported Epochs: [1 - ∞)

| Column              | Description                                                                    |
|---------------------|--------------------------------------------------------------------------------|
| height              | Epoch at which these details were added/modified.                              |
| state_root          | StateRoot at which these details were added/modified.                          |
| miner_id            | Address of the miner these details apply to.                                   | 
| locked_funds        | Amount of FIL (in attoFIL) locked due to vesting.                              | 
| initial_pledge      | Amount of FIL (in attoFIL) locked due to it being pledged as collateral.       | 
| pre_commit_deposits | Amount of FIL (in attoFIL) locked due to it being used as a PreCommit deposit. | 

### miner_pre_commit_infos
Information on sector PreCommits states.
- Task Name: `miner_pre_commit_info`
- Supported Epochs: [1 - 2383680)

| Column                   | Description                                                                            |
|--------------------------|----------------------------------------------------------------------------------------|
| height                   | Epoch this PreCommit information was added/modified.                                   |
| state_root               | StateRoot this PreCommit information was added/modified.                               |
| miner_id                 | Address of the miner who owns the sector.                                              |
| sector_id                | Numeric identifier for the sector.                                                     |
| sealed_cid               | CID of the sealed sector.                                                              |
| seal_rand_epoch          | Seal challenge epoch.                                                                  |
| expiration_epoch         | Epoch this sector expires.                                                             |
| pre_commit_deposit       | Amount of FIL (in attoFIL) used as a PreCommit deposit.                                |
| pre_commit_epoch         | Epoch this PreCommit was created.                                                      |
| deal_weight              | Total space*time of submitted deals.                                                   |
| verified_deal_weight     | Total space*time of submitted verified deals.                                          |
| is_replace_capacity      | Whether to replace a "committed capacity" no-deal sector (requires non-empty DealIDs). |
| replace_sector_deadline  | The deadline location of the sector to replace.                                        |
| replace_sector_partition | The partition location of the sector to replace.                                       |
| replace_sector_number    | ID of the committed capacity sector to replace.                                        |

### miner_pre_commit_infos_v9
Information on sector PreCommits states.
- Task Name: `miner_pre_commit_info`
- Supported Epochs: [2383680 - ∞)

| Column             | Description                                              |
|--------------------|----------------------------------------------------------|
| height             | Epoch this PreCommit information was added/modified.     |
| state_root         | StateRoot this PreCommit information was added/modified. |
| miner_id           | Address of the miner who owns the sector.                |
| sector_id          | Numeric identifier for the sector.                       |
| pre_commit_deposit | Amount of FIL (in attoFIL) used as a PreCommit deposit.  |
| sealed_cid         | CID of the sealed sector.                                |
| seal_rand_epoch    | Seal challenge epoch.                                    |
| expiration_epoch   | Epoch this sector expires.                               |
| deal_ids           | Array of deal IDs contained in this PreCommit.           |
| unsealed_cid       | CID of the unsealed sector.                              |

<details>
<summary>Model Schema</summary>

```postgresql
create table miner_pre_commit_infos_v9
(
  height             bigint  not null,
  state_root         text    not null,
  miner_id           text    not null,
  sector_id          bigint  not null,
  pre_commit_deposit numeric not null,
  pre_commit_epoch   bigint  not null,
  sealed_cid         text    not null,
  seal_rand_epoch    bigint  not null,
  expiration_epoch   bigint  not null,
  deal_ids           bigint[],
  unsealed_cid       text,
  primary key (height, miner_id, sector_id, state_root)
);
```
</details>

### miner_sector_deals
Mapping of Deal IDs to their respective Miner and Sector IDs.
- Task Name: `miner_sector_deal`
- Supported Epochs: [1 - ∞)

| Column    | Description                                       |
|-----------|---------------------------------------------------|
| height    | Epoch at which this deal was added/updated.       |
| miner_id  | Address of the miner the deal is with.            |
| sector_id | Numeric identifier of the sector the deal is for. |
| deal_id   | Numeric identifier for the deal.                  |

### miner_sector_events
Sector events on-chain per Miner/Sector.
- Task Name: `miner_sector_event`
- Supported Epochs: [1 - ∞)

| Column     | Description                                                                                                                                                                                                                                           |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| height     | Epoch at which this event occurred.                                                                                                                                                                                                                   |
| state_root | StateRoot at which this even occurred.                                                                                                                                                                                                                |
| miner_id   | Address of the miner who owns the sector.                                                                                                                                                                                                             |
| sector_id  | Numeric identifier of the sector.                                                                                                                                                                                                                     |
| event      | Name of the event that occurred: PRECOMMIT_ADDED, PRECOMMIT_EXPIRED, COMMIT_CAPACITY_ADDED, SECTOR_ADDED, SECTOR_EXTENDED, SECTOR_FAULTED, SECTOR_FAULTED, SECTOR_SNAPPED, SECTOR_RECOVERING, SECTOR_RECOVERED, SECTOR_EXPIRED, or SECTOR_TERMINATED. |

### miner_sector_infos
Latest state of sectors by Miner.
- Task Name: `miner_sector_event`
- Supported Epochs: [1 - ∞)

| Column                  | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| height                  | Epoch at which this sector info was added/updated.           |
| miner_id                | Address of the miner who owns the sector.                    |
| sector_id               | Numeric identifier of the sector.                            |
| state_root              | CID of the parent state root at this epoch.                  |
| sealed_cid              | The root CID of the Sealed Sector’s merkle tree. Also called CommR, or "replica commitment". |
| activation_epoch        | Epoch during which the sector proof was accepted.            |
| expiration_epoch        | Epoch during which the sector expires.                       |
| deal_weight             | Integral of active deals over sector lifetime.               |
| verified_deal_weight    | Integral of active verified deals over sector lifetime. This is specifically for sectors in [Filecoin Plus](https://plus.fil.org/). |
| initial_pledge          | Pledge collected to commit this sector (in attoFIL).         |
| expected_day_reward     | Expected one day projection of reward for sector computed at activation time (in attoFIL). |
| expected_storage_pledge | Expected twenty day projection of reward for sector computed at activation time (in attoFIL). |

### miner_sector_posts
Proof of Spacetime for sectors.
- Task Name: `miner_sector_post`
- Supported Epochs: [1 - ∞)

| Column           | Description                                    |
|------------------|------------------------------------------------|
| height           | Epoch at which this PoSt message was executed. |
| miner_id         | Address of the miner who owns the sector.      |
| sector_id        | Numeric identifier of the sector.              |
| post_message_cid | CID of the PoSt message.                       |

## Multisig Actor

### multisig_approvals
Message Transactions approved by Multsig Actors.
- Task Name: `multisig_approvals`
- Supported Epochs: [1 - ∞)

| Column         | Description                                                                                                                                                                                              |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| height         | Epoch at which this transaction was executed.                                                                                                                                                            |
| state_root     | StateRoot at which this transaction was executed.                                                                                                                                                        |
| multisig_id    | Address of the multisig actor involved in the transaction.                                                                                                                                               |
| transaction_id | Number identifier for the transaction - unique per multisig.                                                                                                                                             |
| to             | Address of the recipient who will be sent a message if the proposal is approved.                                                                                                                         |
| value          | Amount of FIL (in attoFIL) that will be transferred if the proposal is approved.                                                                                                                         |
| method         | The method number to invoke on the recipient if the proposal is approved. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method execution. |

### multisig_transactions
Details of pending transactions involving multisig actors.
- Task Name: `multisig_transaction`
- Supported Epochs: [1 - ∞)

| Column         | Description                                                                                                                                                                                               |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| height         | Epoch at which this transaction was executed.                                                                                                                                                             |
| state_root     | StateRoot at which this transaction was executed.                                                                                                                                                         |
| multisig_id    | Address of the multisig actor involved in the transaction.                                                                                                                                                |
| transaction_id | Number identifier for the transaction - unique per multisig.                                                                                                                                              |
| to             | Address of the recipient who will be sent a message if the proposal is approved.                                                                                                                          |
| value          | Amount of FIL (in attoFIL) that will be transferred if the proposal is approved.                                                                                                                          |
| method         | The method number to invoke on the recipient if the proposal is approved. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution. |
| params         | CBOR encoded bytes of parameters to send to the method that will be invoked if the proposal is approved.                                                                                                  |
| approved       | Addresses of signers who have approved the transaction. 0th entry is the proposer.                                                                                                                        |

## Power Actor

### chain_powers
Power summaries from the Power actor.
- Task Name: `chain_power`
- Supported Epochs: [1 - ∞)

| Column                        | Description                                                                                          |
|-------------------------------|------------------------------------------------------------------------------------------------------|
| height                        | Epoch this power summary applies to.                                                                 |
| state_root                    | StateRoot this power summary applies to.                                                             |
| total_raw_bytes_power         | Total storage power in bytes in the network.                                                         |
| total_raw_bytes_committed     | Total provably committed storage power in bytes.                                                     |
| total_qa_bytes_power          | Total quality adjusted storage power in bytes in the network.                                        |
| total_qa_bytes_committed      | Total provably committed, quality adjusted storage power in bytes.                                   |
| total_pledge_collateral       | Total locked FIL (attoFIL) miners have pledged as collateral in order to participate in the economy. |
| qa_smoothed_position_estimate | Total power smoothed position estimate.                                                              |
| qa_smoothed_velocity_estimate | Total power smoothed velocity estimate.                                                              |
| miner_count                   | Total number of miners.                                                                              |
| participating_miner_count     | Total number of miners with power above the minimum miner threshold.                                 |

### power_actor_claims
Changes in the [Storage Power Actors](https://spec.filecoin.io/#section-systems.filecoin_blockchain.storage_power_consensus.storage_power_actor) Claims map.
- Task Name: `power_actor_claim`
- Supported Epochs: [1 - ∞)

| Column            | Description                                                                                                                                                                                                                                                                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| height            | Epoch this claim was made.                                                                                                                                                                                                                                                                                                                   |
| state_root        | CID of the parent state root at this epoch.                                                                                                                                                                                                                                                                                                  |
| miner_id          | Address of miner making the claim.                                                                                                                                                                                                                                                                                                           |
| raw_byte_power    | Sum of [raw byte power](https://spec.filecoin.io/#section-glossary.raw-byte-power) for a miner's sectors.                                                                                                                                                                                                                                    |
| quality_adj_power | Sum of [quality adjusted power](https://spec.filecoin.io/#section-glossary.raw-byte-power) for a miner's sectors. Quality adjusted power is measured using [Raw Byte Power](https://spec.filecoin.io/#section-glossary.raw-byte-power) and [Sector Quality Multiplier](https://spec.filecoin.io/#section-glossary.sector-quality-multiplier) |


## Reward Actor

### chain_rewards
Reward summaries from the Reward actor.
- Task Name: `chain_reward`
- Supported Epochs: [1 - ∞)

| Column                                | Description                                                                                                                                                                                                                  |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| height                                | Epoch this rewards summary applies to.                                                                                                                                                                                       |
| state_root                            | CID of the parent state root.                                                                                                                                                                                                |
| cum_sum_baseline                      | Target that CumsumRealized needs to reach for EffectiveNetworkTime to increase. It is measured in byte-epochs (space * time) representing power committed to the network for some duration.                                  |
| cum_sum_realized                      | Cumulative sum of network power capped by BaselinePower(epoch). It is measured in byte-epochs (space * time) representing power committed to the network for some duration.                                                  |
| effective_baseline_power              | The baseline power (in bytes) at the EffectiveNetworkTime epoch.                                                                                                                                                             |
| new_baseline_power                    | The baseline power (in bytes) the network is targeting.                                                                                                                                                                      |
| new_reward_smoothed_position_estimate | Smoothed reward position estimate - Alpha Beta Filter "position" (value) estimate in Q.128 format.                                                                                                                           |
| new_reward_smoothed_velocity_estimate | Smoothed reward velocity estimate - Alpha Beta Filter "velocity" (rate of change of value) estimate in Q.128 format.                                                                                                         |
| total_mined_reward                    | The total FIL (attoFIL) awarded to block miners.                                                                                                                                                                             |
| new_reward                            | The reward to be paid in per WinCount to block producers. The actual reward total paid out depends on the number of winners in any round. This value is recomputed every non-null epoch and used in the next non-null epoch. |
| effective_network_time                | Ceiling of real effective network time "theta" based on CumsumBaselinePower(theta) == CumsumRealizedPower. Theta captures the notion of how much the network has progressed in its baseline and in advancing network time.   |

## Verified Registry Actor

### verified_registry_verified_clients
Changes in the [Verifed Registry Actors](https://spec.filecoin.io/#section-glossary.verified-registry-actor) VerifiedClients map.
- Task Name: `verified_registry_verified_client`
- Supported Epochs: [1 - 2383680) (Note: subsequent epochs are track via the data_cap_balances model)

| Column     | Description                                                      |
|------------|------------------------------------------------------------------|
| height     | Epoch at which this verified client state changed.               |
| state_root | CID of the parent state root at this epoch.                      |
| address    | Address of verified client this state change applies to.         |
| data_cap   | DataCap of verified client at this state change.                 |
| event      | Name of the event that occurred. On of: ADDED, REMOVED, MODIFIED |

### verified_registry_verifiers
Changes in the [Verifed Registry Actors](https://spec.filecoin.io/#section-glossary.verified-registry-actor) Verifiers map.
- Task Name: `verified_registry_verified_client`
- Supported Epochs: [1 - ∞)

| Column     | Description                                                      |
|------------|------------------------------------------------------------------|
| height     | Epoch at which this verifiers state changed.                     |
| state_root | CID of the parent state root at this epoch.                      |
| address    | Address of verifier this state change applies to.                |
| data_cap   | DataCap of verifier at this state change.                        |
| event      | Name of the event that occurred. On of: ADDED, REMOVED, MODIFIED |

