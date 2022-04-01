---
title: "Lily data models"
description: "Lily relational data is formatted per the Lily data models."
lead: "Lily relational data format is defined according to the following models, each corresponding to a table."
menu:
  data:
    parent: "data"
    identifier: "models"
weight: 10
toc: true
---

---

## actor_states

Actor states that were changed at an epoch. Associates actors states as single-level trees with CIDs pointing to complete state tree with the root CID (head) for that actor's state.

| Column | Description                                      |
| ------ | ------------------------------------------------ |
| height | Epoch when this state change happened.           |
| head   | CID of the root of the state tree for the actor. |
| code   | CID identifier for the type of the actor.        |
| state  | Top level of state data.                         |

## actors

Actors on chain that were added or updated at an epoch. Associates the actor's state root CID (head) with the chain state root CID from which it decends. Includes account ID nonce and balance at each state.

| Column     | Description                                               |
| ---------- | --------------------------------------------------------- |
| height     | Epoch when this actor was created or updated.             |
| id         | Actor address.                                            |
| code       | Human readable identifier for the type of the actor.      |
| head       | CID of the root of the state tree for the actor.          |
| nonce      | The next actor nonce that is expected to appear on chain. |
| balance    | Actor balance in attoFIL.                                 |
| state_root | CID of the state root.                                    |

## block_headers

Blocks included in tipsets at an epoch.

| Column            | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| height            | Epoch when this block was mined.                             |
| cid               | CID of the block.                                            |
| parent_weight     | Aggregate chain weight of the block's parent set.            |
| parent_state_root | CID of the block's parent state root.                        |
| miner             | Address of the miner who mined this block.                   |
| timestamp         | Time the block was mined in Unix time, the number of seconds elapsed since January 1, 1970 UTC. |
| win_count         | Number of reward units won in this block.                    |
| parent_base_fee   | The base fee after executing the parent tipset.              |
| fork_signaling    | Flag used as part of signaling forks.                        |

## block_messages

Message CIDs and the Blocks CID which contain them.

| Column  | Description                                 |
| ------- | ------------------------------------------- |
| height  | Epoch when the block was mined.             |
| block   | CID of the block that contains the message. |
| message | CID of a message in the block.              |

## block_parents

Block CIDs to many parent Block CIDs.

| Column | Description                     |
| ------ | ------------------------------- |
| height | Epoch when the block was mined. |
| block  | CID of the block.               |
| parent | CID of the parent block.        |

## chain_consensus

Hight and TipSet to Parent TipSet or Null Round. 

| Column            | Description                                      |
| ----------------- | ------------------------------------------------ |
| height            | Epoch when the blocks were mined in this tipset. |
| tip_set           | CID of the tipset or `NULL_ROUND`                |
| parent_tip_set    | CID of the parent tipset                         |
| parent_state_root | CID of the parent tipset state root              |

## chain_economics

Economic summaries per state root CID.

| Column                | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| height                | Epoch of the economic summary.                               |
| parent_state_root     | CID of the parent state root.                                |
| circulating_fil       | The amount of FIL (attoFIL) circulating and tradeable in the economy. The basis for Market Cap calculations. |
| vested_fil            | Total amount of FIL (attoFIL) that is vested from genesis allocation. |
| mined_fil             | The amount of FIL (attoFIL) that has been mined by storage miners. |
| burnt_fil             | Total FIL (attoFIL) burned as part of penalties and on-chain computations. |
| locked_fil            | The amount of FIL (attoFIL) locked as part of mining, deals, and other mechanisms. |
| fil_reserve_disbursed | The amount of FIL (attoFIL) that has been disbursed from the mining reserve. |

## chain_powers

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

## chain_rewards

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

## derived_gas_outputs

Derived gas costs resulting from execution of a message in the VM.

