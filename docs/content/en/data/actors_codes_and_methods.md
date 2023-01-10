---
title: "Actor Codes & Methods"
description: "The codes and methods of builtin actors."
lead: "The codes and methods of builtin actors."
menu:
  data:
    parent: "data"
    identifier: "actors_codes_and_methods"
weight: 10
toc: true

---

---

## Miner Actor

### Codes

| Version | Code                                                             |
|---------|------------------------------------------------------------------|
| 0       | `bafkqaetgnfwc6mjpon2g64tbm5sw22lomvza`                          |
| 2       | `bafkqaetgnfwc6mrpon2g64tbm5sw22lomvza`                          |
| 3       | `bafkqaetgnfwc6mzpon2g64tbm5sw22lomvza`                          |
| 4       | `bafkqaetgnfwc6nbpon2g64tbm5sw22lomvza`                          |
| 5       | `bafkqaetgnfwc6njpon2g64tbm5sw22lomvza`                          |
| 6       | `bafkqaetgnfwc6nrpon2g64tbm5sw22lomvza`                          |
| 7       | `bafkqaetgnfwc6nzpon2g64tbm5sw22lomvza`                          |
| 8       | `bafk2bzacea6rabflc7kpwr6y4lzcqsnuahr4zblyq3rhzrrsfceeiw2lufrb4` |
| 9       | `bafk2bzacebz4na3nq4gmumghegtkaofrv4nffiihd7sxntrryfneusqkuqodm` |

### Methods

| Method Name              | Method Number |
| ------------------------ | ------------- |
| Constructor              | 1             |
| ControlAddresses         | 2             |
| ChangeWorkerAddress      | 3             |
| ChangePeerID             | 4             |
| SubmitWindowedPoSt       | 5             |
| PreCommitSector          | 6             |
| ProveCommitSector        | 7             |
| ExtendSectorExpiration   | 8             |
| TerminateSectors         | 9             |
| DeclareFaults            | 10            |
| DeclareFaultsRecovered   | 11            |
| OnDeferredCronEvent      | 12            |
| CheckSectorProven        | 13            |
| ApplyRewards             | 14            |
| ReportConsensusFault     | 15            |
| WithdrawBalance          | 16            |
| ConfirmSectorProofsValid | 17            |
| ChangeMultiaddrs         | 18            |
| CompactPartitions        | 19            |
| CompactSectorNumbers     | 20            |
| ConfirmUpdateWorkerKey   | 21            |
| RepayDebt                | 22            |
| ChangeOwnerAddress       | 23            |
| DisputeWindowedPoSt      | 24            |
| PreCommitSectorBatch     | 25            |
| ProveCommitAggregate     | 26            |
| ProveReplicaUpdates      | 27            |

## Account Actor

### Codes
| Version | Code                          |
|---------|-------------------------------|
| 2       | bafkqadlgnfwc6mrpmfrwg33vnz2a |
| 3       | bafkqadlgnfwc6mzpmfrwg33vnz2a |
| 4       | bafkqadlgnfwc6nbpmfrwg33vnz2a |
| 5       | bafkqadlgnfwc6njpmfrwg33vnz2a |
| 6       | bafkqadlgnfwc6nrpmfrwg33vnz2a |
| 7       | bafkqadlgnfwc6nzpmfrwg33vnz2a |
| 8       | bafkqadlgnfwc6obpmfrwg33vnz2a |

### Methods

| Method Name           | Method Number |
|-----------------------|---------------|
| Constructor           | 1             |
| PubkeyAddress         | 2             |
| AuthenticateMessage   | 3             |
| UniversalReceiverHook | 3726118371    |

## Cron Actor

### Codes

| Version | Code                     |
|---------|--------------------------|
| 2       | bafkqactgnfwc6mrpmnzg63q |
| 3       | bafkqactgnfwc6mzpmnzg63q |
| 4       | bafkqactgnfwc6nbpmnzg63q |
| 5       | bafkqactgnfwc6njpmnzg63q |
| 6       | bafkqactgnfwc6nrpmnzg63q |
| 7       | bafkqactgnfwc6nzpmnzg63q |
| 8       | bafkqactgnfwc6obpmnzg63q |

### Methods

| Method Name | Method Number |
|-------------|---------------|
| Constructor | 1             |
| EpochTick   | 2             |

## Init Actor

### Codes

| Version | Code                     |
|---------|--------------------------|
| 2       | bafkqactgnfwc6mrpnfxgs5a |
| 3       | bafkqactgnfwc6mzpnfxgs5a |
| 4       | bafkqactgnfwc6nbpnfxgs5a |
| 5       | bafkqactgnfwc6njpnfxgs5a |
| 6       | bafkqactgnfwc6nrpnfxgs5a |
| 7       | bafkqactgnfwc6nzpnfxgs5a |
| 8       | bafkqactgnfwc6obpnfxgs5a |

### Methods

| Method Name | Method Number |
|-------------|---------------|
| Constructor | 1             |
| Exec        | 2             |

## Market Actor

### Codes

| Version | Code                                   |
|---------|----------------------------------------|
| 2       | bafkqae3gnfwc6mrpon2g64tbm5sw2ylsnnsxi |
| 3       | bafkqae3gnfwc6mzpon2g64tbm5sw2ylsnnsxi |
| 4       | bafkqae3gnfwc6nbpon2g64tbm5sw2ylsnnsxi |
| 5       | bafkqae3gnfwc6njpon2g64tbm5sw2ylsnnsxi |
| 6       | bafkqae3gnfwc6nrpon2g64tbm5sw2ylsnnsxi |
| 7       | bafkqae3gnfwc6nzpon2g64tbm5sw2ylsnnsxi |
| 8       | bafkqae3gnfwc6obpon2g64tbm5sw2ylsnnsxi |

