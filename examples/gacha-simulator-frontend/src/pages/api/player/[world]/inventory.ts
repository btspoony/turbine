import type { APIRoute } from "astro";

import { getPlayerInventoryItems } from "@flow/actions.js";

export const GET: APIRoute = async (ctx) => {
  if (!ctx.locals.username) {
    throw new Error("Unauthorized: username is required");
  }
  if (!ctx.params.world) {
    throw new Error("Invalid params: world");
  }
  let list = await getPlayerInventoryItems(
    ctx.params.world,
    ctx.locals.username
  );
  return new Response(JSON.stringify({ list }));
};
