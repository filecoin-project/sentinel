---
title: "Actor Models"
description: "Lily relational data is formatted per the Lily data models."
lead: "Lily relational data format is defined according to the following models, each corresponding to a table. These tables are for builtin actors."
menu:
  data:
    parent: "data"
    identifier: "actors_models"
weight: 10
toc: true

---

---

## Raw Actor States
### actors

Actors on chain that were added or updated at an epoch. Associates the actor's state root CID (head) with the chain state root CID from which it descends. Includes account ID nonce, balance and state data at each state.

- Task: `actor`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column       | Type     | Nullable | Description                                               |
| ------------ | -------- | -------- | --------------------------------------------------------- |
| `id`         | `text`   | NO       | Actor address.                                            |
| `code`       | `text`   | NO       | Human readable identifier for the type of the actor.      |
| `head`       | `text`   | NO       | CID of the root of the state tree for the actor.          |
| `nonce`      | `bigint` | NO       | The next actor nonce that is expected to appear on chain. |
| `balance`    | `text`   | NO       | Actor balance in attoFIL.                                 |
| `state_root` | `text`   | NO       | CID of the state root.                                    |
| `height`     | `bigint` | NO       | Epoch when this actor was created or updated.             |
| `state`      | `jsonb`  | NO       | Top level of state data.                                  |


## DataCap Actor
### data_cap_balance

DataCap on-chain per each DataCap balance state change.

- Task: `data_cap_balance`
- Network Range: [`v17` - `v∞`)
- Epoch Range: [`2383680` - `∞`)

| Column       | Type                              | Nullable | Description                                                                                   |
| ------------ | --------------------------------- | -------- | --------------------------------------------------------------------------------------------- |
| `height`     | `bigint`                          | NO       | Epoch when this actors balances map was modified.                                             |
| `state_root` | `text`                            | NO       | StateRoot when this actor balances map was modified.                                          |
| `address`    | `text`                            | NO       | Address of the actor whose balance was created or modified.                                   |
| `data_cap`   | `numeric`                         | NO       | Datacap (Tokenized StoragePower) of the actor with `address` after it was created or modified.|
| `event`      | `ADDED`, `MODIFIED`, or `REMOVED` | NO       | Event identifying how an actors balance was modified. (One of: `ADDED`, `REMOVED`,`MODIFIED`) |

## Init Actor
### id_addresses

Mapping of IDs to robust addresses from the init actor's state.

- Task: `id_addresses`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column       | Type     | Nullable | Description                                                           |
| ------------ | -------- | -------- | --------------------------------------------------------------------- |
| `height`     | `bigint` | NO       | Epoch at which this address mapping was added.                        |
| `id`         | `text`   | NO       | ID of the actor.                                                      |
| `address`    | `text`   | NO       | Robust address of the actor.                                          |
| `state_root` | `text`   | NO       | CID of the parent state root at which this address mapping was added. |

## Storage Market Actor
### market_deal_proposals

All storage deal states with latest values applied to end_epoch when updates are detected on-chain.

- Task: `market_deal_proposal`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                    | Type      | Nullable | Description                                                                                                                                                              |
| ------------------------- | --------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `deal_id`                 | `bigint`  | NO       | Identifier for the deal.                                                                                                                                                 |
| `state_root`              | `text`    | NO       | CID of the parent state root for this deal.                                                                                                                              |
| `piece_cid`               | `text`    | NO       | CID of a sector piece. A Piece is an object that represents a whole or part of a File.                                                                                   |
| `padded_piece_size`       | `bigint`  | NO       | The piece size in bytes with padding.                                                                                                                                    |
| `unpadded_piece_size`     | `bigint`  | NO       | The piece size in bytes without padding.                                                                                                                                 |
| `is_verified`             | `boolean` | NO       | Deal is with a verified provider.                                                                                                                                        |
| `client_id`               | `text`    | NO       | Address of the actor proposing the deal.                                                                                                                                 |
| `provider_id`             | `text`    | NO       | Address of the actor providing the services.                                                                                                                             |
| `start_epoch`             | `bigint`  | NO       | The epoch at which this deal with begin. Storage deal must appear in a sealed (proven) sector no later than start_epoch, otherwise it is invalid.                        |
| `end_epoch`               | `bigint`  | NO       | The epoch at which this deal with end.                                                                                                                                   |
| `storage_price_per_epoch` | `text`    | NO       | The amount of FIL (in attoFIL) that will be transferred from the client to the provider every epoch this deal is active for.                                             |
| `provider_collateral`     | `text`    | NO       | The amount of FIL (in attoFIL) the provider has pledged as collateral. The Provider deal collateral is only slashed when a sector is terminated before the deal expires. |
| `client_collateral`       | `text`    | NO       | The amount of FIL (in attoFIL) the client has pledged as collateral.                                                                                                     |
| `label`                   | `text`    | YES      | An arbitrary client chosen label to apply to the deal.                                                                                                                   |
| `height`                  | `bigint`  | NO       | Epoch at which this deal proposal was added or changed.                                                                                                                  |
| `is_string`               | `boolean` | YES      | When true Label contains a valid UTF-8 string encoded in base64. When false Label contains raw bytes encoded in base64. Required by FIP: 27                              |

