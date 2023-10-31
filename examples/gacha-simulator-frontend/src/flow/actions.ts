import { resolve } from "node:path";
import { readFile } from "node:fs/promises";
import * as fcl from "@onflow/fcl";

import { FlowContext } from "./shared/context.js";
import flowJSON from "@turbine/examples-gacha/flow.json" assert { type: "json" };

const APP_PREFIX = "GACHA_SIMULATOR_FLOW";

/**
 * Load standard code from flow-core-contracts
 * @param type
 * @param path
 */
export async function loadCode(type: "transactions" | "scripts", path: string) {
  const pathName = path.endsWith(".cdc") ? path : `${path}.cdc`;
  const filePath = resolve(
    process.cwd(),
    `node_modules/@turbine/examples-gacha/${type}/${pathName}`
  );
  return await readFile(filePath, "utf-8");
}

/**
 * Build flow context
 */
export async function buildFlowContext(): Promise<FlowContext> {
  const ctx = await FlowContext.create({
    flowJSON,
    redisPrefix: APP_PREFIX,
  });
  return ctx;
}

/// ------------------------------ Transactions ------------------------------
