import type { APIRoute } from "astro";

import { fetchLatestTransactions } from "@flow/actions";

export const GET: APIRoute = async (_ctx) => {
  const list = await fetchLatestTransactions(20);
  return new Response(JSON.stringify({ list }));
};
