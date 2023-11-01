import type { APIRoute } from "astro";

import { revealGachaPullResults } from "@flow/actions";

export const POST: APIRoute = async (ctx) => {
  const body: { txids: string[] } = await ctx.request.json();
  if (
    !Array.isArray(body.txids) ||
    body.txids.length === 0 ||
    body.txids.some((one) => typeof one !== "string")
  ) {
    throw new Error(
      "Invalid body: txids is required, and must be a string array"
    );
  }

  return new Response(
    JSON.stringify({
      batch: await revealGachaPullResults(body.txids),
    })
  );
};