| Column               | Description                                                  |
| -------------------- | ------------------------------------------------------------ |
| height               | Epoch this message was executed at.                          |
| cid                  | CID of the message.                                          |
| from                 | Address of actor that sent the message.                      |
| to                   | Address of actor that received the message.                  |
| value                | The FIL value transferred (attoFIL) to the message receiver. |
| gas_fee_cap          | The maximum price that the message sender is willing to pay per unit of gas. |
| gas_premium          | The price per unit of gas (measured in attoFIL/gas) that the message sender is willing to pay (on top of the BaseFee) to "tip" the miner that will include this message in a block. |
| gas_limit            | A hard limit on the amount of gas (i.e., number of units of gas) that a message’s execution should be allowed to consume on chain. It is measured in units of gas. |
| size_bytes           | Size in bytes of the serialized message.                     |
| nonce                | The message nonce, which protects against duplicate messages and multiple messages with the same values. |
| method               | The method number to invoke. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution. |
| state_root           | CID of the parent state root.                                |
| exit_code            | The exit code that was returned as a result of executing the message. Exit code 0 indicates success. Codes 0-15 are reserved for use by the runtime. Codes 16-31 are common codes shared by different actors. Codes 32+ are actor specific. |
| gas_used             | A measure of the amount of resources (or units of gas) consumed, in order to execute a message. |
| parent_base_fee      | The set price per unit of gas (measured in attoFIL/gas unit) to be burned (sent to an unrecoverable address) for every message execution. |
| base_fee_burn        | The amount of FIL (in attoFIL) to burn as a result of the base fee. It is parent_base_fee (or gas_fee_cap if smaller) multiplied by gas_used. Note: successful window PoSt messages are not charged this burn. |
| over_estimation_burn | The fee to pay (in attoFIL) for overestimating the gas used to execute a message. The overestimated gas to burn (gas_burned) is a portion of the difference between gas_limit and gas_used. The over_estimation_burn value is gas_burned * parent_base_fee. |
| miner_penalty        | Any penalty fees (in attoFIL) the miner incured while executing the message. |
| miner_tip            | The amount of FIL (in attoFIL) the miner receives for executing the message. Typically it is gas_premium * gas_limit but may be lower if the total fees exceed the gas_fee_cap. |
| refund               | The amount of FIL (in attoFIL) to refund to the message sender after base fee, miner tip and overestimation amounts have been deducted. |
| gas_refund           | The overestimated units of gas to refund. It is a portion of the difference between gas_limit and gas_used. |
| gas_burned           | The overestimated units of gas to burn. It is a portion of the difference between gas_limit and gas_used. |
| actor_name           | The full versioned name of the actor that received the message (for example fil/3/storagepower). |
| actor_family         | The short unversioned name of the actor that received the message (for example storagepower). |

## drand_block_entries

Drand randomness round numbers used in each block.

| Column | Description                              |
| ------ | ---------------------------------------- |
| round  | The round number of the randomness used. |
| block  | CID of the block.                        |

## 	id_addresses

Mapping of IDs to robust addresses from the init actor's state.

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this address mapping was added.               |
| id         | ID of the actor.                                             |
| address    | Robust address of the actor.                                 |
| state_root | CID of the parent state root at which this address mapping was added. |

## internal_messages

Messages generated implicitly by system actors and by using the runtime send method.

| Column         | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| height         | Epoch this message was executed at.                          |
| cid            | CID of the message.                                          |
| state_root     | CID of the parent state root at which this message was executed. |
| source_message | CID of the message that caused this message to be sent.      |
| from           | Address of the actor that sent the message.                  |
| to             | Address of the actor that received the message.              |
| value          | Amount of FIL (in attoFIL) transferred by this message.      |
| method         | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution. |
| actor_name     | The full versioned name of the actor that received the message (for example fil/3/storagepower). |
| actor_family   | The short unversioned name of the actor that received the message (for example storagepower). |
| exit_code      | The exit code that was returned as a result of executing the message. Exit code 0 indicates success. Codes 0-15 are reserved for use by the runtime. Codes 16-31 are common codes shared by different actors. Codes 32+ are actor specific. |
| gas_used       | A measure of the amount of resources (or units of gas) consumed, in order to execute a message. |

## internal_parsed_messages

Internal messages parsed to extract useful information.

| Column | Description                                                  |
| ------ | ------------------------------------------------------------ |
| height | Epoch this message was executed at.                          |
| cid    | CID of the message.                                          |
| from   | Address of the actor that sent the message.                  |
| to     | Address of the actor that received the message.              |
| value  | Amount of FIL (in attoFIL) transferred by this message.      |
| method | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution. |
| params | Method parameters parsed and serialized as a JSON object.    |

## market_deal_proposals

All storage deal states with latest values applied to end_epoch when updates are detected on-
chain.

