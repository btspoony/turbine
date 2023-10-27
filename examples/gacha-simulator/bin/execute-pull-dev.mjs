import cp from "node:child_process";

import json from "../reference/hsr-gacha-1.4.json" assert { type: "json" };

const userName = "bt.wood";
const worldName = "sample";
const times = 10;

const out = cp.execSync(
  `flow transactions send ./transactions/platform/pull.cdc ${userName} ${worldName} ${json.name} ${times} --signer=default --gas-limit 9999`
);
console.log("Result: ", out.toString());
