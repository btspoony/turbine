# Core contracts for the Gacha Simulator

## How to use (for Developement)

> Initialize a gacha world

```bash
node bin/init-world.mjs
```

> Setup Gacha pool (for Dev)

Setup Gacha Pool referred from "Honkai Starrail 1.4 version"

```bash
node bin/setup-gacha-dev.mjs
```

> Pull Items from Gacha pool (for Dev)

```bash
node bin/pull-gacha-dev.mjs
```

> Query Inventory

```bash
flow scripts execute ./scripts/platform/query-user-inventory.cdc sample bt.wood
```
