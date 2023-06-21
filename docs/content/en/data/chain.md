---
title: "Chain Models"
description: "Lily relational data is formatted per the Lily data models."
lead: "Lily relational data format is defined according to the following models, each corresponding to a table. These tables contain chain state and derived chain state."
menu:
  data:
    parent: "data"
    identifier: "chain_models"
weight: 10
toc: true

---

---

## Blocks
### block_headers

Blocks included in tipsets at an epoch.

- Task: `block_header`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column              | Type     | Nullable | Description                                                                                     |
| ------------------- | -------- | -------- | ----------------------------------------------------------------------------------------------- |
| `cid`               | `text`   | NO       | CID of the block.                                                                               |
| `parent_weight`     | `text`   | NO       | Aggregate chain weight of the block's parent set.                                               |
| `parent_state_root` | `text`   | NO       | CID of the block's parent state root.                                                           |
| `height`            | `bigint` | NO       | Epoch when this block was mined.                                                                |
| `miner`             | `text`   | NO       | Address of the miner who mined this block.                                                      |
| `timestamp`         | `bigint` | NO       | Time the block was mined in Unix time, the number of seconds elapsed since January 1, 1970 UTC. |
| `win_count`         | `bigint` | YES      | Number of reward units won in this block.                                                       |
| `parent_base_fee`   | `text`   | NO       | The base fee after executing the parent tipset.                                                 |
| `fork_signaling`    | `bigint` | NO       | Flag used as part of signaling forks.                                                           |

### block_messages

Message CIDs and the Blocks CID which contain them.

- Task: `block_message`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column    | Type     | Nullable | Description                                 |
| --------- | -------- | -------- | ------------------------------------------- |
| `block`   | `text`   | NO       | CID of the block that contains the message. |
| `message` | `text`   | NO       | CID of a message in the block.              |
| `height`  | `bigint` | NO       | Epoch when the block was mined.             |

### block_parents

Block CIDs to many parent Block CIDs.

- Task: `block_parent`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column   | Type     | Nullable | Description                     |
| -------- | -------- | -------- | ------------------------------- |
| `block`  | `text`   | NO       | CID of the block.               |
| `parent` | `text`   | NO       | CID of the parent block.        |
| `height` | `bigint` | NO       | Epoch when the block was mined. |

### drand_block_entries

Drand randomness round numbers used in each block.

- Task: `drand_block_entrie`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column  | Type     | Nullable | Description                              |
| ------- | -------- | -------- | ---------------------------------------- |
| `round` | `bigint` | NO       | The round number of the randomness used. |
| `block` | `text`   | NO       | CID of the block.                        |

## Messages
### messages

Validated on-chain messages by their CID and their metadata.