### market_deal_states

All storage deal state transitions detected on-chain.

- Task: `market_deal_state`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column               | Type     | Nullable | Description                                                                               |
| -------------------- | -------- | -------- | ----------------------------------------------------------------------------------------- |
| `deal_id`            | `bigint` | NO       | Identifier for the deal.                                                                  |
| `sector_start_epoch` | `bigint` | NO       | Epoch this deal was included in a proven sector. -1 if not yet included in proven sector. |
| `last_update_epoch`  | `bigint` | NO       | Epoch this deal was last updated at. -1 if deal state never updated.                      |
| `slash_epoch`        | `bigint` | NO       | Epoch this deal was slashed at. -1 if deal was never slashed.                             |
| `state_root`         | `text`   | NO       | CID of the parent state root for this deal.                                               |
| `height`             | `bigint` | NO       | Epoch at which this deal was added or changed.                                            |

## Storage Miner Actor
### miner_beneficiary

- Task: `miner_beneficiary`
- Network Range: [`v17` - `v∞`)
- Epoch Range: [`2383680` - `∞`)

| Column                    | Type      | Nullable | Description                                                                                                                                                                |
| ------------------------- | --------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height`                  | `bigint`  | NO       | Epoch at which this beneficiary was added or change.                                                                                                                       |
| `state_root`              | `text`    | NO       | CID of the parent state root at which this beneficiary was added or change.                                                                                                |
| `miner_id`                | `text`    | NO       | Address of the miner this beneficiary relates to.                                                                                                                          |
| `beneficiary`             | `text`    | NO       | Address of the beneficiary. The beneficiary is set to the same address of Owner when initiating a miner without specifying a beneficiary address (for back-compatibility). |
| `quota`                   | `numeric` | NO       | Quota of the beneficiary.                                                                                                                                                  |
| `used_quote`              | `numeric` | NO       | Quota currently used by the beneficiary.                                                                                                                                   |
| `expiration`              | `bigint`  | NO       | Epoch at which the beneficiary expired.                                                                                                                                    |
| `new_beneficiary`         | `text`    | NO       | Address of a proposed beneficiary.                                                                                                                                         |
| `new_quota`               | `numeric` | NO       | Quota of proposed beneficiary.                                                                                                                                             |
| `new_expiration`          | `bigint`  | NO       | Expiration epoch of proposed beneficiary.                                                                                                                                  |
| `approved_by_beneficiary` | `boolean` | NO       | If new_beneficiary, new_quota and new_expiration are approved by beneficiary.                                                                                              |
| `approved_by_nominee`     | `boolean` | NO       | If new_beneficiary, new_quota and new_expiration are approved by nominee.                                                                                                  |

### miner_current_deadline_infos

Deadline refers to the window during which proofs may be submitted.

- Task: `miner_current_deadline_info`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column           | Type     | Nullable | Description                                                                    |
| ---------------- | -------- | -------- | ------------------------------------------------------------------------------ |
| `height`         | `bigint` | NO       | Epoch at which this info was calculated.                                       |
| `miner_id`       | `text`   | NO       | Address of the miner this info relates to.                                     |
| `state_root`     | `text`   | NO       | CID of the parent state root at this epoch.                                    |
| `deadline_index` | `bigint` | NO       | A deadline index, in [0..d.WPoStProvingPeriodDeadlines) unless period elapsed. |
| `period_start`   | `bigint` | NO       | First epoch of the proving period (<= CurrentEpoch).                           |
| `open`           | `bigint` | NO       | First epoch from which a proof may be submitted (>= CurrentEpoch).             |
| `close`          | `bigint` | NO       | First epoch from which a proof may no longer be submitted (>= Open).           |
| `challenge`      | `bigint` | NO       | Epoch at which to sample the chain for challenge (< Open).                     |
| `fault_cutoff`   | `bigint` | NO       | First epoch at which a fault declaration is rejected (< Open).                 |

### miner_fee_debts

Miner debts per epoch from unpaid fees.

- Task: `miner_fee_debt`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column       | Type      | Nullable | Description                                                         |
| ------------ | --------- | -------- | ------------------------------------------------------------------- |
| `height`     | `bigint`  | NO       | Epoch at which this debt applies.                                   |
| `miner_id`   | `text`    | NO       | Address of the miner that owes fees.                                |
| `state_root` | `text`    | NO       | CID of the parent state root at this epoch.                         |
| `fee_debt`   | `numeric` | NO       | Absolute value of debt this miner owes from unpaid fees in attoFIL. |

### miner_infos

Miner Account IDs for all associated addresses plus peer ID. See https://docs.filecoin.io/mine/lotus/miner-addresses/ for more information.

- Task: `miner_info`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                      | Type     | Nullable | Description                                                                                                                                                                                                                                                                                                                                                         |
| --------------------------- | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height`                    | `bigint` | NO       | Epoch at which this miner info was added/changed.                                                                                                                                                                                                                                                                                                                   |
| `miner_id`                  | `text`   | NO       | Address of miner this info applies to.                                                                                                                                                                                                                                                                                                                              |
| `state_root`                | `text`   | NO       | CID of the parent state root at this epoch.                                                                                                                                                                                                                                                                                                                         |
| `owner_id`                  | `text`   | NO       | Address of actor designated as the owner. The owner address is the address that created the miner, paid the collateral, and has block rewards paid out to it.                                                                                                                                                                                                       |
| `worker_id`                 | `text`   | NO       | Address of actor designated as the worker. The worker is responsible for doing all of the work, submitting proofs, committing new sectors, and all other day to day activities.                                                                                                                                                                                     |
| `new_worker`                | `text`   | YES      | Address of a new worker address that will become effective at worker_change_epoch.                                                                                                                                                                                                                                                                                  |
| `worker_change_epoch`       | `bigint` | NO       | Epoch at which a new_worker address will become effective.                                                                                                                                                                                                                                                                                                          |
| `consensus_faulted_elapsed` | `bigint` | NO       | The next epoch this miner is eligible for certain permissioned actor methods and winning block elections as a result of being reported for a consensus fault.                                                                                                                                                                                                       |
| `peer_id`                   | `text`   | YES      | Current libp2p Peer ID of the miner.                                                                                                                                                                                                                                                                                                                                |
| `control_addresses`         | `jsonb`  | YES      | JSON array of control addresses. Control addresses are used to submit WindowPoSts proofs to the chain. WindowPoSt is the mechanism through which storage is verified in Filecoin and is required by miners to submit proofs for all sectors every 24 hours. Those proofs are submitted as messages to the blockchain and therefore need to pay the respective fees. |
| `multi_addresses`           | `jsonb`  | YES      | JSON array of multiaddrs at which this miner can be reached.                                                                                                                                                                                                                                                                                                        |