### Methods

| Method Name      | Method Number |
|------------------|---------------|
| Constructor      | 1             |
| AwardBlockReward | 2             |
| ThisEpochReward  | 3             |
| UpdateNetworkKPI | 4             |

## Multisig Actor

### Codes

| Version | Code                           |
|---------|--------------------------------|
| 2       | bafkqadtgnfwc6mrpnv2wy5djonuwo |
| 3       | bafkqadtgnfwc6mzpnv2wy5djonuwo |
| 4       | bafkqadtgnfwc6nbpnv2wy5djonuwo |
| 5       | bafkqadtgnfwc6njpnv2wy5djonuwo |
| 6       | bafkqadtgnfwc6nrpnv2wy5djonuwo |
| 7       | bafkqadtgnfwc6nzpnv2wy5djonuwo |
| 8       | bafkqadtgnfwc6obpnv2wy5djonuwo |

### Methods

| Method Name                 | Method Number |
|-----------------------------|---------------|
| Constructor                 | 1             |
| Propose                     | 2             |
| Approve                     | 3             |
| Cancel                      | 4             |
| AddSigner                   | 5             |
| RemoveSigner                | 6             |
| SwapSigner                  | 7             |
| ChangeNumApprovalsThreshold | 8             |
| LockBalance                 | 9             |
| UniversalReceiverHook       | 3726118371    |

## Paych Actor

### Codes

| Version | Code                                     |
|---------|------------------------------------------|
| 2       | bafkqafdgnfwc6mrpobqxs3lfnz2gg2dbnzxgk3a |
| 3       | bafkqafdgnfwc6mzpobqxs3lfnz2gg2dbnzxgk3a |
| 4       | bafkqafdgnfwc6nbpobqxs3lfnz2gg2dbnzxgk3a |
| 5       | bafkqafdgnfwc6njpobqxs3lfnz2gg2dbnzxgk3a |
| 6       | bafkqafdgnfwc6nrpobqxs3lfnz2gg2dbnzxgk3a |
| 7       | bafkqafdgnfwc6nzpobqxs3lfnz2gg2dbnzxgk3a |
| 8       | bafkqafdgnfwc6obpobqxs3lfnz2gg2dbnzxgk3a |

### Methods

| Method Name        | Method Number |
|--------------------|---------------|
| Constructor        | 1             |
| UpdateChannelState | 2             |
| Settle             | 3             |
| Collect            | 4             |

## Power Actor

### Codes

| Version | Code                                  |
|---------|---------------------------------------|
| 2       | bafkqaetgnfwc6mrpon2g64tbm5sxa33xmvza |
| 3       | bafkqaetgnfwc6mzpon2g64tbm5sxa33xmvza |
| 4       | bafkqaetgnfwc6nbpon2g64tbm5sxa33xmvza |
| 5       | bafkqaetgnfwc6njpon2g64tbm5sxa33xmvza |
| 6       | bafkqaetgnfwc6nrpon2g64tbm5sxa33xmvza |
| 7       | bafkqaetgnfwc6nzpon2g64tbm5sxa33xmvza |
| 8       | bafkqaetgnfwc6obpon2g64tbm5sxa33xmvza |

### Methods

| Method Name              | Method Number |
|--------------------------|---------------|
| Constructor              | 1             |
| CreateMiner              | 2             |
| UpdateClaimedPower       | 3             |
| EnrollCronEvent          | 4             |
| CronTick                 | 5             |
| UpdatePledgeTotal        | 6             |
| Deprecated1              | 7             |
| SubmitPoRepForBulkVerify | 8             |
| CurrentTotalPower        | 9             |

## Reward Actor

### Codes

| Version | Code                        |
|---------|-----------------------------|
| 2       | bafkqaddgnfwc6mrpojsxoylsmq |
| 3       | bafkqaddgnfwc6mzpojsxoylsmq |
| 4       | bafkqaddgnfwc6nbpojsxoylsmq |
| 5       | bafkqaddgnfwc6njpojsxoylsmq |
| 6       | bafkqaddgnfwc6nrpojsxoylsmq |
| 7       | bafkqaddgnfwc6nzpojsxoylsmq |
| 8       | bafkqaddgnfwc6obpojsxoylsmq |

### Methods

| Method Name      | Method Number |
|------------------|---------------|
| Constructor      | 1             |
| AwardBlockReward | 2             |
| ThisEpochReward  | 3             |
| UpdateNetworkKPI | 4             |

## System Actor

### Codes

| Version | Code                        |
|---------|-----------------------------|
| 2       | bafkqaddgnfwc6mrpon4xg5dfnu |
| 3       | bafkqaddgnfwc6mzpon4xg5dfnu |
| 4       | bafkqaddgnfwc6nbpon4xg5dfnu |
| 5       | bafkqaddgnfwc6njpon4xg5dfnu |
| 6       | bafkqaddgnfwc6nrpon4xg5dfnu |
| 7       | bafkqaddgnfwc6nzpon4xg5dfnu |
| 8       | bafkqaddgnfwc6obpon4xg5dfnu |

### Methods

## Verified Registry Actor

### Codes

### Methods

| Method Name                 | Method Number |
|-----------------------------|---------------|
| Constructor                 | 1             |
| AddVerifier                 | 2             |
| RemoveVerifier              | 3             |
| AddVerifiedClient           | 4             |
| Deprecated1                 | 5             |
| Deprecated2                 | 6             |
| RemoveVerifiedClientDataCap | 7             |
| RemoveExpiredAllocations    | 8             |
| ClaimAllocations            | 9             |
| GetClaims                   | 10            |
| ExtendClaimTerms            | 11            |
| RemoveExpiredClaims         | 12            |
| UniversalReceiverHook       | 3726118371    |
