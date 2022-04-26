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

When the daemon is started, the repo path is where this communication
coordination is handled. The repo path contains information about where the
JSON RPC API is (`api` file located in repo path) located along with an
authentication token used (`token` file) for writeable interactions. For more
details see the
[Lotus API documentation](https://docs.filecoin.io/build/lotus/).

The IP/port which the daemon binds to can be managed via the `config.toml` or
by passing the value to `--api`. By default, the daemon binds to `localhost`
and will be unavailable externally unless bound to a publicly-accessible IP.

---

## Jobs

Once the Lily daemon process is [running and fully synced](setup.md), you may
manage its Jobs through the CLI. (Note: behaviour is undefined if Lily is not
fully synced, so one may gate the Job creation to wait for sync to complete
with `lily sync wait && lily ...`.).

Currently, Lily accepts the following Jobs:

- `lily watch`: A Watch job follows the chain as is grows. Watch jobs
  subscribe to incoming tipsets and process them as they arrive. a confidence
  level may be specified which determines how many epochs lily should wait
  before processing a tipset.
- `lily walk`: A Walk job accepts a range of heights (`--from` and `--to`) and
  traverses the chain from the heaviest tipset set at the upper height to the
  lower height using the parent state root present in each tipset.
- `lily gap find`: A Gap-Find job walks over tables in the Postgres storage
  provided to the task and prepares the work needed to execute `lily gap
  fill`.
- `lily gap fill`: A Gap-Fill job uses the prepared work from `lily gap find`
  to execute the named `--tasks` over any detected gaps in our data.

Among the arguments that jobs take are two important ones shared by all types:
  - `--tasks` specifies the list of [tasks](#tasks) to run by this job. Some
    tasks [will be heavier than others](hardware.md). A tipset is only
    processed when all tasks in the job have finished. Only then will Lily
    move to the next epoch.
  - `--storage` specifies which of the configured storage outputs the job will write to.

When Jobs are launched on a running daemon, a new Job (with ID) is
created. These jobs may be managed using the `lily job` CLI:

```
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
        ...
        {
                "ID": 1,
                "Name": "customtaskname",
                "Type": "watch",
                "Error": "",
                "Tasks": [
                        "blocks",
                        "messages",
                        "chaineconomics",
                        "actorstatesraw",
                        "actorstatespower",
                        "actorstatesreward",
                        "actorstatesmultisig",
                        "msapprovals"
                ],
                "Running": true,
                "RestartOnFailure": true,
                "RestartOnCompletion": false,
                "RestartDelay": 0,
                "Params": {
                        "confidence": "100",
                        "storage": "db",
                        "window": "30s"
                },
                "StartedAt": "2021-08-27T21:56:49.045783716Z",
                "EndedAt": "0001-01-01T00:00:00Z"
        }
        ...
]
```


---

## Tasks

Lily provides several tasks to capture different aspects of the blockchain
state. The type of data extracted extracted by Lily is controlled by the below
tasks. Jobs accepts tasks to run as a comma separated list. The data extracted
by a task is stored in its related Models.

|        Task         |                         Description                          |                            Models                            | Duration Per Tipset (Estimate) |
| :-----------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------: |
|       blocks        |      Captures data about blocks and their relationships      | [block_headers]({{< relref "/data/models.md#block_headers" >}}), [block_parents]({{< relref "/data/models.md#block_parents" >}}), [drand_block_entries]({{< relref "/data/models.md#drand_block_entries" >}}) |              1 ms              |
|   chaineconomics    |           Captures circulating supply information.           |      [chain_economics]({{< relref "/data/models.md#drand_block_entries" >}})      |             50 ms              |
|      consensus      | Captures consensus view of the chain which includes null rounds. |        [chain_consensus]({{< relref "/data/models.md#chain_consensus" >}})        |              1 ms              |
|      messages       | Captures data about messages that were carried in a tipset's blocks. The receipt is also captured for any messages that were executed. Detailed information about gas usage by each messages as well as a summary of gas usage by all messages is also captured. The task does not produce any data until it has seen two tipsets since receipts are carried in the tipset following the one containing the messages. | [block_messages]({{< relref "/data/models.md#block_messages" >}}), [derived_gas_outputs]({{< relref "/data/models.md#derived_gas_outputs" >}}), [messages]({{< relref "/data/models.md#messages" >}}), [messages_gas_economy]({{< relref "/data/models.md#messages_gas_economy" >}}), [parsed_messages]({{< relref "/data/models.md#parsed_messages" >}}), [receipts]({{< relref "/data/models.md#receipts" >}}), |             50 ms              |
|  implicitmessage   | Captures internal message sends not appearing on chain including Multisig actor sends, Cron Event Ticks, Block and Reward Messages | [internal_messages]({{< relref "/data/models.md#internal_messages" >}}), [internal_parsed_messages]({{< relref "/data/models.md#internal_parsed_messages" >}}) |              1 ms              |
|     msapprovals     |        Captures approvals of multisig gated messages         |     [multisig_approvals]({{< relref "/data/models.md#multisig_approvals" >}})     |             10 ms              |
|   actorstatesraw    | Captures basic actor properties for any actors that have changed state and serializes a shallow form of the new state to JSON. | [actors]({{< relref "/data/models.md#actors" >}}), [actor_states]({{< relref "/data/models.md#actor_states" >}}) |             50 ms              |
| actorstatesverifreg | Captures changes to the verified registry actor and verified registry clients. | [verified_registry_verified_clients]({{< relref "/data/models.md#verified_registry_verified_clients" >}}), [verified_registry_verifiers]({{< relref "/data/models.md#verified_registry_verifiers" >}}) |             10 ms              |
| actorstatesmultisig |    Captures changes to multisig actors transaction state.    |  [multisig_transactions]({{< relref "/data/models.md#multisig_transactions" >}})  |             100 ms             |
|  actorstatesreward  | Captures changes to the reward actors state including information about miner rewards for each epoch. |           [chain_reward]({{< relref "/data/models.md#chain_reward" >}})           |             100 ms             |
|   actorstatesinit   | Captures changes to the init actor to provide mappings between canonical ID-addresses and actor addresses or public keys. |             [id_address]({{< relref "/data/models.md#id1_address" >}})             |              3 s               |
|  actorstatespower   | Captures changes to the power actors state including total power at each epoch and updates to the miner power claims. | [chain_powers]({{< relref "/data/models.md#chain_powers" >}}), [power_actor_claims]({{< relref "/data/models.md#power_actor_claims" >}}) |              5 s               |
|  actorstatesmarket  | Captures new deal proposals and changes to deal states recorded by the storage market actor. | [market_deal_proposals]({{< relref "/data/models.md#market_deal_proposals" >}}), [market_deal_states]({{< relref "/data/models.md#market_deal_states" >}}) |              10 s              |
|  actorstatesminer   | Captures changes to miner actors to provide information about sectors, posts, and locked funds. | [miner_current_deadline_infos]({{< relref "/data/models.md#miner_current_deadline_infos" >}}), [miner_fee_debts]({{< relref "/data/models.md#miner_fee_debts" >}}), [miner_locked_funds]({{< relref "/data/models.md#miner_locked_funds" >}}), [miner_infos]({{< relref "/data/models.md#miner_infos" >}}), [miner_sector_posts]({{< relref "/data/models.md#miner_sector_posts" >}}), [miner_pre_commit_infos]({{< relref "/data/models.md#miner_pre_commit_infos" >}}), [miner_sector_infos]({{< relref "/data/models.md#miner_sector_infos" >}}),            [miner_sector_events]({{< relref "/data/models.md#miner_sector_events" >}}), [miner_sector_deals]({{< relref "/data/models.md#miner_sector_deals" >}}) |              18 s              |

`lily help tasks` provides additional information about the different types of
tasks.

Example, for starting a watch job named "lily-watch-job" pointed at the
"analysis" storage target with a subset of tasks:

```
$ lily watch --name="lily-watch-job" --storage=analysis --tasks="messages, blocks, msapprovals"
```


---

## Job Confidence
  * [ ] 
A network with distributed consensus may occasionally have intermittent
connectivity problems which cause some nodes to have different views of the
true blockchain HEAD. Eventually, the connectivity issues resolve, the nodes
connect, and they reconcile their differences. The node which is found to be
on the wrong branch will reorganize its local state to match the new network
consensus by "unwinding" the incorrect chain of tipsets up to the point of
disagreement (the "fork") and then applying the correct chain of tipsets. This
can be referred to as a "reorg". The number of tipsets which are "unwound"
from the incorrect chain is referred to as "reorg depth".

Lily makes use of a "confidence" FIFO cache which gives the operator
confidence that the tipsets which are being processed and persisted are
unlikely to be reorganized. A confidence of 100 would establish a cache which
will fill with as many tipsets. Once the 101st tipset is unshifted onto the
cache stack, the 1st tipset would be popped off the bottom and have the Tasks
processed over it. In the event of a reorg, the most recent tipsets are
shifted off the top and the correct tipsets are unshifted in their place.

Example:

```
$ lily watch --confidence=10
```

A visualization of the confidence cache during normal operation. Data is only
extracted from tipsets marked with `(process)`:

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

Low confidence values may risk that Lily extracts data from tipsets that are
not part of the final chain, which is something that you may want or not,
depending on what you are trying to index.

## Timeout window

The `lily [walk|watch] --window` flag controls how long Lily let tasks
run. Since the network produces a tipset every 30 seconds, Lily will fall
behind if processing all tasks in a job takes longer than that. Thus, by
default any task(s) not completed within the window will be marked as
incomplete (shown as `SKIP` in the processing_reports table when using a
PostgreSQL storage target).

The `30s` default can be increased to accomodate deviations (i.e. sometimes
the actorstateminer task might take 40s and some other times 15s, so Lily does
not fall behind).

---


## Job performance

Lily captures details about each Task completed within the configured storage
in a table called `visor_processing_reports`. This table includes the height,
state_root, reporter (via configured [ApplicationName](setup.md)), task,
started/completed timestamps, status, and errors (if any). This provides
task-level insight on how Lily is progressing with the provided Jobs as well
as any internal errors.

---

## Metrics, traces and debugging


#### Prometheus Metrics

Lily automatically exposes an HTTP endpoint which exposes internal performance
metrics. The endpoint is intended to be consumed by a
[Prometheus](https://prometheus.io/docs/introduction/overview/)
server.

Prometheus metrics are exposed by default on `http://0.0.0.0:9991/metrics` and
may be bound to a custom IP/port by passing `--prometheus-port="0.0.0.0:9991"`
on daemon startup with your custom values. `lily help monitoring` provides
more information.

A description of the metrics are included inline in the reply. A sample may be
captured using curl:

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
