# Core contracts for the Gacha Simulator

## How to use (for Developement)

> Initialize a gacha world

```bash
flow transactions send ./transactions/platform/initialize-world.cdc sample fb62bbf229fb28f7d903334e99282699b06686b3bb6dab87fae3cef92acb17f43f576b332a2ee91c36f2b117d4264ba96c65eceac22bb92ab5a6aad24e94d7c0 10.0 --signer=default
```

> Setup Gacha pool (for Dev)

Setup Gacha Pool referred from "Honkai Starrail 1.4 version"

```bash
node bin/setup-gacha-dev.mjs
```