### miner_locked_funds

Details of Miner funds locked and unavailable for use.

- Task: `miner_locked_fund`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                | Type      | Nullable | Description                                                                                                                                                                                                                                                                                                         |
| --------------------- | --------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height`              | `bigint`  | NO       | Epoch at which these details were added/changed.                                                                                                                                                                                                                                                                    |
| `miner_id`            | `text`    | NO       | Address of the miner these details apply to.                                                                                                                                                                                                                                                                        |
| `state_root`          | `text`    | NO       | CID of the parent state root at this epoch.                                                                                                                                                                                                                                                                         |
| `locked_funds`        | `numeric` | NO       | Amount of FIL (in attoFIL) locked due to vesting. When a Miner receives tokens from block rewards, the tokens are locked and added to the Miner's vesting table to be unlocked linearly over some future epochs.                                                                                                    |
| `initial_pledge`      | `numeric` | NO       | Amount of FIL (in attoFIL) locked due to it being pledged as collateral. When a Miner ProveCommits a Sector, they must supply an "initial pledge" for the Sector, which acts as collateral. If the Sector is terminated, this deposit is removed and burned along with rewards earned by this sector up to a limit. |
| `pre_commit_deposits` | `numeric` | NO       | Amount of FIL (in attoFIL) locked due to it being used as a PreCommit deposit. When a Miner PreCommits a Sector, they must supply a "precommit deposit" for the Sector, which acts as collateral. If the Sector is not ProveCommitted on time, this deposit is removed and burned.                                  |

### miner_pre_commit_infos

Information on sector PreCommits.

- Task: `miner_pre_commit_info`
- Network Range: [`v0` - `v16`]
- Epoch Range: [`0` - `2383680`)

| Column                     | Type      | Nullable | Description                                                                                                                              |
| -------------------------- | --------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `miner_id`                 | `text`    | NO       | Address of the miner who owns the sector.                                                                                                |
| `sector_id`                | `bigint`  | NO       | Numeric identifier for the sector.                                                                                                       |
| `state_root`               | `text`    | NO       | CID of the parent state root at this epoch.                                                                                              |
| `sealed_cid`               | `text`    | NO       | CID of the sealed sector.                                                                                                                |
| `seal_rand_epoch`          | `bigint`  | YES      | Seal challenge epoch. Epoch at which randomness should be drawn to tie Proof-of-Replication to a chain.                                  |
| `expiration_epoch`         | `bigint`  | YES      | Epoch this sector expires.                                                                                                               |
| `pre_commit_deposit`       | `numeric` | NO       | Amount of FIL (in attoFIL) used as a PreCommit deposit. If the Sector is not ProveCommitted on time, this deposit is removed and burned. |
| `pre_commit_epoch`         | `bigint`  | YES      | Epoch this PreCommit was created.                                                                                                        |
| `deal_weight`              | `numeric` | NO       | Total space\*time of submitted deals.                                                                                                    |
| `verified_deal_weight`     | `numeric` | NO       | Total space\*time of submitted verified deals.                                                                                           |
| `is_replace_capacity`      | `boolean` | YES      | Whether to replace a "committed capacity" no-deal sector (requires non-empty DealIDs).                                                   |
| `replace_sector_deadline`  | `bigint`  | YES      | The deadline location of the sector to replace.                                                                                          |
| `replace_sector_partition` | `bigint`  | YES      | The partition location of the sector to replace.                                                                                         |
| `replace_sector_number`    | `bigint`  | YES      | ID of the committed capacity sector to replace.                                                                                          |
| `height`                   | `bigint`  | NO       | Epoch this PreCommit information was added/changed.                                                                                      |

### miner_pre_commit_infos_v9

Information on sector PreCommits for actors v9+ and above.

- Task: `miner_pre_commit_info`
- Network Range: [`v17` - `v∞`)
- Epoch Range: [`2383680` - `∞`)

| Column                     | Type      | Nullable | Description                                                                                                                              |
| -------------------------- | --------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `miner_id`                 | `text`    | NO       | Address of the miner who owns the sector.                                                                                                |
| `sector_id`                | `bigint`  | NO       | Numeric identifier for the sector.                                                                                                       |
| `state_root`               | `text`    | NO       | CID of the parent state root at this epoch.                                                                                              |
| `sealed_cid`               | `text`    | NO       | CID of the sealed sector.                                                                                                                |
| `seal_rand_epoch`          | `bigint`  | YES      | Seal challenge epoch. Epoch at which randomness should be drawn to tie Proof-of-Replication to a chain.                                  |
| `expiration_epoch`         | `bigint`  | YES      | Epoch this sector expires.                                                                                                               |
| `pre_commit_deposit`       | `numeric` | NO       | Amount of FIL (in attoFIL) used as a PreCommit deposit. If the Sector is not ProveCommitted on time, this deposit is removed and burned. |
| `pre_commit_epoch`         | `bigint`  | YES      | Epoch this PreCommit was created.                                                                                                        |
| `deal_weight`              | `numeric` | NO       | Total space\*time of submitted deals.                                                                                                    |
| `verified_deal_weight`     | `numeric` | NO       | Total space\*time of submitted verified deals.                                                                                           |
| `is_replace_capacity`      | `boolean` | YES      | Whether to replace a "committed capacity" no-deal sector (requires non-empty DealIDs).                                                   |
| `replace_sector_deadline`  | `bigint`  | YES      | The deadline location of the sector to replace.                                                                                          |
| `replace_sector_partition` | `bigint`  | YES      | The partition location of the sector to replace.                                                                                         |
| `replace_sector_number`    | `bigint`  | YES      | ID of the committed capacity sector to replace.                                                                                          |
| `height`                   | `bigint`  | NO       | Epoch this PreCommit information was added/changed.                                                                                      |

### miner_sector_deals

Mapping of Deal IDs to their respective Miner and Sector IDs.

- Task: `miner_sector_deal`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column      | Type     | Nullable | Description                                       |
| ----------- | -------- | -------- | ------------------------------------------------- |
| `miner_id`  | `text`   | NO       | Address of the miner the deal is with.            |
| `sector_id` | `bigint` | NO       | Numeric identifier of the sector the deal is for. |
| `deal_id`   | `bigint` | NO       | Numeric identifier for the deal.                  |
| `height`    | `bigint` | NO       | Epoch at which this deal was added/updated.       |

### miner_sector_events

Sector events on-chain per Miner/Sector.

- Task: `miner_sector_event`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column       | Type                                                                                                                                                                                                                                        | Nullable | Description                                 |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------- |
| `miner_id`   | `text`                                                                                                                                                                                                                                      | NO       | Address of the miner who owns the sector.   |
| `sector_id`  | `bigint`                                                                                                                                                                                                                                    | NO       | Numeric identifier of the sector.           |
| `state_root` | `text`                                                                                                                                                                                                                                      | NO       | CID of the parent state root at this epoch. |
| `event`      | `PRECOMMIT_ADDED`, `PRECOMMIT_EXPIRED`, `COMMIT_CAPACITY_ADDED`, `SECTOR_ADDED`, `SECTOR_EXTENDED`, `SECTOR_FAULTED`, `SECTOR_FAULTED`, `SECTOR_SNAPPED`, `SECTOR_RECOVERING`, `SECTOR_RECOVERED`, `SECTOR_EXPIRED`, or `SECTOR_TERMINATED` | NO       | Name of the event that occurred.            |
| `height`     | `bigint`                                                                                                                                                                                                                                    | NO       | Epoch at which this event occurred.         |

### miner_sector_infos_v7

Latest state of sectors by Miner for actors v7 and above.

- Task: `miner_sector_infos_v7`
- Network Range: [`v15` - `v∞`)
- Epoch Range: [`1594680` - `∞`)

| Column                    | Type      | Nullable | Description                                                                                   |
| ------------------------- | --------- | -------- | --------------------------------------------------------------------------------------------- |
| `miner_id`                | `text`    | NO       | Address of the miner who owns the sector.                                                     |
| `sector_id`               | `bigint`  | NO       | Numeric identifier of the sector.                                                             |
| `state_root`              | `text`    | NO       | CID of the parent state root at this epoch.                                                   |
| `sealed_cid`              | `text`    | NO       | The root CID of the Sealed Sector’s merkle tree. Also called CommR, or "replica commitment".  |
| `activation_epoch`        | `bigint`  | YES      | Epoch during which the sector proof was accepted.                                             |
| `expiration_epoch`        | `bigint`  | YES      | Epoch during which the sector expires.                                                        |
| `deal_weight`             | `numeric` | NO       | Integral of active deals over sector lifetime.                                                |
| `verified_deal_weight`    | `numeric` | NO       | Integral of active verified deals over sector lifetime.                                       |
| `initial_pledge`          | `numeric` | NO       | Pledge collected to commit this sector (in attoFIL).                                          |
| `expected_day_reward`     | `numeric` | NO       | Expected one day projection of reward for sector computed at activation time (in attoFIL).    |
| `expected_storage_pledge` | `numeric` | NO       | Expected twenty day projection of reward for sector computed at activation time (in attoFIL). |
| `height`                  | `bigint`  | NO       | Epoch at which this sector info was added/updated.                                            |
| `sector_key_cid`          | `text`    | YES      | SealedSectorCID is set when CC sector is snapped.                                             |

### miner_sector_infos

Latest state of sectors by Miner.

- Task: `miner_sector_infos`
- Network Range: [`v0` - `v14`]
- Epoch Range: [`0` - `1594680`)

| Column                    | Type      | Nullable | Description                                                                                   |
| ------------------------- | --------- | -------- | --------------------------------------------------------------------------------------------- |
| `miner_id`                | `text`    | NO       | Address of the miner who owns the sector.                                                     |
| `sector_id`               | `bigint`  | NO       | Numeric identifier of the sector.                                                             |
| `state_root`              | `text`    | NO       | CID of the parent state root at this epoch.                                                   |
| `sealed_cid`              | `text`    | NO       | The root CID of the Sealed Sector’s merkle tree. Also called CommR, or "replica commitment".  |
| `activation_epoch`        | `bigint`  | YES      | Epoch during which the sector proof was accepted.                                             |
| `expiration_epoch`        | `bigint`  | YES      | Epoch during which the sector expires.                                                        |
| `deal_weight`             | `numeric` | NO       | Integral of active deals over sector lifetime.                                                |
| `verified_deal_weight`    | `numeric` | NO       | Integral of active verified deals over sector lifetime.                                       |
| `initial_pledge`          | `numeric` | NO       | Pledge collected to commit this sector (in attoFIL).                                          |
| `expected_day_reward`     | `numeric` | NO       | Expected one day projection of reward for sector computed at activation time (in attoFIL).    |
| `expected_storage_pledge` | `numeric` | NO       | Expected twenty day projection of reward for sector computed at activation time (in attoFIL). |
| `height`                  | `bigint`  | NO       | Epoch at which this sector info was added/updated.                                            |

### miner_sector_posts

Proof of Spacetime for sectors.

- Task: `miner_sector_post`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column             | Type     | Nullable | Description                                    |
| ------------------ | -------- | -------- | ---------------------------------------------- |
| `miner_id`         | `text`   | NO       | Address of the miner who owns the sector.      |
| `sector_id`        | `bigint` | NO       | Numeric identifier of the sector.              |
| `height`           | `bigint` | NO       | Epoch at which this PoSt message was executed. |
| `post_message_cid` | `text`   | YES      | CID of the PoSt message.                       |

## MultiSig Actor
### multisig_approvals

Message Transactions approved by Multsig Actors.

- Task: `multisig_approvals`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column         | Description                                                                                                                                                                                              |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| height         | Epoch at which this transaction was executed.                                                                                                                                                            |
| multisig_id    | Address of the multisig actor involved in the transaction.                                                                                                                                               |
| state_root     | CID of the parent state root at this epoch.                                                                                                                                                              |
| transaction_id | Number identifier for the transaction - unique per multisig.                                                                                                                                             |
| to             | Address of the recipient who will be sent a message if the proposal is approved.                                                                                                                         |
| value          | Amount of FIL (in attoFIL) that will be transferred if the proposal is approved.                                                                                                                         |
| method         | The method number to invoke on the recipient if the proposal is approved. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method execution. |

### multisig_transactions

Details of pending transactions involving multisig actors.

- Task: `multisig_transaction`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column           | Type     | Nullable | Description                                                                                                                                                                                              |
| ---------------- | -------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height`         | `bigint` | NO       | Epoch at which this transaction was executed.                                                                                                                                                            |
| `multisig_id`    | `text`   | NO       | Address of the multisig actor involved in the transaction.                                                                                                                                               |
| `state_root`     | `text`   | NO       | CID of the parent state root at this epoch.                                                                                                                                                              |
| `transaction_id` | `bigint` | NO       | Number identifier for the transaction - unique per multisig.                                                                                                                                             |
| `to`             | `text`   | NO       | Address of the recipient who will be sent a message if the proposal is approved.                                                                                                                         |
| `value`          | `text`   | NO       | Amount of FIL (in attoFIL) that will be transferred if the proposal is approved.                                                                                                                         |
| `method`         | `bigint` | NO       | The method number to invoke on the recipient if the proposal is approved. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method execution. |
| `params`         | `bytea`  | YES      | CBOR encoded bytes of parameters to send to the method that will be invoked if the proposal is approved.                                                                                                 |
| `approved`       | `jsonb`  | NO       | Addresses of signers who have approved the transaction. 0th entry is the proposer.                                                                                                                       |

