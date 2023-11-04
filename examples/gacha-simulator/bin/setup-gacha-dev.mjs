import cp from "node:child_process";
// import fs from "node:fs/promises";
// import path from "node:path";

import json from "../reference/hsr-gacha-1.4.json" assert { type: "json" };

const isTestnet = process.env.FLOW_NETWORK === "testnet";

// Build Transaction
function generateSetupTransactionParams() {
  const params = [];

  // worldName: String,
  params.push({
    type: "String",
    value: "sample",
  });

  // poolName: String,
  params.push({
    type: "String",
    value: json.name,
  });

  // rarityProbabilityPool: {UInt8: UFix64},
  params.push({
    type: "Dictionary",
    value: json.rarityProbabilityPool.map((item) => ({
      key: { type: "UInt8", value: `${item.rarity}` },
      value: { type: "UFix64", value: `${item.probability}` },
    })),
  });

  // counterThreshold: UInt64,
  params.push({
    type: "UInt64",
    value: `${json.counterThreshold}`,
  });

  // counterProbabilityModifier: UFix64,
  params.push({
    type: "UFix64",
    value: `${json.counterProbabilityModifier}`,
  });

  // boostingProbabilityRatio: UFix64,
  params.push({
    type: "UFix64",
    value: `${json.boostingProbabilityRatio}`,
  });

  // boostingProbabilityItems: [String],
  params.push({
    type: "Array",
    value: json.boostingProbabilityItems.map((item) => ({
      type: "String",
      value: `${item}`,
    })),
  });

  // items: [{String: AnyStruct}],
  params.push({
    type: "Array",
    value: json.items.map((item) => ({
      type: "Dictionary",
      value: [
        {
          key: { type: "String", value: "identity" },
          value: { type: "String", value: `${item.data.identity}` },
        },
        {
          key: { type: "String", value: "name" },
          value: { type: "String", value: `${item.display.name}` },
        },
        {
          key: { type: "String", value: "description" },
          value: { type: "String", value: `${item.display.description}` },
        },
        {
          key: { type: "String", value: "thumbnail" },
          value: { type: "String", value: `${item.display.thumbnail}` },
        },
        {
          key: { type: "String", value: "category" },
          value: { type: "UInt8", value: `${item.data.category}` },
        },
        {
          key: { type: "String", value: "rarity" },
          value: { type: "UInt8", value: `${item.data.rarity}` },
        },
      ],
    })),
  });

  return params;
}

const paramsJsonStr = JSON.stringify(generateSetupTransactionParams());

const out = cp.execSync(
  `flow transactions send ./transactions/platform/setup-gacha-pool.cdc --args-json='${paramsJsonStr}' ${
    isTestnet ? "--signer=testnet-admin --network=testnet" : "--signer=default"
  } --gas-limit 9999`
);
console.log("Result: ", out.toString());
