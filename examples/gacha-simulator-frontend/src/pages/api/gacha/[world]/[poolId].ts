import type { APIRoute } from "astro";

import { gachaPull, getGachaPoolItems } from "@flow/actions.js";

/**
 * Pull from a gacha pool
 */
export const POST: APIRoute = async (ctx) => {
  if (!ctx.locals.username) {
    throw new Error("Unauthorized: username is required");
  }
  if (!ctx.params.world || !ctx.params.poolId) {
    throw new Error("Invalid params: world and poolId are required");
  }
  const body = await ctx.request.json();
  if (typeof body.times !== "number") {
    throw new Error("Invalid body: times is required");
  }

  const response = await gachaPull(
    ctx.locals.username,
    ctx.params.world,
    ctx.params.poolId,
    body.times
  );
  return new Response(JSON.stringify(response));
};

/**
 * List items in a gacha pool
 */
export const GET: APIRoute = async (ctx) => {
  if (!ctx.params.world || !ctx.params.poolId) {
    throw new Error("Invalid params: world and poolId are required");
  }
  let list = await getGachaPoolItems(ctx.params.world, ctx.params.poolId);
  return new Response(JSON.stringify({ list }));
};
