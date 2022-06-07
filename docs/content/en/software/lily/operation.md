---
title: "Lily Operation Guide"
linkTitle: "Operation"
description: "This guide covers the management of jobs and tasks which result in data extraction from the Filecoin chain that the Lily node is following."
lead: "When the lily daemon is started, it acts as a long-running process which coordinates the requested Jobs and directs data to specific storage targets. In order to interact with the daemon, the CLI also accepts commands which are communicated to the running daemon. This guide covers the management of jobs and tasks which result in data extraction from the Filecoin chain that the Lily node is following."
menu:
  software:
    parent: "lily"
    identifier: "operation"
weight: 30
toc: true
---

---

## API endpoint

When the daemon is started, the repo path is where this communication coordination is handled. The repo path contains information about where the JSON RPC API is (`api` file located in repo path) located, along with an authentication token used (`token` file) for writeable interactions. For more details, see the [Lotus API documentation](https://lotus.filecoin.io/reference/basics/api-access/).

The IP/port to which the daemon binds can be managed via the `--api` flag. By default, the daemon binds to `localhost` and will be unavailable externally unless bound to a publicly-accessible IP.

---

## Jobs

Once the Lily daemon process is [running and fully synced](setup.md), you may manage its Jobs through the CLI. (Note: behavior is undefined if Lily is not fully synced, so one may gate the Job creation to wait for the sync to complete with `lily sync wait && lily ...`.).

Jobs may be executed on a lily node via the `job run` command. The `job run` command accepts the following flags:
- `--window` duration after which job execution will be canceled while processing a tipset.
- `--tasks` specify the list of [tasks](#tasks) to run by this job. Some tasks [will be heavier than others](hardware.md). A tipset is only processed when all tasks in the job have finished. Only then will Lily move to the next epoch. The default value of this flag if omitted is all tasks lily is capable of performing.
- `--storage` specifies which of the configured storage outputs the job will write to.
- `--name` specifies the name of the job for easy identification later. The provided value
  will appear as `reporter` in the `visor_processing_reports` table.
- `--restart-delay` duration to wait before restarting job after it ends execution.
- `--restart-on-failure` specifies if a job should be restarted if it fails.
- `--restart-on-completion` specifies if a job should be restarted once it completes.

Currently, Lily is capable of executing the following types of jobs:

### Watch
The Watch command subscribes to incoming tipsets from the filecoin blockchain and indexes them as they arrive.

Since it may be the case that tipsets arrive at a rate greater than lily's rate of indexing, the watch job maintains a
buffer of tipsets to index. Consumption of this queue can be configured via the `--workers` flag. Increasing the value
provided to the `--workers` flag will allow the watch job to index tipsets simultaneously.
(Note: this will use a significant amount of system resources).

While watching a network with distributed consensus, participants may occasionally have intermittent connectivity problems, which cause some nodes to have different views of the blockchain HEAD. Eventually, the connectivity issues resolve, the nodes connect, and they reconcile their differences. The node which is found to be on the wrong branch will reorganize its local state to match the new network consensus by "unwinding" the incorrect chain of tipsets up to the point of disagreement (the "fork") and then applying the correct chain of tipsets. This can be referred to as a "reorg." The number of tipsets that are "unwound" from the incorrect chain is called "reorg depth."

Lily uses a "confidence" FIFO cache, which gives the operator confidence that the tipsets that are being processed and persisted are unlikely to be reorganized. A confidence of 100 would establish a cache that will fill with as many tipsets. Once the 101st tipset is unshifted onto the cache stack, the 1st tipset would be popped off the bottom and have the Tasks processed over it. In the event of a reorg, the most recent tipsets are shifted off the top, and the correct tipsets are unshifted in their place.

Example:

```
$ lily job run watch --confidence=10
```

A visualization of the confidence cache during normal operation. Data is only extracted from tipsets marked with `(process)`:

```
             *unshift*        *unshift*      *unshift*       *unshift*
                │  │            │  │            │  │            │  │
             ┌──▼──▼──┐      ┌──▼──▼──┐      ┌──▼──▼──┐      ┌──▼──▼──┐
             │        │      │  ts10  │      │  ts11  │      │  ts12  │
   ...  ---> ├────────┤ ---> ├────────┤ ---> ├────────┤ ---> ├────────┤ --->  ...
             │  ts09  │      │  ts09  │      │  ts10  │      │  ts11  │
             ├────────┤      ├────────┤      ├────────┤      ├────────┤
             │  ts08  │      │  ts08  │      │  ts09  │      │  ts10  │
             ├────────┤      ├────────┤      ├────────┤      ├────────┤
             │  ...   │      │  ...   │      │  ...   │      │  ...   │
             ├────────┤      ├────────┤      ├────────┤      ├────────┤
             │  ts02  │      │  ts02  │      │  ts03  │      │  ts04  │
             ├────────┤      ├────────┤      ├────────┤      ├────────┤
             │  ts01  │      │  ts01  │      │  ts02  │      │  ts03  │
             ├────────┤      ├────────┤      ├────────┤      ├────────┤
             │  ts00  │      │  ts00  │      │  ts01  │      │  ts02  │
             └────────┘      └────────┘      └──│──│──┘      └──│──│──┘
                                                ▼  ▼  *pop*     ▼  ▼  *pop*
                                             ┌────────┐      ┌────────┐
              (confidence=10 :: length=10)   │  ts00  │      │  ts01  │
                                             └────────┘      └────────┘
                                              (process)       (process)


```

A visualization of the confidence cache during a reorg of depth=2:

```
  *unshift*    *shift*    *shift*  *unshift*  *unshift*  *unshift*
     │  │       ▲  ▲       ▲  ▲       │  │       │  │       │  │
   ┌─▼──▼─┐   ┌─│──│─┐   ┌─│──│─┐   ┌─│──│─┐   ┌─▼──▼─┐   ┌─▼──▼─┐
   │ ts10 │   │      │   │ │  │ │   │ │  │ │   │ ts10'│   │ ts11'│
   ├──────┤   ├──────┤   ├─│──│─┤   ├─▼──▼─┤   ├──────┤   ├──────┤
   │ ts09 │   │ ts09 │   │      │   │ ts09'│   │ ts09'│   │ ts10'│
   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤
   │ ts08 │   │ ts08 │   │ ts08 │   │ ts08 │   │ ts08 │   │ ts09'│
   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤
   │ ...  │ > │ ...  │ > │ ...  │ > │ ...  │ > │ ...  │ > │ ...  │
   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤
   │ ts02 │   │ ts02 │   │ ts02 │   │ ts02 │   │ ts02 │   │ ts03 │
   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤
   │ ts01 │   │ ts01 │   │ ts01 │   │ ts01 │   │ ts01 │   │ ts02 │
   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤   ├──────┤
   │ ts00 │   │ ts00 │   │ ts00 │   │ ts00 │   │ ts00 │   │ ts01 │
   └──────┘   └──────┘   └──────┘   └──────┘   └──────┘   └─│──│─┘
                                                            ▼  ▼  *pop*
               reorg                            reorg     ┌──────┐
               occurs                          resolves   │ ts00 │
                here                             here     └──────┘
                                                          (process)

```

Low confidence values may risk that Lily extracts data from tipsets that are not part of the final chain, which is something that you may want or not, depending on what you are trying to index.

#### Constraints

- Lily's sync of the filecoin blockchain must be completed before starting a watch job. Users of lily may run the `lily sync wait` command to check if their node has completed syncing the chain. The command will exit when sync is complete.

### Walk
The Walk command will index the state based on the list of tasks (`--tasks`) provided over the specified range
(`--from`, `--to`). Each epoch will be indexed serially, starting from the heaviest tipset at the upper height
(`--to`) to the lower height (`--from`).

#### Constraints

- Walk jobs may only be executed over epoch ranges lily has state. Walking ranges lily does not have a state for will result in the error: `blockstore: block not found` being written to the `errors_detected` column of the `visor_processing_reports` table.

### Find
The Find job searches for gaps in a database storage system by executing the SQL `gap_find()` function over the
`visor_processing_reports` table. Find will query the database for gaps based on the list of tasks (`--tasks`) provided
over the specified range (`--from`,`--to`). An epoch is considered to have gaps if and only if:

1. Tasks specified by the `--tasks` flag are not present at each epoch within the specified range.
2. Task specified by the `--tasks` flag do not have the status `'OK'` at each epoch within the specified range.
    The find job results are written to the `visor_gap_reports` table with the status `'GAP'`.

#### Constraints

- The Find job must be executed **BEFORE** a Fill job. These jobs must **NOT** be performed simultaneously.
- Do not execute the Find job over epoch ranges imported from the lily data archive as there are no processing reports for imported data.   

### Fill
The Fill job queries the `visor_gap_reports` table for gaps to fill and indexes the data reported to have gaps.
A gap in the `visor_gap_reports` table is any row with the status `'GAP'`. Fill will index gaps based on the list
of tasks (`--tasks`) provided over the specified range (`--from`, `--to`). Each epoch and its corresponding list of
tasks found in the `visor_gap_reports` table will be indexed independently. When the gap is successfully
filled, its corresponding entry in the `visor_gap_reports` table will be updated with' FILLED' status.

#### Constraints

- The Fill job must be executed **AFTER** a Find job. These jobs must **NOT** be performed simultaneously.
- Walk jobs may only be executed over epoch ranges lily has state. Walking ranges lily does not have a state for will result in the error: `blockstore: block not found` being written to the `errors_detected` column of the `visor_processing_reports` table.
- Do not execute the Fill job over epoch ranges imported from the lily data archive as there are no processing reports for imported data.

### Survey

The Survey job collects information on the filecoin peer agents lily is connected to. The frequency at which lily collects this information may be configured via the `--interval` flag. Currently, this job only has one task type: `peeragents`. Note that this task name is distinct from the task names `watch`, `walk`, `find`, and `fill` jobs accept.

## Distributed TipSet Workers

Lily may be configured to use Redis as a distributed task queue to distribute work across multiple lily instances. When configured this way the system of lily nodes can consist of multiple `Workers` and a single `Notifier` :

- The `Notifier` puts tasks into a queue for execution by a `Worker`.
- The `Workers` remove tasks from the queue for execution.

The configuration described here should be used when multiple machines are available for running lily nodes as it allows the work of processing tasks to be distributed across a pool of machines. Internally, lily uses [asynq](https://github.com/hibiken/asynq) for distributed task queue orchestration.

### Notifier

A lily node may be configured to operate as a notifier using the `notify` subcommand on the `watch`, `walk`, and `fill` commands. For example:
```bash
$ lily job run --tasks=block_header watch notify --queue="Notifier1"
```

will cause the watch job to insert tasks into the queue based on the configuration with the name `Notifier1`. In this mode of operation, lily will distribute watch tasks to a Redis queue for consumption by `Workers` instead of performing the indexing locally. The values specified by the `--task` flag will be passed along to the `Workers`, however, the `--storage` flag will be ignored since lily isn't processing the watch tasks locally. 

Similar to the above watch command, the walk command below:

```bash
$ lily job run walk --from=100 --to=200 notify --queue="Notifier1"
```

will cause the walk job to insert tasks into the queue configuration with the name `Notifier1` as they are walked by the notifier.

### Worker

A lily node may be configured to operate as a worker using the `tipset-worker` command. A `tipset-worker` consumes tasks (produced by a `notifier`) from a Redis queue and processes them. For example, the below command starts a `tipset-worker` that consumes tasks based on the configuration with the name `Worker1`:
```bash
$ lily job run --storage="Database1" tipset-worker --queue="Worker1"
```

In this mode of operation, lily will pull tasks from a Redis instance for processing, writing the results to the storage backend at configuration `Database1`. Below is an example of a `Worker` configuration:

```toml
[Queue.Workers.Worker1]
  [Queue.Workers.Worker1.RedisConfig]
    Network = "tcp"
    Addr = "localhost:6379"
    Username = "default"
    PasswordEnv = "LILY_REDIS_PASSWORD"
    DB = 0
    PoolSize = 0
[Queue.Workers.Worker1.WorkerConfig]
    # Defines how many tasks a worker may process in parallel
    Concurrency = 1
    # Logging level of internal task system
    LoggerLevel = "debug"
    # Priorities of corresponding queues:
    #   processes Watch tasks 50% of the time.
    #   processes Fill tasks 30% of the time.
    #   processes Index tasks 10% of the time.
    #   processes Walk tasks 10% of the time
    WatchQueuePriority = 5
    FillQueuePriority = 3
    IndexQueuePriority = 1
    WalkQueuePriority = 1
    # If true, the queues with higher priority are always processed first.
    # Else queues with lower priority are processed only if all the other queues with higher priorities are empty.
    StrictPriority = false
    # Specifies the duration to wait to let workers finish their tasks
    ShutdownTimeout = 30000000000
```

## Tasks

Lily provides several tasks to capture different aspects of the blockchain state. The type of data extracted by Lily is controlled by the below tasks. Jobs accepts tasks to run as a comma-separated list. The data extracted by a task is stored in its related Models.

| Name                              |                            Model                             | Duration |
| --------------------------------- | :----------------------------------------------------------: | -------- |
| actor                             |        [actors]({{< ref "/data/models.md#actors" >}})        | 10s      |
| actor_state                       |  [actor_states]({{< ref "/data/models.md#actor_states" >}})  | 10s      |
| block_header                      | [block_headers]({{< ref "/data/models.md#block_headers" >}}) | 1s       |
| block_message                     | [block_messages]({{< ref "/data/models.md#block_messages" >}}) | 15s      |
| block_parent                      | [block_parents]({{< ref "/data/models.md#block_parents" >}}) | 1s       |
| chain_consensus                   | [chain_consensus]({{< ref "/data/models.md#chain_consensus" >}}) | 1s       |
| chain_economics                   | [chain_economics]({{< ref "/data/models.md#chain_economics" >}}) | 1s       |
| chain_power                       |  [chain_powers]({{< ref "/data/models.md#chain_powers" >}})  | 10s      |
| chain_reward                      | [chain_rewards]({{< ref "/data/models.md#chain_rewards" >}}) | 10s      |
| derived_gas_outputs               | [derived_gas_outputs]({{< ref "/data/models.md#derived_gas_outputs" >}}) | 15s      |
| drand_block_entrie                | [drand_block_entries]({{< ref "/data/models.md#drand_block_entries" >}}) | 1s       |
| id_address                        |  [id_addresses]({{< ref "/data/models.md#id_addresses" >}})  | 30s      |
| internal_messages                 | [internal_messages]({{< ref "/data/models.md#internal_messages" >}}) | 10s      |
| internal_parsed_messages          | [internal_parsed_messages]({{< ref "/data/models.md#internal_parsed_messages" >}}) | 10s      |
| market_deal_proposal              | [market_deal_proposals]({{< ref "/data/models.md#market_deal_proposals" >}}) | 30s      |
| market_deal_state                 | [market_deal_states]({{< ref "/data/models.md#market_deal_states" >}}) | 30s      |
| message                           |      [messages]({{< ref "/data/models.md#messages" >}})      | 15s      |
| message_gas_economy               | [message_gas_economy]({{< ref "/data/models.md#message_gas_economy" >}}) | 15s      |
| miner_current_deadline_info       | [miner_current_deadline_infos]({{< ref "/data/models.md#miner_current_deadline_infos" >}}) | 10s      |
| miner_fee_debt                    | [miner_fee_debts]({{< ref "/data/models.md#miner_fee_debts" >}}) | 15s      |
| miner_info                        |   [miner_infos]({{< ref "/data/models.md#miner_infos" >}})   | 30s      |
| miner_locked_fund                 | [miner_locked_funds]({{< ref "/data/models.md#miner_locked_funds" >}}) | 30s      |
| miner_pre_commit_info             | [miner_pre_commit_infos]({{< ref "/data/models.md#miner_pre_commit_infos" >}}) | 60s      |
| miner_sector_deal                 | [miner_sector_deals]({{< ref "/data/models.md#miner_sector_deals" >}}) | 60s      |
| miner_sector_event                | [miner_sector_events]({{< ref "/data/models.md#miner_sector_events" >}}) | 60s      |
| miner_sector_infos                | [miner_sector_infos]({{< ref "/data/models.md#miner_sector_infos" >}}) | 60s      |
| miner_sector_infos_v7             | [miner_sector_infos_v7]({{< ref "/data/models.md#miner_sector_infos_v7" >}}) | 60s      |
| miner_sector_post                 | [miner_sector_posts]({{< ref "/data/models.md#miner_sector_posts" >}}) | 15s      |
| multisig_approvals                | [multisig_approvals]({{< ref "/data/models.md#multisig_approvals" >}}) | 15s      |
| multisig_transaction              | [multisig_transactions]({{< ref "/data/models.md#multisig_transactions" >}}) | 15s      |
| parsed_message                    | [parsed_messages]({{< ref "/data/models.md#parsed_messages" >}}) | 15s      |
| power_actor_claim                 | [power_actor_claims]({{< ref "/data/models.md#power_actor_claims" >}}) | 15s      |
| receipt                           |      [receipts]({{< ref "/data/models.md#receipts" >}})      | 15s      |
| verified_registry_verified_client | [verified_registry_verified_clients]({{< ref "/data/models.md#verified_registry_verified_clients" >}}) | 10s      |
| verified_registry_verifier        | [verified_registry_verifiers]({{< ref "/data/models.md#verified_registry_verifiers" >}}) | 10s      |

## Job Managment

When Jobs are launched on a running daemon, a new Job (with ID) is created. These jobs may be managed using the `lily job` CLI:

```
# launch a job
$ lily job run [watch|walk|find|fill|survey|tipset-worker]

# shows all Jobs and their status
$ lily job list

# stop a running Job
$ lily job stop

# allows a stopped Job to be resumed (new Jobs are not created this way)
$ lily job start
```

Example job list output:

```
$ lily job list
[
	{
		"ID": 1,
		"Name": "custom-job-name",
		"Type": "watch",
		"Error": "",
		"Tasks": [
			"id_address",
			"receipt",
			"message_gas_economy",
			"message",
			"drand_block_entrie",
			"derived_gas_outputs",
			"chain_economics",
			"chain_consensus",
			"block_parent",
			"block_message",
			"block_header"
		],
		"Running": true,
		"RestartOnFailure": false,
		"RestartOnCompletion": false,
		"RestartDelay": 0,
		"Params": {
			"buffer": "5",
			"confidence": "5",
		},
		"StartedAt": "2022-05-27T20:58:43.054786488Z",
		"EndedAt": "0001-01-01T00:00:00Z"
	}
]
```

---


## Job Performance

Lily captures details about each Task completed within the configured storage in a table called `visor_processing_reports`. This table includes the height, state_root, reporter (via `--name` flag), task, started/completed timestamps, status, and errors (if any). This provides task-level insight into how Lily is progressing with the provided Jobs and any internal errors.

---

## Metrics & Debugging


#### Prometheus Metrics

Lily automatically exposes an HTTP endpoint which exposes internal performance
metrics. The endpoint is intended to be consumed by a
[Prometheus](https://prometheus.io/docs/introduction/overview/)
server.

Prometheus metrics are exposed by default on `http://0.0.0.0:9991/metrics` and
may be bound to a custom IP/port by passing `--prometheus-port="0.0.0.0:9991"`
on daemon startup with your custom values. `lily help monitoring` provides
more information.

A description of the metrics is included inline in the reply. A sample may be captured using curl:

```
$ curl 0.0.0.0:9991/metrics -o lily_prom_sample.txt
```
---

#### Logging

Lily emits logs about each module contained within the runtime. Their level of
verbosity can be managed on a per-module basis. A full list of registered
modules can be retrieved on the console with `$ lily log list`. All modules
have defaults set to prevent verbose output. Logging levels are one of `DEBUG,
INFO, WARN, ERROR, DPANIC, PANIC, FATAL`. Logging can also be generated in
colorized text (default), plain text, and JSON. See `lily help monitoring` for
more information.

Examples:

```
# set level for all modules via envvar
$ explore GOLOG_LOG_LEVEL="debug"
# set levels for multiple modules via envvar (can be different levels per module)
$ export GOLOG_LOG_LEVEL_NAMED="chain:debug,chainxchg:info"
# set levels for multiple modules via arg on startup
$ lily daemon --log-level-named="chain:debug,chainxchg:info"
# set levels for multiple modules via CLI (requires daemon to be running, one level per command)
$ lily log set-level --system chain --system chainxchg debug
```

---

#### Tracing

Lily is capable of exposing traces during normal runtime. This behavior is
disabled by default because there is a performance impact for these traces to
be captured. These traces are produced using Jaeger and are compatible with
[OpenCensus](https://opencensus.io/tracing/).

Jaeger tracing can be enabled by passing the `--tracing` flag on daemon
startup. There are other configuration values which have "reasonable" default
values, but should be reviewed for your use case before enabling
tracing. `lily help monitoring` provides more information about these aspects.

For example: by default, Lily uses probabilistic sampling with a rate of 0.0001. During testing it can be easier to override to remove sampling by setting
the following environment variables:

```
export JAEGER_SAMPLER_TYPE=const
export JAEGER_SAMPLER_PARAM=1
```

or by specifying `--jaeger-sampler-type=const jaeger-sampler-param=1`.

Default tracing values are preconfigured to work with OpenTelemetry's default
agent ports and assumes the agent is bound to `localhost`. Configuration of
`JAEGER_*` envvars or `--jaeger-*` args may be required if your setup is
custom.

---

#### Go debug profiles

Lily exposes runtime profiling endpoints during normal runtime. This behavior
is always available, but waits for interaction through the exposed HTTP
endpoint before capturing this data.

By default, the profiling endpoint is exposed at
`http://0.0.0.0:1234/debug/pprof`. This will serve up valid HTML to be viewed
through a browser client or this endpoint can be connected to using the `go
pprof tool` using the appropriate endpoint for the type of profile to be
captured. (See
[interacting with the pprof HTTP endpoint](https://pkg.go.dev/net/http/pprof)
for more information.)


Example: Capture local heap profile and load into pprof for analysis:

```
$ curl 0.0.0.0:1234/debug/pprof/heap -o heap.pprof.out
$ go tool pprof ./path/to/binary ./heap.pprof.out
```

Inspect profile interactively via `http://localhost:1234/debug/pprof` and host
a web interface at `http://localhost:8000` (which opens automatically once
profile is captured):

```
$ go tool pprof -http :8000 :1234/debug/pprof/heap
```