| Column                  | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| height                  | Epoch at which this deal proposal was added or changed.      |
| deal_id                 | Identifier for the deal.                                     |
| state_root              | CID of the parent state root for this deal.                  |
| piece_cid               | CID of a sector piece. A Piece is an object that represents a whole or part of a File. |
| padded_piece_size       | The piece size in bytes with padding.                        |
| unpadded_piece_size     | The piece size in bytes without padding.                     |
| is_verified             | Deal is with a verified provider.                            |
| client_id               | Address of the actor proposing the deal.                     |
| provider_id             | Address of the actor providing the services.                 |
| start_epoch             | The epoch at which this deal with begin. Storage deal must appear in a sealed (proven) sector no later than start_epoch, otherwise it is invalid. |
| end_epoch               | The epoch at which this deal with end.                       |
| slashed_epoch           | The epoch at which this deal was slashed or null.            |
| storage_price_per_epoch | The amount of FIL (in attoFIL) that will be transferred from the client to the provider every epoch this deal is active for. |
| provider_collateral     | The amount of FIL (in attoFIL) the provider has pledged as collateral. The Provider deal collateral is only slashed when a sector is terminated before the deal expires. |
| client_collateral       | The amount of FIL (in attoFIL) the client has pledged as collateral. |
| label                   | An arbitrary client chosen label to apply to the deal.       |

## market_deal_states

All storage deal state transitions detected on-chain.

| Column             | Description                                                  |
| ------------------ | ------------------------------------------------------------ |
| height             | Epoch at which this deal was added or changed.               |
| deal_id            | Identifier for the deal.                                     |
| sector_start_epoch | Epoch this deal was included in a proven sector. -1 if not yet included in proven sector. |
| last_update_epoch  | Epoch this deal was last updated at. -1 if deal state never updated. |
| slash_epoch        | Epoch this deal was slashed at. -1 if deal was never slashed. |
| state_root         | CID of the parent state root for this deal.                  |

## message_gas_economy

Gas economics for all messages in all blocks at each epoch.

| Column                 | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| height                 | Epoch these economics apply to.                              |
| state_root             | CID of the parent state root at this epoch.                  |
| gas_limit_total        | The sum of all the gas limits.                               |
| gas_limit_unique_total | The sum of all the gas limits of unique messages.            |
| base_fee               | The set price per unit of gas (measured in attoFIL/gas unit) to be burned (sent to an unrecoverable address) for every message execution. |
| base_fee_change_log    | The logarithm of the change between new and old base fee.    |
| gas_fill_ratio         | The gas_limit_total / target gas limit total for all blocks. |
| gas_capacity_ratio     | The gas_limit_unique_total / target gas limit total for all blocks. |
| gas_waste_ratio        | (gas_limit_total - gas_limit_unique_total) / target gas limit total for all blocks. |

## messages

Validated on-chain messages by their CID and their metadata.

| Column      | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| height      | Epoch this message was executed at.                          |
| cid         | CID of the message.                                          |
| from        | Address of the actor that sent the message.                  |
| to          | Address of the actor that received the message.              |
| size_bytes  | Size of the serialized message in bytes.                     |
| nonce       | The message nonce, which protects against duplicate messages and multiple messages with the same values. |
| value       | Amount of FIL (in attoFIL) transferred by this message.      |
| gas_fee_cap | The maximum price that the message sender is willing to pay per unit of gas. |
| gas_premium | The price per unit of gas (measured in attoFIL/gas) that the message sender is willing to pay (on top of the BaseFee) to "tip" the miner that will include this message in a block. |
| gas_limit   | The upper bound unit of gas set on the computation required to process the message. |
| method      | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method execution. |

## miner_current_deadline_infos

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

## miner_fee_debts

Miner debts per epoch from unpaid fees.

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this debt applies.                            |
| miner_id   | Address of the miner that owes fees.                         |
| state_root | CID of the parent state root at this epoch.                  |
| fee_debt   | Absolute value of debt this miner owes from unpaid fees in attoFIL. |

## miner_infos

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

## miner_locked_funds

Details of Miner funds locked and unavailable for use.

| Column              | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| height              | Epoch at which these details were added/changed.             |
| miner_id            | Address of the miner these details apply to.                 |
| state_root          | CID of the parent state root at this epoch.                  |
| locked_funds        | Amount of FIL (in attoFIL) locked due to vesting. When a Miner receives tokens from block rewards, the tokens are locked and added to the Miner's vesting table to be unlocked linearly over some future epochs. |
| initial_pledge      | Amount of FIL (in attoFIL) locked due to it being pledged as collateral. When a Miner ProveCommits a Sector, they must supply an "initial pledge" for the Sector, which acts as collateral. If the Sector is terminated, this deposit is removed and burned along with rewards earned by this sector up to a limit. |
| pre_commit_deposits | Amount of FIL (in attoFIL) locked due to it being used as a PreCommit deposit. When a Miner PreCommits a Sector, they must supply a "precommit deposit" for the Sector, which acts as collateral. If the Sector is not ProveCommitted on time, this deposit is removed and burned. |

