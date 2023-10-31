import type { APIRoute } from "astro";

export const GET: APIRoute = ({ request, locals, params }) => {
  return new Response(JSON.stringify({}));
};