- Task: `message`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column        | Type      | Nullable | Description                                                                                                                                                                         |
| ------------- | --------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cid`         | `text`    | NO       | CID of the message.                                                                                                                                                                 |
| `from`        | `text`    | NO       | Address of the actor that sent the message.                                                                                                                                         |
| `to`          | `text`    | NO       | Address of the actor that received the message.                                                                                                                                     |
| `size_bytes`  | `bigint`  | NO       | Size of the serialized message in bytes.                                                                                                                                            |
| `nonce`       | `bigint`  | NO       | The message nonce, which protects against duplicate messages and multiple messages with the same values.                                                                            |
| `value`       | `numeric` | NO       | Amount of FIL (in attoFIL) transferred by this message.                                                                                                                             |
| `gas_fee_cap` | `numeric` | NO       | The maximum price that the message sender is willing to pay per unit of gas.                                                                                                        |
| `gas_premium` | `numeric` | NO       | The price per unit of gas (measured in attoFIL/gas) that the message sender is willing to pay (on top of the BaseFee) to "tip" the miner that will include this message in a block. |
| `method`      | `bigint`  | YES      | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution.   |
| `height`      | `bigint`  | NO       | Epoch this message was executed at.                                                                                                                                                 |

### receipts

Message receipts after being applied to chain state by message CID and parent state root CID of tipset when message was executed.

- Task: `receipt`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column       | Type     | Nullable | Description                                                                                                                                                                                                                                 |
| ------------ | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `message`    | `text`   | NO       | CID of the message this receipt belongs to.                                                                                                                                                                                                 |
| `state_root` | `text`   | NO       | CID of the parent state root that this epoch.                                                                                                                                                                                               |
| `idx`        | `bigint` | NO       | Index of message indicating execution order.                                                                                                                                                                                                |
| `exit_code`  | `bigint` | NO       | The exit code that was returned as a result of executing the message. Exit code 0 indicates success. Codes 0-15 are reserved for use by the runtime. Codes 16-31 are common codes shared by different actors. Codes 32+ are actor specific. |
| `gas_used`   | `bigint` | NO       | A measure of the amount of resources (or units of gas) consumed, in order to execute a message.                                                                                                                                             |
| `height`     | `bigint` | NO       | Epoch the message was executed and receipt generated.                                                                                                                                                                                       |

### parsed_messages

Messages parsed to extract useful information.

- Task: `parsed_message`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column   | Type      | Nullable | Description                                                     |
| -------- | --------- | -------- | --------------------------------------------------------------- |
| `cid`    | `text`    | NO       | CID of the message.                                             |
| `height` | `bigint`  | NO       | Epoch this message was executed at.                             |
| `from`   | `text`    | NO       | Address of the actor that sent the message.                     |
| `to`     | `text`    | NO       | Address of the actor that received the message.                 |
| `value`  | `numeric` | NO       | Amount of FIL (in attoFIL) transferred by this message.         |
| `method` | `text`    | NO       | The name of the method that was invoked on the recipient actor. |
| `params` | `jsonb`   | YES      | Method parameters parsed and serialized as a JSON object.       |

### internal_messages

Messages generated implicitly by system actors and by using the runtime send method.

- Task: `internal_messages`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column           | Type      | Nullable | Description                                                                                                                                                                                                                                 |
| ---------------- | --------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height`         | `bigint`  | NO       | Epoch this message was executed at.                                                                                                                                                                                                         |
| `cid`            | `text`    | NO       | CID of the message.                                                                                                                                                                                                                         |
| `state_root`     | `text`    | NO       | CID of the parent state root at which this message was executed.                                                                                                                                                                            |
| `source_message` | `text`    | YES      | CID of the message that caused this message to be sent.                                                                                                                                                                                     |
| `from`           | `text`    | NO       | Address of the actor that sent the message.                                                                                                                                                                                                 |
| `to`             | `text`    | NO       | Address of the actor that received the message.                                                                                                                                                                                             |
| `value`          | `numeric` | NO       | Amount of FIL (in attoFIL) transferred by this message.                                                                                                                                                                                     |
| `method`         | `bigint`  | NO       | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution.                                                           |
| `actor_name`     | `text`    | NO       | The full versioned name of the actor that received the message (for example fil/3/storagepower).                                                                                                                                            |
| `actor_family`   | `text`    | NO       | The short unversioned name of the actor that received the message (for example storagepower).                                                                                                                                               |
| `exit_code`      | `bigint`  | NO       | The exit code that was returned as a result of executing the message. Exit code 0 indicates success. Codes 0-15 are reserved for use by the runtime. Codes 16-31 are common codes shared by different actors. Codes 32+ are actor specific. |
| `gas_used`       | `bigint`  | NO       | A measure of the amount of resources (or units of gas) consumed, in order to execute a message.                                                                                                                                             |

### internal_parsed_messages

Internal messages parsed to extract useful information.

