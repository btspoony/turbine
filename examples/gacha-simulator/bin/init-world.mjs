import cp from "node:child_process";

const isTestnet = process.env.FLOW_NETWORK === "testnet";
const worldName = "sample";
const pubKey =
  "fb62bbf229fb28f7d903334e99282699b06686b3bb6dab87fae3cef92acb17f43f576b332a2ee91c36f2b117d4264ba96c65eceac22bb92ab5a6aad24e94d7c0";

const out = cp.execSync(
  `flow transactions send ./transactions/platform/initialize-world.cdc ${worldName} ${pubKey} 10.0 ${
    isTestnet ? "--signer=testnet-admin --network=testnet" : "--signer=default"
  }`
);
console.log("Result: ", out.toString());
