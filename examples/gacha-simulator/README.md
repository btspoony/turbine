# Core contracts for the Gacha Simulator

## How to use (for Developement)

> Deploy contracts to local emulator

```bash
pnpm dev
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
node bin/pull-gacha-dev.mjs
```

> Query Inventory

```bash
flow scripts execute ./scripts/platform/query-user-inventory.cdc sample bt.wood
```
