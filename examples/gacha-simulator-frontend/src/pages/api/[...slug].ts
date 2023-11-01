import type { APIRoute } from "astro";

export const ALL: APIRoute = async (ctx) => {
  const url = new URL(ctx.request.url);
  return new Response(`Not Found: url - ${url.toString()}`, {
    status: 404,
  });
};
