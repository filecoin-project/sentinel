---
title: "FAQ"
linkTitle: "Frequently Asked Questions (FAQ)"
description: "Answers to frequently asked questions (FAQs) about Lily."
lead: "Answers to frequently asked questions (FAQs) about Lily."
toc: true
menu:
    software:
        parent: "lily"
        identifier: "faq"
weight: 60
---

---

## Setup

### Do I need Lotus to run Lily?

No. Lily does not need a separate Lotus node running since Lily itself is an abstraction over Lotus.

However, Lily **can** use a datastore created by Lotus.

### Do I need to use TimescaleDB with Lily?

A database instance is not required to use Lily. You can simply have a Lily node running and then run a
[walk job]({{< ref "/software/lily/operation.md#walk" >}}) over it with CSVs as a `Storage` mechanism.
These CSVs can then be loaded onto the database of your choosing.

### How much storage should I allocate for my database?

Around 4TB should be sufficient for mainnet data with a data retention policy of 3 months.

### How do I configure Lily?

You can configure Lily with the `config.toml` file.

### Where do I get the `config.toml` file?

Lily creates a `config.toml` file for you upon `lily init` if no configuration file is provided to the `--config`
option.

Lotus also provides a default `config.toml` file with the handy `lotus config default` command. You can then redirect
this into a file.

### Why didn't my config changes take effect? 

You'll need to restart the Lily daemon.

---

## Jobs

### How should I distribute tasks across jobs?

Tasks should be grouped based on the actors they process for optimal cache utilization.

### How can I backfill incomplete data?

You can run the [find job]({{< ref "/software/lily/operation.md#find >}}) and then an adhoc [fill job]({{< ref "/software/lily/operation.md#fill" >}}) to backfill missing tasks at
some specified range of epochs. This can also be run as a cron job.

### How can I tell if Lily correctly exported to the database?

You can use [gap find]({{<ref "/software/lily/operation.md#find" >}}) to search for gaps in the database. You can also
run the [gap find function](https://github.com/filecoin-project/lily/blob/master/schemas/v1/6_gap_find.go) independent of Lily with SQL.

### Why are my tasks failing?

Task failures are persisted to the `visor_processing_reports` table produced by the `find` job.

### Why is my job failing?

Check `lily job list` to see the reason for job failure.

### Can a job be successful even when tasks fail?

Yes. A job runs a set of tasks and tasks can fail while the job is successful.

---

## Syncing

### Do I need to let Lily sync until the current epoch?

Yes. If you run jobs before Lily completely syncs, there will be unexpected behavior.

### How can I make sure that Lily finishes syncing?

```shell
lily sync wait && lily ...
```

### What's a good way to check that my repo has all of the heights I need for a walk?

```shell
lily job run --tasks=actor_states,consensus,messages walk --from <min_height> --to <max_height>
```

### Why do tasks in my job fail?

This can be for multiple reasons. But the most common ones are:

- your Lily node is not fully synced
- the snapshot you used to initialize Lily does not have the state of either your minimum or maximum epoch height