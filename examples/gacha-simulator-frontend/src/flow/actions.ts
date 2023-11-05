import { loadCode } from "@turbine-cdc/examples-gacha";
import flowJSON from "@turbine-cdc/examples-gacha/flow.json" assert { type: "json" };

import { FlowContext } from "./shared/context.js";
import { RedisHelperService } from "./shared/redis-helper.service.js";
import type {
  GachaPool,
  GachaPoolItem,
  GachaResult,
  ItemCatagory,
  PlayerInventoryItem,
} from "./types.js";

const APP_PREFIX = "GACHA_SIMULATOR_FLOW";

/**
 * Build flow context
 */
export async function buildFlowContext(): Promise<FlowContext> {
  const ctx = await FlowContext.create({ flowJSON });
  return ctx;
}

/// ------------------------------ Transactions ------------------------------

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

  const redisHelper = new RedisHelperService({ prefix: APP_PREFIX });
  const txid = await signer.sendTransactionWithKeyPool(
    code,
    (arg, t) => [
      arg(username, t.String),
      arg(world, t.String),
      arg(poolId, t.UInt64),
      arg(String(Math.min(10, Math.max(1, times))), t.UInt64),
    ],
    redisHelper
  );
  return { txid };
}

/// ------------------------------ Query Scripts ------------------------------

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

function parseGachaItem(one: any): GachaPoolItem {
  return {
    id: one.id,
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
    throw new Error(`Not Found: World[${world}] GachaPool[${poolId}]`);
  }
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

/**
 * Get player inventory items
 */
export async function getPlayerInventoryItems(
  world: string,
  username: string,
  ctx?: FlowContext
): Promise<PlayerInventoryItem[]> {
  ctx = ctx ?? (await buildFlowContext());
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
    throw new Error(`Inventory Not Found: ${world} - User[${username}]`);
  }
  return response;
}

/**
 * Get player inventory items
 */
export async function getPlayerInventoryItemsByIds(
  world: string,
  ownedItemIds: string[],
  ctx?: FlowContext
): Promise<PlayerInventoryItem[]> {
  ctx = ctx ?? (await buildFlowContext());
  const code = await loadCode("scripts", "platform/query-owned-items");
  let response: any;
  try {
    const list = await ctx.service.executeScript(
      code,
      (arg, t) => [arg(world, t.String), arg(ownedItemIds, t.Array(t.UInt64))],
      undefined
    );
    if (Array.isArray(list) && list.length > 0) {
      response = list.map((one) => parsePlayerInventoryItem(one));
    }
  } catch (e) {}
  if (!response) {
    throw new Error(`OwnedIds Not Found: ${world} - ${ownedItemIds.join(",")}`);
  }
  return response;
}

/**
 * Get player inventory items
 */
export async function fetchLatestTransactions(
  limit?: number
): Promise<string[]> {
  const redisHelper = new RedisHelperService({ prefix: APP_PREFIX });
  return await redisHelper.fetchLatestKeysFromRedis("Transactions", limit);
}

export async function revealGachaPullResults(txids: string[]) {
  const ctx = await buildFlowContext();

  const txResults = await Promise.all(
    txids.map(async (txid) => await ctx.service.getTransactionStatus(txid))
  );
  // filter valid txs
  const txResultsWithEvents = txResults.filter(
    (one) => one.status >= 3 && one.events.length > 0
  );

  const ownedItemIdsMapping: Record<
    string,
    Omit<GachaResult, "items"> & { items: string[] }
  > = {};

  // parse events
  for (const one of txResultsWithEvents) {
    const worldEvt = one.events.find((one) =>
      one.type.endsWith("CoreWorld.WorldEntityCreated")
    );
    if (!worldEvt) continue;
    const txid = worldEvt.transactionId;
    const world = worldEvt.data["name"] as string;
    if (!world) continue;

    const userPullEvt = one.events.find((one) =>
      one.type.endsWith("GachaGameSystem.PlayerPulled")
    );
    if (!userPullEvt) continue;
    const username = userPullEvt.data["username"] as string;
    const poolId = userPullEvt.data["poolEntityId"] as string;
    if (!username || !poolId) continue;

    const txRecord = { world, username, poolId, items: [] };

    const owndItemEvts = one.events.filter((one) =>
      one.type.endsWith("InventoryComponent.OwnedItemAdded")
    );
    for (const evt of owndItemEvts) {
      if (typeof evt.data["itemID"] !== "string") continue;
      txRecord.items.push(evt.data["itemID"]);
    }

    // save tx record
    ownedItemIdsMapping[txid] = txRecord;
  }

  // query items
  const results: Record<string, GachaResult> = {};
  for (const txid in ownedItemIdsMapping) {
    const record = ownedItemIdsMapping[txid];

    results[txid] = Object.assign({}, record, {
      items: await getPlayerInventoryItemsByIds(
        record.world,
        record.items,
        ctx
      ),
    });
  }
  return results;
}
