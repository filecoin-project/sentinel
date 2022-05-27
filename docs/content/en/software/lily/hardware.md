---
title: "Lily Hardware requirements"
linkTitle: "Hardware requirements"
description: "An overview of Lily's requirements for different tasks."
lead: "Lily's requirements depend on which tasks the Lily daemon is asked to run."
menu:
  software:
    parent: "lily"
    identifier: "hardware"
weight: 40
toc: true
---


Lily's base hardware requirements are
[those of a Lotus node](https://docs.filecoin.io/get-started/lotus/installation/#minimal-requirements).

From that point, the requirements depend on
[how you intend to operate Lily and what tasks you will run](operation.md).

We attempt to characterize the heaviest load scenario to illustrate some of
the performance concerns and limitations.

The Sentinel team operates Lily on `r5.8xlarge` AWS instances and have found
this sizing to accommodate the majority of the workload we ask of Lily. This
instance comes with:

- 256GiB RAM
- 32vCPU running on 3.1Ghz Intel Xeon (Skylake-SP or Cascade Lake)
- 10Gbps network access
- 3Tb EBS volume (w 6,800Mbps EBS transfer rate)

A typical deployment of Lily will configure two server instances w the
following four Jobs:

  * **Instance #1**

```
lily job run --storage=db --window=30s --tasks="blocks,messages,chaineconomics,actorstatesraw,actorstatespower,actorstatesreward,actorstatesmultisig,msapprovals" watch --confidence=100
lily job run --storage=db --window=30s --tasks=actorstatesinit watch --confidence=100
lily job run --storage=db --window=60s --tasks=actorstatesmarket watch --confidence=100
```

  * **Instance #2**

```
lily job run --storage=db --window=60s --task=actorstatesminer watch --confidence=100
```

The reason is that this allows watch tasks to run in parallel in a way that is
most effective. The miner task is specially heavy and needs dedicated
resources, as otherwise it is too slow and will last more than 30
seconds. This is also the reason why the `window` is extended to 60 seconds in
some cases, so that those tasks can occassionaly run for longer.

Lily Tasks are typically memory-bound, then disk-bound before they are
CPU-bound. Disk IO and CPU usage are not as highly demanded as
memory. Memory-optimized hardware should be prioritized for Lily deployments.