## Power Actor
### chain_powers

Power summaries from the Power actor.

- Task: `chain_power`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                          | Type      | Nullable | Description                                                                                                                                                                                                 |
| ------------------------------- | --------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `state_root`                    | `text`    | NO       | CID of the parent state root.                                                                                                                                                                               |
| `total_raw_bytes_power`         | `numeric` | NO       | Total storage power in bytes in the network. Raw byte power is the size of a sector in bytes.                                                                                                               |
| `total_raw_bytes_committed`     | `numeric` | NO       | Total provably committed storage power in bytes. Raw byte power is the size of a sector in bytes.                                                                                                           |
| `total_qa_bytes_power`          | `numeric` | NO       | Total quality adjusted storage power in bytes in the network. Quality adjusted power is a weighted average of the quality of its space and it is based on the size, duration and quality of its deals.      |
| `total_qa_bytes_committed`      | `numeric` | NO       | Total provably committed, quality adjusted storage power in bytes. Quality adjusted power is a weighted average of the quality of its space and it is based on the size, duration and quality of its deals. |
| `total_pledge_collateral`       | `numeric` | NO       | Total locked FIL (attoFIL) miners have pledged as collateral in order to participate in the economy.                                                                                                        |
| `qa_smoothed_position_estimate` | `numeric` | NO       | Total power smoothed position estimate - Alpha Beta Filter "position" (value) estimate in Q.128 format.                                                                                                     |
| `qa_smoothed_velocity_estimate` | `numeric` | NO       | Total power smoothed velocity estimate - Alpha Beta Filter "velocity" (rate of change of value) estimate in Q.128 format.                                                                                   |
| `miner_count`                   | `bigint`  | YES      | Total number of miners.                                                                                                                                                                                     |
| `participating_miner_count`     | `bigint`  | YES      | Total number of miners with power above the minimum miner threshold.                                                                                                                                        |
| `height`                        | `bigint`  | NO       | Epoch this power summary applies to.                                                                                                                                                                        |

