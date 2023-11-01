import { resolve } from "node:path";
import { readFile } from "node:fs/promises";

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

export interface GeneralTransaction {
  txid: string;
}

export async function gachaPull(
  username: string,
  world: string,
  poolId: string,
  times: number
) {
  const ctx = await buildFlowContext();
  const code = await loadCode("transactions", "platform/pull");

  const signer = ctx.createNewSigner();
  signer.setLabel("default");
  const txid = await signer.sendTransactionWithKeyPool(code, (arg, t) => [
    arg(username, t.String),
    arg(world, t.String),
    arg(poolId, t.UInt64),
    arg(String(Math.min(1, Math.max(10, times))), t.UInt64),
  ]);
  return { txid };
}

/// ------------------------------ Query Scripts ------------------------------

export interface GachaPool {
  host: string;
  world: string;
  poolId: string;
  poolName: string;
}

export async function getGachaPools(): Promise<GachaPool[]> {
  const ctx = await buildFlowContext();
  const code = await loadCode("scripts", "platform/list-pools");
  const response = await ctx.service.executeScript(
    code,
    (args, t) => [],
    undefined
  );
  // TODO: parse response
  return response as GachaPool[];
}

export enum ItemCatagory {
  Character = 0,
  Weapon,
  Consumable,
  QuestItem,
}

export interface GachaPoolItem {
  // display
  name: string;
  description: string;
  thumbnail?: string;
  // info
  category: ItemCatagory;
  fungible: boolean;
  identity: string;
  rarity: number;
  traits: Record<string, number>;
}

function parseGachaItem(one: any): GachaPoolItem {
  return {
    name: one.display?.name,
    description: one.display?.description,
    thumbnail: one.display?.thumbnail?.url ?? undefined,
    category: parseInt(one.item?.category?.rawValue ?? "0") as ItemCatagory,
    fungible: one.item?.fungible,
    identity: one.item?.identity,
    rarity: parseInt(one.item?.rarity ?? "0"),
    traits: one.item?.traits ?? {},
  };
}

export async function getGachaPoolItems(
  world: string,
  poolId: string
): Promise<GachaPoolItem[]> {
  const ctx = await buildFlowContext();
  const code = await loadCode("scripts", "platform/fetch-pool-detail");
  try {
    const list = await ctx.service.executeScript(
      code,
      (arg, t) => [arg(world, t.String), arg(poolId, t.UInt64)],
      undefined
    );
    if (Array.isArray(list) && list.length > 0) {
      return list.map((one) => parseGachaItem(one));
    } else {
      return [];
    }
  } catch (e) {
    throw new Error(`Not Found: ${world}/${poolId}`);
  }
}

export interface PlayerInventoryItem extends GachaPoolItem {
  // owned info
  itemEntityID: string;
  exp: number;
  level: number;
  quality: number;
  quantity: number;
}

function parsePlayerInventoryItem(one: any): PlayerInventoryItem {
  const item = parseGachaItem(one);
  return {
    ...item,
    itemEntityID: one.itemEntityID,
    exp: parseInt(one.exp ?? "0"),
    level: parseInt(one.level ?? "0"),
    quality: parseInt(one.quality ?? "0"),
    quantity: parseInt(one.quantity ?? "0"),
  };
}

export async function getPlayerInventoryItems(
  world: string,
  username: string
): Promise<PlayerInventoryItem[]> {
  const ctx = await buildFlowContext();
  const code = await loadCode("scripts", "platform/query-user-inventory");
  let response: any;
  try {
    const list = await ctx.service.executeScript(
      code,
      (arg, t) => [arg(world, t.String), arg(username, t.String)],
      undefined
    );
    if (Array.isArray(list) && list.length > 0) {
      response = list.map((one) => parsePlayerInventoryItem(one));
    }
  } catch (e) {}
  if (!response) {
    throw new Error(`Inventory Not Found: ${world}/${username}`);
  }
  return response;
}

export async function fetchLatestTransactions(
  limit?: number
): Promise<string[]> {
  const ctx = await buildFlowContext();
  return await ctx.redisHelper.fetchLatestKeysFromRedis("Transactions", limit);
}