## miner_pre_commit_infos

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

## miner_sector_deals

Mapping of Deal IDs to their respective Miner and Sector IDs.

| Column    | Description                                       |
| --------- | ------------------------------------------------- |
| height    | Epoch at which this deal was added/updated.       |
| miner_id  | Address of the miner the deal is with.            |
| sector_id | Numeric identifier of the sector the deal is for. |
| deal_id   | Numeric identifier for the deal.                  |

## miner_sector_events

Sector events on-chain per Miner/Sector. One of

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this event occurred.                          |
| miner_id   | Address of the miner who owns the sector.                    |
| sector_id  | Numeric identifier of the sector.                            |
| state_root | CID of the parent state root at this epoch.                  |
| event      | Name of the event that occurred: PRECOMMIT_ADDED, PRECOMMIT_EXPIRED, COMMIT_CAPACITY_ADDED, SECTOR_ADDED, SECTOR_EXTENDED, SECTOR_FAULTED, SECTOR_FAULTED, SECTOR_RECOVERING, SECTOR_RECOVERED, SECTOR_EXPIRED, or SECTOR_TERMINATED. |

## miner_sector_infos

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
| verified_deal_weight    | Integral of active verified deals over sector lifetime.      |
| initial_pledge          | Pledge collected to commit this sector (in attoFIL).         |
| expected_day_reward     | Expected one day projection of reward for sector computed at activation time (in attoFIL). |
| expected_storage_pledge | Expected twenty day projection of reward for sector computed at activation time (in attoFIL). |

## miner_sector_posts

Proof of Spacetime for sectors.

| Column           | Description                                    |
| ---------------- | ---------------------------------------------- |
| height           | Epoch at which this PoSt message was executed. |
| miner_id         | Address of the miner who owns the sector.      |
| sector_id        | Numeric identifier of the sector.              |
| post_message_cid | CID of the PoSt message.                       |

## multisig_approvals

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

## multisig_transactions

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

## parsed_messages

Messages parsed to extract useful information.

| Column | Description                                                  |
| ------ | ------------------------------------------------------------ |
| height | Epoch this message was executed at.                          |
| cid    | CID of the message.                                          |
| from   | Address of the actor that sent the message.                  |
| to     | Address of the actor that received the message.              |
| value  | Amount of FIL (in attoFIL) transferred by this message.      |
| method | The name of the method that was invoked on the recipient actor. |
| params | Method parameters parsed and serialized as a JSON object.    |

## power_actor_claims

Miner power claims recorded by the power actor.

| Column            | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| height            | Epoch this claim was made.                                   |
| miner_id          | Address of miner making the claim.                           |
| state_root        | CID of the parent state root at this epoch.                  |
| raw_byte_power    | Sum of raw byte storage power for a miner's sectors. Raw byte power is the size of a sector in bytes. |
| quality_adj_power | Sum of quality adjusted storage power for a miner's sectors. Quality adjusted power is a weighted average of the quality of its space and it is based on the size, duration and quality of its deals. |

## receipts

Message reciepts after being applied to chain state by message CID and parent state root CID 
of tipset when message was executed.

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch the message was executed and receipt generated.        |
| message    | CID of the message this receipt belongs to.                  |
| state_root | CID of the parent state root that this epoch.                |
| idx        | Index of message indicating execution order.                 |
| exit_code  | The exit code that was returned as a result of executing the message. Exit code 0 indicates success. Codes 0-15 are reserved for use by the runtime. Codes 16-31 are common codes shared by different actors. Codes 32+ are actor specific. |
| gas_used   | A measure of the amount of resources (or units of gas) consumed, in order to execute a message. |

## verified_registry_verified_clients

Verifier on-chain per each verified client state change.

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this verified client state changed.           |
| state_root | CID of the parent state root at this epoch.                  |
| address    | Address of verified client this state change applies to.     |
| data_cap   | DataCap of verified client at this state change.             |
| event      | Name of the event that occurred. On of: ADDED, REMOVED, MODIFIED |

## verified_registry_verifiers

Verifier on-chain per each verifier state change.

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch at which this verifiers state changed.                 |
| state_root | CID of the parent state root at this epoch.                  |
| address    | Address of verifier this state change applies to.            |
| data_cap   | DataCap of verifier at this state change.                    |
| event      | Name of the event that occurred. On of: ADDED, REMOVED, MODIFIED |