### power_actor_claims

Miner power claims recorded by the power actor.

- Task: `power_actor_claim`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column              | Type      | Nullable | Description                                                                                                                                                                                           |
| ------------------- | --------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height`            | `bigint`  | NO       | Epoch this claim was made.                                                                                                                                                                            |
| `miner_id`          | `text`    | NO       | Address of miner making the claim.                                                                                                                                                                    |
| `state_root`        | `text`    | NO       | CID of the parent state root at this epoch.                                                                                                                                                           |
| `raw_byte_power`    | `numeric` | NO       | Sum of raw byte storage power for a miner's sectors. Raw byte power is the size of a sector in bytes.                                                                                                 |
| `quality_adj_power` | `numeric` | NO       | Sum of quality adjusted storage power for a miner's sectors. Quality adjusted power is a weighted average of the quality of its space and it is based on the size, duration and quality of its deals. |

## Reward Actor
### chain_rewards

Reward summaries from the Reward actor.

- Task: `chain_reward`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                                  | Type      | Nullable | Description                                                                                                                                                                                                                  |
| --------------------------------------- | --------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `state_root`                            | `text`    | NO       | CID of the parent state root.                                                                                                                                                                                                |
| `cum_sum_baseline`                      | `numeric` | NO       | Target that CumsumRealized needs to reach for EffectiveNetworkTime to increase. It is measured in byte-epochs (space \* time) representing power committed to the network for some duration.                                 |
| `cum_sum_realized`                      | `numeric` | NO       | Cumulative sum of network power capped by BaselinePower(epoch). It is measured in byte-epochs (space \* time) representing power committed to the network for some duration.                                                 |
| `effective_baseline_power`              | `numeric` | NO       | The baseline power (in bytes) at the EffectiveNetworkTime epoch.                                                                                                                                                             |
| `new_baseline_power`                    | `numeric` | NO       | The baseline power (in bytes) the network is targeting.                                                                                                                                                                      |
| `new_reward_smoothed_position_estimate` | `numeric` | NO       | Smoothed reward position estimate - Alpha Beta Filter "position" (value) estimate in Q.128 format.                                                                                                                           |
| `new_reward_smoothed_velocity_estimate` | `numeric` | NO       | Smoothed reward velocity estimate - Alpha Beta Filter "velocity" (rate of change of value) estimate in Q.128 format.                                                                                                         |
| `total_mined_reward`                    | `numeric` | NO       | The total FIL (attoFIL) awarded to block miners.                                                                                                                                                                             |
| `new_reward`                            | `numeric` | YES      | The reward to be paid in per WinCount to block producers. The actual reward total paid out depends on the number of winners in any round. This value is recomputed every non-null epoch and used in the next non-null epoch. |
| `effective_network_time`                | `bigint`  | YES      | Ceiling of real effective network time "theta" based on CumsumBaselinePower(theta) == CumsumRealizedPower. Theta captures the notion of how much the network has progressed in its baseline and in advancing network time.   |
| `height`                                | `bigint`  | NO       | Epoch this rewards summary applies to.                                                                                                                                                                                       |

## Verified Registry Actor
### verified_registry_verifiers

Verifier on-chain per each verifier state change.

- Task: `verified_registry_verifier`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column       | Type           | Nullable | Description                                       |
| ------------ | -------------- | -------- | ------------------------------------------------- |
| `height`     | `bigint`       | NO       | Epoch at which this verifiers state changed.      |
| `state_root` | `text`         | NO       | CID of the parent state root at this epoch.       |
| `address`    | `text`         | NO       | Address of verifier this state change applies to. |
| `data_cap`   | `numeric`      | NO       | DataCap of verifier at this state change.         |
| `event`      | `USER-DEFINED` | NO       | Name of the event that occurred.                  |

### verified_registry_verified_clients

Verifier on-chain per each verified client state change.

- Task: `verified_registry_verified_client`
- Network Range: [`v0` - `v16`]
- Epoch Range: [`0` - `2383680`)

| Column       | Type           | Nullable | Description                                              |
| ------------ | -------------- | -------- | -------------------------------------------------------- |
| `height`     | `bigint`       | NO       | Epoch at which this verified client state changed.       |
| `state_root` | `text`         | NO       | CID of the parent state root at this epoch.              |
| `address`    | `text`         | NO       | Address of verified client this state change applies to. |
| `data_cap`   | `numeric`      | NO       | DataCap of verified client at this state change.         |
| `event`      | `USER-DEFINED` | NO       | Name of the event that occurred.                         |

## FEVM Actor
### fevm_actor_stats

FEVM Actor related statistical data.

- Task: `fevm_actor_stats`
- Network Range: [`v18` - `v∞`)
- Epoch Range: [`2683348` - `∞`)

| Column                 | Type     | Nullable | Description                                         |
| -----------------------| ---------| -------- | --------------------------------------------------- |
| `height`               | `bigint` | NO       | Epoch                                               |
| `contract_balance`     | `text`   | NO       | Balance of EVM actor in attoFIL                     |
| `eth_account_balance`  | `text`   | NO       | Balance of ETH account actor in attoFIL.            |
| `placeholder_balance`  | `text`   | NO       | Balance of Placeholder Actor in attoFIL.            |
| `contract_count`       | `bigint` | NO       | Number of contracts                                 |
| `unique_contract_count`| `bigint` | NO       | Number of unique contracts                          |
| `eth_account_count`    | `bigint` | NO       | Number of ETH account actors                        |
| `placeholder_count`    | `bigint` | NO       | Number of placeholder actors                        |

### fevm_contracts

The table is designed to maintain a comprehensive record of changes made to contracts in the FEVM system. This table captures both the creation of new contracts and any subsequent updates or modifications made to existing contracts.

- Task: `fevm_contract`
- Network Range: [`v18` - `v∞`)
- Epoch Range: [`2683348` - `∞`)

| Column          | Type     | Nullable | Description                                              |
| ----------------| ---------| -------- | ---------------------------------------------------------|
| `height`        | `bigint` | NO       | Epoch at contract was added or changed.                  |
| `actor_id`      | `text`   | NO       | Actor address.                                           |
| `eth_address`   | `text`   | NO       | Actor ETH address.                                       |
| `byte_code`     | `text`   | NO       | Contract Bytecode.                                       |
| `byte_code_hash`| `text`   | NO       | Contract Bytecode is encoded in hash by Keccak256.       |
| `balance`       | `numeric`| NO       | Balance of EVM actor in attoFIL.                         |
| `nonce`         | `bigint` | NO       | The next actor nonce that is expected to appear on chain.|



## Deprecate
### actor_states

Actor states that were changed at an epoch. Associates actors states as single-level trees with CIDs pointing to complete state tree with the root CID (head) for that actor's state.

- Task: `actor_state`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column   | Type     | Nullable | Description                                      |
| -------- | -------- | -------- | ------------------------------------------------ |
| `head`   | `text`   | NO       | CID of the root of the state tree for the actor. |
| `code`   | `text`   | NO       | CID identifier for the type of the actor.        |
| `state`  | `jsonb`  | NO       | Top level of state data.                         |
| `height` | `bigint` | NO       | Epoch when this state change happened.           |
