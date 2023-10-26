import cp from "node:child_process";

const userName = "bt.wood";
const worldName = "sample";
const poolName = "HSR_Gacha_1.4_Charactor_A";
const times = 10;

const out = cp.execSync(
  `flow transactions send ./transactions/platform/pull.cdc ${userName} ${worldName} ${poolName} ${times} --signer=default --gas-limit 9999`
);
console.log("Result: ", out.toString());
