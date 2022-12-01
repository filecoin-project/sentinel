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
- Supported Epochs: 1 - ∞

| Column | Description                                         |
| ------ |-----------------------------------------------------|
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
- Supported Epochs: 1 - ∞

| Column     | Description                                               |
| ---------- |-----------------------------------------------------------|
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
- Supported Epochs: 2383680 - ∞

| Column     | Description                                                                                    |
| ---------- |------------------------------------------------------------------------------------------------|
| height     | Epoch when this actors balances map was modified.                                              |
| state_root | StateRoot when this actor balances map was modified.                                           |
| address | Address of the actor whose balance was created or modified.                                    |
| data_cap | Datacap of the actor with `address` after it was created or modified.                          |       
| event | Event identifiying how an actors balance was modified. (One of: `ADDED`, `REMOVED`,`MODIFIED`) |

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
- Task Name: `actor`
- Supported Epochs: 1 - ∞

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this address mapping was added.               |
| id         | ID of the actor.                                             |
| address    | Robust address of the actor.                                 |
| state_root | CID of the parent state root at which this address mapping was added. |


## Storage Market Actor

### market_deal_proposals

Changes to the [Storage Market Actors](https://spec.filecoin.io/#section-systems.filecoin_markets.onchain_storage_market.storage_market_actor) Proposals array.
- Task Name: `market_deal_proposal`
- Supported Epochs: 1 - ∞

| Column                  | Description                                                                                                                                                              |
| ----------------------- |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| height                  | Epoch at which this deal proposal was added or modified.                                                                                                                 |
| state_root              | StateRoot at which this deal proposal was added or modified.                                                                                                             |
| deal_id                 | Identifier for the deal.                                                                                                                                                 |
| piece_cid               | CID of a sector piece. A Piece is an object that represents a whole or part of a File.                                                                                   |
| padded_piece_size       | The piece size in bytes with padding.                                                                                                                                    |
| unpadded_piece_size     | The piece size in bytes without padding.                                                                                                                                 |
| is_verified             | Deal is with a verified provider.                                                                                                                                        |
| client_id               | Address of the actor proposing the deal.                                                                                                                                 |
| provider_id             | Address of the actor providing the services.                                                                                                                             |
| start_epoch             | The nominal epoch at which this deal starts.                                                                                                                             |
| end_epoch               | The epoch at which this deal with end.                                                                                                                                   |
| slashed_epoch           | The epoch at which this deal was slashed or null.                                                                                                                        |
| storage_price_per_epoch | The amount of FIL (in attoFIL) that will be transferred from the client to the provider every epoch this deal is active for.                                             |
| provider_collateral     | The amount of FIL (in attoFIL) the provider has pledged as collateral. The Provider deal collateral is only slashed when a sector is terminated before the deal expires. |
| client_collateral       | The amount of FIL (in attoFIL) the client has pledged as collateral.                                                                                                     |
| label                   | An arbitrary client chosen label to apply to the deal.                                                                                                                   |

### market_deal_states

All storage deal state transitions detected on-chain.

| Column             | Description                                                  |
| ------------------ | ------------------------------------------------------------ |
| height             | Epoch at which this deal was added or changed.               |
| deal_id            | Identifier for the deal.                                     |
| sector_start_epoch | Epoch this deal was included in a proven sector. -1 if not yet included in proven sector. |
| last_update_epoch  | Epoch this deal was last updated at. -1 if deal state never updated. |
| slash_epoch        | Epoch this deal was slashed at. -1 if deal was never slashed. |
| state_root         | CID of the parent state root for this deal.                  |

## Miner Actor

### miner_current_deadline_infos

Deadline refers to the window during which proofs may be submitted.

| Column         | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| height         | Epoch at which this info was calculated.                     |
| miner_id       | Address of the miner this info relates to.                   |
| state_root     | CID of the parent state root at this epoch.                  |
| deadline_index | A deadline index, in [0..d.WPoStProvingPeriodDeadlines) unless period elapsed. |
| period_start   | First epoch of the proving period (<= CurrentEpoch).         |
| open           | First epoch from which a proof may be submitted (>= CurrentEpoch). |
| close          | First epoch from which a proof may no longer be submitted (>= Open). |
| challenge      | Epoch at which to sample the chain for challenge (< Open).   |
| fault_cutoff   | First epoch at which a fault declaration is rejected (< Open). |

### miner_fee_debts

Miner debts per epoch from unpaid fees.

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this debt applies.                            |
| miner_id   | Address of the miner that owes fees.                         |
| state_root | CID of the parent state root at this epoch.                  |
| fee_debt   | Absolute value of debt this miner owes from unpaid fees in attoFIL. |

### miner_infos

Miner Account IDs for all associated addresses plus peer ID. See https://docs.filecoin.io/min
e/lotus/miner-addresses/ for more information.

| Column                    | Description                                                  |
| ------------------------- | ------------------------------------------------------------ |
| height                    | Epoch at which this miner info was added/changed.            |
| miner_id                  | Address of miner this info applies to.                       |
| state_root                | CID of the parent state root at this epoch.                  |
| owner_id                  | Address of actor designated as the owner. The owner address is the address that created the miner, paid the collateral, and has block rewards paid out to it. |
| worker_id                 | Address of actor designated as the worker. The worker is responsible for doing all of the work, submitting proofs, committing new sectors, and all other day to day activities. |
| new_worker                | Address of a new worker address that will become effective at worker_change_epoch. |
| worker_change_epoch       | Epoch at which a new_worker address will become effective.   |
| consensus_faulted_elapsed | The next epoch this miner is eligible for certain permissioned actor methods and winning block elections as a result of being reported for a consensus fault. |
| peer_id                   | Current libp2p Peer ID of the miner.                         |
| control_address           | JSON array of control addresses. Control addresses are used to submit WindowPoSts proofs to the chain. WindowPoSt is the mechanism through which storage is verified in Filecoin and is required by miners to submit proofs for all sectors every 24 hours. Those proofs are submitted as messages to the blockchain and therefore need to pay the respective fees. |
| multi_address             | JSON array of multiaddrs at which this miner can be reached. |
| sector_size               | The sector size used by this miner.                          |

### miner_locked_funds

Details of Miner funds locked and unavailable for use.

| Column              | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| height              | Epoch at which these details were added/changed.             |
| miner_id            | Address of the miner these details apply to.                 |
| state_root          | CID of the parent state root at this epoch.                  |
| locked_funds        | Amount of FIL (in attoFIL) locked due to vesting. When a Miner receives tokens from block rewards, the tokens are locked and added to the Miner's vesting table to be unlocked linearly over some future epochs. |
| initial_pledge      | Amount of FIL (in attoFIL) locked due to it being pledged as collateral. When a Miner ProveCommits a Sector, they must supply an "initial pledge" for the Sector, which acts as collateral. If the Sector is terminated, this deposit is removed and burned along with rewards earned by this sector up to a limit. |
| pre_commit_deposits | Amount of FIL (in attoFIL) locked due to it being used as a PreCommit deposit. When a Miner PreCommits a Sector, they must supply a "precommit deposit" for the Sector, which acts as collateral. If the Sector is not ProveCommitted on time, this deposit is removed and burned. |

### miner_pre_commit_infos

Information on sector PreCommits states.

| Column                   | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| height                   | Epoch this PreCommit information was added/changed.          |
| miner_id                 | Address of the miner who owns the sector.                    |
| sector_id                | Numeric identifier for the sector.                           |
| state_root               | CID of the parent state root at this epoch.                  |
| sealed_cid               | CID of the sealed sector.                                    |
| seal_rand_epoch          | Seal challenge epoch. Epoch at which randomness should be drawn to tie Proof-of-Replication to a chain. |
| expiration_epoch         | Epoch this sector expires.                                   |
| pre_commit_deposit       | Amount of FIL (in attoFIL) used as a PreCommit deposit. If the Sector is not ProveCommitted on time, this deposit is removed and burned. |
| pre_commit_epoch         | Epoch this PreCommit was created.                            |
| deal_weight              | Total space*time of submitted deals.                         |
| verified_deal_weight     | Total space*time of submitted verified deals.                |
| is_replace_capacity      | Whether to replace a "committed capacity" no-deal sector (requires non-empty DealIDs). |
| replace_sector_deadline  | The deadline location of the sector to replace.              |
| replace_sector_partition | The partition location of the sector to replace.             |
| replace_sector_number    | ID of the committed capacity sector to replace.              |

### miner_sector_deals

Mapping of Deal IDs to their respective Miner and Sector IDs.

| Column    | Description                                       |
| --------- | ------------------------------------------------- |
| height    | Epoch at which this deal was added/updated.       |
| miner_id  | Address of the miner the deal is with.            |
| sector_id | Numeric identifier of the sector the deal is for. |
| deal_id   | Numeric identifier for the deal.                  |

### miner_sector_events

Sector events on-chain per Miner/Sector. One of

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this event occurred.                          |
| miner_id   | Address of the miner who owns the sector.                    |
| sector_id  | Numeric identifier of the sector.                            |
| state_root | CID of the parent state root at this epoch.                  |
| event      | Name of the event that occurred: PRECOMMIT_ADDED, PRECOMMIT_EXPIRED, COMMIT_CAPACITY_ADDED, SECTOR_ADDED, SECTOR_EXTENDED, SECTOR_FAULTED, SECTOR_FAULTED, SECTOR_SNAPPED, SECTOR_RECOVERING, SECTOR_RECOVERED, SECTOR_EXPIRED, or SECTOR_TERMINATED. |

### miner_sector_infos

Latest state of sectors by Miner.

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

| Column           | Description                                    |
| ---------------- | ---------------------------------------------- |
| height           | Epoch at which this PoSt message was executed. |
| miner_id         | Address of the miner who owns the sector.      |
| sector_id        | Numeric identifier of the sector.              |
| post_message_cid | CID of the PoSt message.                       |

## Multisig Actor

### multisig_approvals

Message Transactions approved by Multsig Actors.

| Column         | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| height         | Epoch at which this transaction was executed.                |
| multisig_id    | Address of the multisig actor involved in the transaction.   |
| state_root     | CID of the parent state root at this epoch.                  |
| transaction_id | Number identifier for the transaction - unique per multisig. |
| to             | Address of the recipient who will be sent a message if the proposal is approved. |
| value          | Amount of FIL (in attoFIL) that will be transferred if the proposal is approved. |
| method         | The method number to invoke on the recipient if the proposal is approved. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution. |

### multisig_transactions

Details of pending transactions involving multisig actors.

| Column         | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| height         | Epoch at which this transaction was executed.                |
| multisig_id    | Address of the multisig actor involved in the transaction.   |
| state_root     | CID of the parent state root at this epoch.                  |
| transaction_id | Number identifier for the transaction - unique per multisig. |
| to             | Address of the recipient who will be sent a message if the proposal is approved. |
| value          | Amount of FIL (in attoFIL) that will be transferred if the proposal is approved. |
| method         | The method number to invoke on the recipient if the proposal is approved. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution. |
| params         | CBOR encoded bytes of parameters to send to the method that will be invoked if the proposal is approved. |
| approved       | Addresses of signers who have approved the transaction. 0th entry is the proposer. |

## Power Actor

### chain_powers

Power summaries from the Power actor.

| Column                        | Description                                                  |
| ----------------------------- | ------------------------------------------------------------ |
| height                        | Epoch this power summary applies to.                         |
| state_root                    | CID of the parent state root.                                |
| total_raw_bytes_power         | Total storage power in bytes in the network. Raw byte power is the size of a sector in bytes. |
| total_raw_bytes_committed     | Total provably committed storage power in bytes. Raw byte power is the size of a sector in bytes. |
| total_qa_bytes_power          | Total quality adjusted storage power in bytes in the network. Quality adjusted power is a weighted average of the quality of its space and it is based on the size, duration and quality of its deals. |
| total_qa_bytes_committed      | Total provably committed, quality adjusted storage power in bytes. Quality adjusted power is a weighted average of the quality of its space and it is based on the size, duration and quality of its deals. |
| total_pledge_collateral       | Total locked FIL (attoFIL) miners have pledged as collateral in order to participate in the economy. |
| qa_smoothed_position_estimate | Total power smoothed position estimate - Alpha Beta Filter "position" (value) estimate in Q.128 format. |
| qa_smoothed_velocity_estimate | Total power smoothed velocity estimate - Alpha Beta Filter "velocity" (rate of change of value) estimate in Q.128 format. |
| miner_count                   | Total number of miners.                                      |
| participating_miner_count     | Total number of miners with power above the minimum miner threshold. |

### power_actor_claims

Changes in the [Storage Power Actors](https://spec.filecoin.io/#section-systems.filecoin_blockchain.storage_power_consensus.storage_power_actor) Claims map.

| Column            | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| height            | Epoch this claim was made.                                   |
| state_root        | CID of the parent state root at this epoch.                  |
| miner_id          | Address of miner making the claim.                           |
| raw_byte_power    | Sum of [raw byte power](https://spec.filecoin.io/#section-glossary.raw-byte-power) for a miner's sectors. Raw byte power is the size of a sector in bytes. |
| quality_adj_power | Sum of [quality adjusted power](https://spec.filecoin.io/#section-glossary.raw-byte-power) for a miner's sectors. Quality adjusted power measures the consensus power of stored data on the network, and is equal to [Raw Byte Power](https://spec.filecoin.io/#section-glossary.raw-byte-power) multiplied by [Sector Quality Multiplier](https://spec.filecoin.io/#section-glossary.sector-quality-multiplier) |


## Reward Actor

### chain_rewards

Reward summaries from the Reward actor.

| Column                                | Description                                                  |
| ------------------------------------- | ------------------------------------------------------------ |
| height                                | Epoch this rewards summary applies to.                       |
| state_root                            | CID of the parent state root.                                |
| cum_sum_baseline                      | Target that CumsumRealized needs to reach for EffectiveNetworkTime to increase. It is measured in byte-epochs (space * time) representing power committed to the network for some duration. |
| cum_sum_realized                      | Cumulative sum of network power capped by BaselinePower(epoch). It is measured in byte-epochs (space * time) representing power committed to the network for some duration. |
| effective_baseline_power              | The baseline power (in bytes) at the EffectiveNetworkTime epoch. |
| new_baseline_power                    | The baseline power (in bytes) the network is targeting.      |
| new_reward_smoothed_position_estimate | Smoothed reward position estimate - Alpha Beta Filter "position" (value) estimate in Q.128 format. |
| new_reward_smoothed_velocity_estimate | Smoothed reward velocity estimate - Alpha Beta Filter "velocity" (rate of change of value) estimate in Q.128 format. |
| total_mined_reward                    | The total FIL (attoFIL) awarded to block miners.             |
| new_reward                            | The reward to be paid in per WinCount to block producers. The actual reward total paid out depends on the number of winners in any round. This value is recomputed every non-null epoch and used in the next non-null epoch. |
| effective_network_time                | Ceiling of real effective network time "theta" based on CumsumBaselinePower(theta) == CumsumRealizedPower. Theta captures the notion of how much the network has progressed in its baseline and in advancing network time. |

## Verified Registry Actor

### verified_registry_verified_clients

Changes in the [Verifed Registry Actors](https://spec.filecoin.io/#section-glossary.verified-registry-actor) VerifiedClients map.

##### Supported Epoch Range: 1 - 2383680

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this verified client state changed.           |
| state_root | CID of the parent state root at this epoch.                  |
| address    | Address of verified client this state change applies to.     |
| data_cap   | DataCap of verified client at this state change.             |
| event      | Name of the event that occurred. On of: ADDED, REMOVED, MODIFIED |

### verified_registry_verifiers

Changes in the [Verifed Registry Actors](https://spec.filecoin.io/#section-glossary.verified-registry-actor) Verifiers map.

##### Supported Epoch Range: 1 - ∞

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this verifiers state changed.                 |
| state_root | CID of the parent state root at this epoch.                  |
| address    | Address of verifier this state change applies to.            |
| data_cap   | DataCap of verifier at this state change.                    |
| event      | Name of the event that occurred. On of: ADDED, REMOVED, MODIFIED |

