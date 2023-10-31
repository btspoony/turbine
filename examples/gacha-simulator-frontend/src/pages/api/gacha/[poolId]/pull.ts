import type { APIRoute } from "astro";

export const POST: APIRoute = ({ request, locals, params }) => {
  return new Response(JSON.stringify({}));
};