- Task: `internal_parsed_messages`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column   | Type      | Nullable | Description                                                                                                                                                                       |
| -------- | --------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height` | `bigint`  | NO       | Epoch this message was executed at.                                                                                                                                               |
| `cid`    | `text`    | NO       | CID of the message.                                                                                                                                                               |
| `from`   | `text`    | NO       | Address of the actor that sent the message.                                                                                                                                       |
| `to`     | `text`    | NO       | Address of the actor that received the message.                                                                                                                                   |
| `value`  | `numeric` | NO       | Amount of FIL (in attoFIL) transferred by this message.                                                                                                                           |
| `method` | `text`    | NO       | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution. |
| `params` | `jsonb`   | YES      | Method parameters parsed and serialized as a JSON object.                                                                                                                         |

### vm_messages

Messages sent internally through the VM not appearing on chain. Requires the environment variable `LOTUS_VM_ENABLE_TRACING=1` to be set before running the lily daemon command.

- Task: `vm_messages`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column       | Type      | Nullable | Description                                                                                                                                                                     |
| ------------ | --------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `height`     | `bigint`  | NO       | Height message was executed at.                                                                                                                                                 |
| `state_root` | `text`    | NO       | CID of the parent state root at which this message was executed.                                                                                                                |
| `cid`        | `text`    | NO       | CID of the message (note this CID does not appear on chain).                                                                                                                    |
| `source`     | `text`    | NO       | CID of the on-chain message or implicit (internal) message that caused this message to be sent.                                                                                 |
| `from`       | `text`    | NO       | Address of the actor that sent the message.                                                                                                                                     |
| `to`         | `text`    | NO       | Address of the actor that received the message.                                                                                                                                 |
| `value`      | `numeric` | NO       | Amount of FIL (in attoFIL) transferred by this message.                                                                                                                         |
| `method`     | `bigint`  | NO       | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method execution |
| `actor_code` | `text`    | NO       | The CID of the actor that received the message.                                                                                                                                 |
| `exit_code`  | `bigint`  | NO       | The exit code that was returned as a result of executing the message.                                                                                                           |
| `gas_used`   | `bigint`  | NO       | A measure of the amount of resources (or units of gas) consumed, in order to execute a message.                                                                                 |
| `params`     | `jsonb`   | YES      | Message parameters parsed and serialized as a JSON object.                                                                                                                      |
| `returns`    | `jsonb`   | YES      | Result returned from executing a message parsed and serialized as a JSON object.                                                                                                |

## Derived
### chain_consensus

Height and TipSet to Parent TipSet or Null Round.

- Task: `chain_consensus`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column            | Description                                      |
| ----------------- | ------------------------------------------------ |
| height            | Epoch when the blocks were mined in this tipset. |
| tip_set           | CID of the tipset or `NULL_ROUND`                |
| parent_tip_set    | CID of the parent tipset                         |
| parent_state_root | CID of the parent tipset state root              |

### chain_economics

Economic summaries per state root CID.

- Task: `chain_economics`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                  | Type      | Nullable | Description                                                                                                  |
| ----------------------- | --------- | -------- | ------------------------------------------------------------------------------------------------------------ |
| `height`                | `bigint`  | NO       | Epoch of the economic summary.                                                                               |
| `parent_state_root`     | `text`    | NO       | CID of the parent state root.                                                                                |
| `circulating_fil`       | `numeric` | NO       | The amount of FIL (attoFIL) circulating and tradeable in the economy. The basis for Market Cap calculations. |
| `vested_fil`            | `numeric` | NO       | Total amount of FIL (attoFIL) that is vested from genesis allocation.                                        |
| `mined_fil`             | `numeric` | NO       | The amount of FIL (attoFIL) that has been mined by storage miners.                                           |
| `burnt_fil`             | `numeric` | NO       | Total FIL (attoFIL) burned as part of penalties and on-chain computations.                                   |
| `locked_fil`            | `numeric` | NO       | The amount of FIL (attoFIL) locked as part of mining, deals, and other mechanisms.                           |
| `fil_reserve_disbursed` | `numeric` | NO       | The amount of FIL (attoFIL) that has been disbursed from the mining reserve.                                 |

### derived_gas_outputs

Derived gas costs resulting from execution of a message in the VM.

- Task: `derived_gas_outputs`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                 | Type      | Nullable | Description                                                                                                                                                                                                                                                  |
| ---------------------- | --------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `cid`                  | `text`    | NO       | CID of the message.                                                                                                                                                                                                                                          |
| `from`                 | `text`    | NO       | Address of actor that sent the message.                                                                                                                                                                                                                      |
| `to`                   | `text`    | NO       | Address of actor that received the message.                                                                                                                                                                                                                  |
| `value`                | `numeric` | NO       | The FIL value transferred (attoFIL) to the message receiver.                                                                                                                                                                                                 |
| `gas_fee_cap`          | `numeric` | NO       | The maximum price that the message sender is willing to pay per unit of gas.                                                                                                                                                                                 |
| `gas_premium`          | `numeric` | NO       | The price per unit of gas (measured in attoFIL/gas) that the message sender is willing to pay (on top of the BaseFee) to "tip" the miner that will include this message in a block.                                                                          |
| `gas_limit`            | `bigint`  | YES      | A hard limit on the amount of gas (i.e., number of units of gas) that a message’s execution should be allowed to consume on chain. It is measured in units of gas.                                                                                           |
| `size_bytes`           | `bigint`  | YES      | Size in bytes of the serialized message.                                                                                                                                                                                                                     |
| `nonce`                | `bigint`  | YES      | The message nonce, which protects against duplicate messages and multiple messages with the same values.                                                                                                                                                     |
| `method`               | `bigint`  | YES      | The method number to invoke. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method exectution.                                                                                                 |
| `state_root`           | `text`    | NO       | CID of the parent state root.                                                                                                                                                                                                                                |
| `exit_code`            | `bigint`  | NO       | The exit code that was returned as a result of executing the message. Exit code 0 indicates success. Codes 0-15 are reserved for use by the runtime. Codes 16-31 are common codes shared by different actors. Codes 32+ are actor specific.                  |
| `gas_used`             | `bigint`  | NO       | A measure of the amount of resources (or units of gas) consumed, in order to execute a message.                                                                                                                                                              |
| `parent_base_fee`      | `numeric` | NO       | The set price per unit of gas (measured in attoFIL/gas unit) to be burned (sent to an unrecoverable address) for every message execution.                                                                                                                    |
| `base_fee_burn`        | `numeric` | NO       | The amount of FIL (in attoFIL) to burn as a result of the base fee. It is parent_base_fee (or gas_fee_cap if smaller) multiplied by gas_used. Note: successful window PoSt messages are not charged this burn.                                               |
| `over_estimation_burn` | `numeric` | NO       | The fee to pay (in attoFIL) for overestimating the gas used to execute a message. The overestimated gas to burn (gas_burned) is a portion of the difference between gas_limit and gas_used. The over_estimation_burn value is gas_burned \* parent_base_fee. |
| `miner_penalty`        | `numeric` | NO       | Any penalty fees (in attoFIL) the miner incured while executing the message.                                                                                                                                                                                 |
| `miner_tip`            | `numeric` | NO       | The amount of FIL (in attoFIL) the miner receives for executing the message. Typically it is gas_premium \* gas_limit but may be lower if the total fees exceed the gas_fee_cap.                                                                             |
| `refund`               | `numeric` | NO       | The amount of FIL (in attoFIL) to refund to the message sender after base fee, miner tip and overestimation amounts have been deducted.                                                                                                                      |
| `gas_refund`           | `bigint`  | NO       | The overestimated units of gas to refund. It is a portion of the difference between gas_limit and gas_used.                                                                                                                                                  |
| `gas_burned`           | `bigint`  | NO       | The overestimated units of gas to burn. It is a portion of the difference between gas_limit and gas_used.                                                                                                                                                    |
| `height`               | `bigint`  | NO       | Epoch this message was executed at.                                                                                                                                                                                                                          |
| `actor_name`           | `text`    | NO       | Human readable identifier for the type of the actor.                                                                                                                                                                                                         |

### message_gas_economy

Gas economics for all messages in all blocks at each epoch.

- Task: `message_gas_economy`
- Network Range: [`v0` - `v∞`)
- Epoch Range: [`0` - `∞`)

| Column                   | Type               | Nullable | Description                                                                                                                               |
| ------------------------ | ------------------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `state_root`             | `text`             | NO       | CID of the parent state root at this epoch.                                                                                               |
| `gas_limit_total`        | `numeric`          | NO       | The sum of all the gas limits.                                                                                                            |
| `gas_limit_unique_total` | `numeric`          | YES      | The sum of all the gas limits of unique messages.                                                                                         |
| `base_fee`               | `numeric`          | NO       | The set price per unit of gas (measured in attoFIL/gas unit) to be burned (sent to an unrecoverable address) for every message execution. |
| `base_fee_change_log`    | `double precision` | NO       | The logarithm of the change between new and old base fee.                                                                                 |
| `gas_fill_ratio`         | `double precision` | YES      | The gas_limit_total / target gas limit total for all blocks.                                                                              |
| `gas_capacity_ratio`     | `double precision` | YES      | The gas_limit_unique_total / target gas limit total for all blocks.                                                                       |
| `gas_waste_ratio`        | `double precision` | YES      | (gas_limit_total - gas_limit_unique_total) / target gas limit total for all blocks.                                                       |
| `height`                 | `bigint`           | NO       | Epoch these economics apply to.                                                                                                           |


## FEVM
### fevm_block_headers

Blocks included in tipsets at an epoch.

- Task: `fevm_block_header`
- Network Range: [`v18` - `v∞`)
- Epoch Range: [`2683348` - `∞`)

| Column              | Type     | Nullable | Description                                                                                     |
| ------------------- | -------- | -------- | ----------------------------------------------------------------------------------------------- |
| `height`            | `bigint` | NO       | Epoch when this block was mined.                                                                |
| `hash`              | `text`   | NO       | Block hash.                                                                                     |
| `parent_hash`       | `text`   | NO       | The hash of the preceding block.                                                                |
| `miner`             | `text`   | NO       | ETH Address of the miner who mined this block.                                                  |
| `state_root`        | `text`   | NO       | Block state root ETH hash.                                                                      |
| `transactions_root` | `text`   | NO       | Set to a hardcoded value which is used by some clients to determine if has no transactions.     |                                       
| `receipts_root`     | `text`   | NO       | Hash of the transaction receipts trie.                                                          |
| `difficulty`        | `bigint` | NO       | ETH mining difficulty.                                                                          |
| `number`            | `bigint` | NO       | The number of the current block.                                                                |
| `gas_limit`         | `bigint` | NO       | Maximum gas allowed in this block.                                                              |
| `gas_used`          | `bigint` | NO       | The actual amount of gas used in this block.                                                    |
| `timestamp`         | `bigint` | NO       | The block time.                                                                                 |
| `extra_data`        | `text`   | YES      | Arbitrary additional data as raw bytes.                                                         |
| `base_fee_per_gas`  | `text`   | NO       | The base fee value.                                                                             |
| `size`              | `bigint` | NO       | Block size.                                                                                     |

### fevm_transactions

Transactions, which change the state of the EVM, need to be broadcast to the whole network.


- Task: `fevm_transaction`
- Network Range: [`v18` - `v∞`)
- Epoch Range: [`2683348` - `∞`)

| Column                    | Type     | Nullable | Description                                                                                     |
| --------------------------| -------- | -------- | ----------------------------------------------------------------------------------------------- |
| `height`                  | `bigint` | NO       | Epoch when this transaction been created.                                                       |
| `hash`                    | `text`   | NO       | Hash of transaction.                                                                            |
| `transaction_index`       | `bigint` | NO       | Integer of the transactions index position in the block.                                        |
| `block_hash`              | `text`   | NO       | Hash of the block where this transaction was in.                                                |
| `block_number`            | `bigint` | NO       | Block number where this transaction was in.                                                     |
| `nonce`                   | `bigint` | NO       | A sequentially incrementing counter which indicates the transaction number from the account.    |
| `from`                    | `text`   | NO       | Address of the sender.                                                                          |    
| `to`                      | `text`   | NO       | Address of the receiver. null when its a contract creation transaction.                         |
| `chain_id`                | `bigint` | NO       | EVM network id.                                                                                 |
| `value`                   | `text`   | NO       | Amount of attoFIL to transfer from sender to recipient.                                             |
| `input`                   | `text`   | NO       | The data sent along with the transaction.                                                       |
| `type`                    | `text`   | NO       | Type of transactions.                                                                           |
| `gas`                     | `bigint` | NO       | Gas provided by the sender.                                                                     |
| `max_fee_per_gas`         | `numeric`| NO       | The maximum fee per unit of gas willing to be paid for the transaction.                         |
| `max_priority_fee_per_gas`| `numeric`| NO       | The maximum price of the consumed gas to be included as a tip to the validator.                 |
| `v`                       | `bigint` | NO       | Transaction’s signature. Recovery Identifier.                                                   |
| `r`                       | `bigint` | NO       | Transaction’s signature. Outputs of an ECDSA signature.                                         |
| `s`                       | `bigint` | NO       | Transaction’s signature. Putputs of an ECDSA signature.                                         |


### fevm_receipts

Data returned by an Ethereum client to represent the result of a particular transaction

- Task: `fevm_receipt`
- Network Range: [`v18` - `v∞`)
- Epoch Range: [`2683348` - `∞`)

| Column               | Type     | Nullable | Description                                                                                     |
| ---------------------| -------- | -------- | ----------------------------------------------------------------------------------------------- |
| `height`             | `bigint` | NO       | Epoch when this receipt been created.                                                           |
| `transaction_hash`   | `text`   | NO       | Hash of transaction.                                                                            |
| `transaction_index`  | `bigint` | NO       | Integer of the transactions index position in the block.                                        |
| `block_hash`         | `text`   | NO       | Hash of the block where this transaction was in.                                                |
| `block_number`       | `bigint` | NO       | Block number where this transaction was in.                                                     |
| `from`               | `text`   | NO       | Address of the sender.                                                                          |                                       
| `to`                 | `text`   | NO       | Address of the receiver. null when its a contract creation transaction.                         |
| `contract_address`   | `text`   | YES      | The contract address created, if the transaction was a contract creation, otherwise null.       |
| `status`             | `bigint` | NO       | 0 indicates transaction failure , 1 indicates transaction succeeded.                            |
| `cumulative_gas_used`| `bigint` | NO       | The total amount of gas used when this transaction was executed in the block.                   |
| `gas_used`           | `bigint` | NO       | The actual amount of gas used in this block.                                                    |
| `effective_gas_price`| `bigint` | NO       | The actual value per gas deducted from the senders account.                                     |
| `logs_bloom`         | `text`   | YES      | Includes the bloom filter representation of the logs.                                           |
| `logs`               | `jsonb`  | NO       | Array of log objects, which this transaction generated.                                         |
| `message`            | `text`   | NO       | The cid in filecoin                                                                             |


### fevm_trace

Messages sent internally through the VM not appearing on chain.

- Task: `fevm_traces`
- Network Range: [`v18` - `v∞`)
- Epoch Range: [`2683348` - `∞`)

| Column                 | Type     | Nullable | Description                                                                                     |
| -----------------------| -------- | -------- | ----------------------------------------------------------------------------------------------- |
| `height`               | `bigint` | NO       | Epoch when this trace been created.                                                             |
| `message_state_toot`   | `text`   | NO       | StateRoot message was applied to.                                                               |
| `message_cid`          | `text`   | NO       | On-chain message triggering the message.                                                        |
| `transaction_hash`     | `text`   | NO       | On-chain message ETH transaction hash.                                                          |
| `trace_cid`            | `text`   | NO       | Cid of the trace.                                                                               |
| `from`                 | `text`   | NO       | Address of the sender.                                                                          |                                       
| `to`                   | `text`   | YES      | Address of the receiver. null when its a contract creation transaction.                         |
| `from_filecoin_address`| `text`   | NO       | Filecoin Address of the sender.                                                                 |
| `to_filecoin_address`  | `text`   | YES      | Filecoin Address of the receive.                                                                |
| `value`                | `numeric`| NO       | Value attoFIL contained in message.                                                             |
| `method`               | `bigint` | NO       | Method called on To (receiver).                                                                 |
| `parsed_method`        | `text`   | NO       | Method in readable name.                                                                        |
| `actor_code`           | `text`   | NO       | ActorCode of To (receiver).                                                                     |
| `exit_code`            | `bigint` | NO       | ExitCode of message execution.                                                                  |
| `params`               | `text`   | NO       | Params contained in message encode in eth bytes.                                                |
| `returns`              | `text`   | NO       | Returns value of message receipt encode in eth bytes.                                           |
| `index`                | `bigint` | NO       | Index indicating the order of the messages execution.                                           |
| `parsed_params`        | `jsonb`  | NO       | Parsed `Params` contained in message.                                                           |
| `parsed_returns`       | `jsonb`  | NO       | Parsed `Returns` value of message receipt.                                                      |
| `params_codec`         | `bigint` | NO       | Params codec.                                                                                   |
| `returns_codec`        | `bigint` | NO       | Returns codec.                                                                                  |


