import type { APIRoute } from "astro";

import { getGachaPools } from "@flow/actions.js";

export const GET: APIRoute = async (_ctx) => {
  let list = await getGachaPools();
  return new Response(JSON.stringify({ list }));
};
