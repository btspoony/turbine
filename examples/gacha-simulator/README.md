# Core contracts for the Gacha Simulator

## How to use (for Developement)

> Deploy contracts to local emulator

```bash
flow emulator // start emulator
pnpm dev // deploy contracts
```

> Initialize a gacha world (name: sample)

```bash
node bin/init-world.mjs
```

> Setup Gacha pool (for Dev)

Setup Gacha Pool referred from "Honkai Starrail 1.4 version"

```bash
node bin/setup-gacha-dev.mjs
```

> Pull Items from Gacha pool (for Dev, user: bt.wood, times: 10)

```bash
node bin/pull-gacha-dev.mjs {poolId}
```

> Query List of Gacha Pools

```bash
flow scripts execute ./scripts/platform/list-pools.cdc
```

> Fetch Pool Details

```bash
flow scripts execute ./scripts/platform/fetch-pool-detail.cdc sample {poolID}
```

> Query Inventory

```bash
flow scripts execute ./scripts/platform/query-user-inventory.cdc sample bt.wood
```
