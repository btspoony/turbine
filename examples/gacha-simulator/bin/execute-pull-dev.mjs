import cp from "node:child_process";

const userName = "bt.wood";
const worldName = "sample";
const times = 10;

// The first two elements in process.argv array are 'node' and the path to your script file
// So you need to start at index 2
const poolId = process.argv[2];

const out = cp.execSync(
  `flow transactions send ./transactions/platform/pull.cdc ${userName} ${worldName} ${poolId} ${times} --signer=default --gas-limit 9999`
);
console.log("Result: ", out.toString());
