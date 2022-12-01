---
title: "Chain Models"
description: "Lily relational data is formatted per the Lily data models."
lead: "Lily relational data format is defined according to the following models, each corresponding to a table."
menu:
  data:
    parent: "data"
    identifier: "chain models"
weight: 10
toc: true

---

---
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

## parsed_messages

Messages parsed to extract useful information. This model only contains executed messages whose receipt contained a successful exit code.

| Column | Description                                                  |
| ------ | ------------------------------------------------------------ |
| height | Epoch this message was executed at.                          |
| cid    | CID of the message.                                          |
| from   | Address of the actor that sent the message.                  |
| to     | Address of the actor that received the message.              |
| value  | Amount of FIL (in attoFIL) transferred by this message.      |
| method | The name of the method that was invoked on the recipient actor. |
| params | Method parameters parsed and serialized as a JSON object.    |

## receipts

Message [Receipts](https://spec.filecoin.io/#section-systems.filecoin_vm.runtime.receipts) resulting from the result of a top-level message execution.

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Epoch the message was executed and receipt generated.        |
| message    | CID of the message this receipt belongs to.                  |
| state_root | CID of the parent state root that this epoch.                |
| idx        | Index of message indicating execution order.                 |
| exit_code  | The [exit code](https://spec.filecoin.io/#section-systems.filecoin_vm.runtime.exit-codes) that was returned as a result of executing the message. |
| gas_used   | A measure of the amount of resources (or units of gas) consumed, in order to execute a message. |

## vm_messages

Messages sent internally by the VM not appearing on-chain resulting from the application of an on-chain message or internal message. This model will only contain messages whose `source` message was applied successfully.

##### Supported Epoch Range: 1 - ∞

| Column     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| height     | Height message was executed at.                              |
| state_root | CID of the parent state root at which this message was executed. |
| cid        | CID of the message (Note this CID does not appear on chain). |
| source     | CID of the message that caused this message to be sent. (Note: this CID will not appear on chain if source was an internal_message,) |
| from       | Address of the actor that sent the message.                  |
| to         | Address of the actor that received the message.              |
| value      | Amount of FIL (in attoFIL) transferred by this message.      |
| method     | The method number invoked on the recipient actor. Only unique to the actor the method is being invoked on. A method number of 0 is a plain token transfer - no method execution. |
| actor_code | The CID of the actor that received the message.              |
| exit_code  | The exit code that was returned as a result of executing the message. |
| gas_used   | A measure of the amount of resources (or units of gas) consumed, in order to execute a message. |
| params     | Message parameters parsed and serialized as a JSON object.   |
| returns    | Result returned from executing a message parsed and serialized as a JSON object |

