import cp from "node:child_process";

const isTestnet = process.env.FLOW_NETWORK === "testnet";
const amount = process.argv[2] ?? 100;

const out = cp.execSync(
  `flow transactions send ./node_modules/@turbine-cdc/core/transactions/utils/add-more-keys.cdc ${amount} ${
    isTestnet ? "--signer=testnet-admin --network=testnet" : "--signer=default"
  }`
);
console.log("Result: ", out.toString());
