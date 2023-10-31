import type { MiddlewareResponseHandler } from "astro";
import { sequence } from "astro:middleware";

const ensureAPIRequest: MiddlewareResponseHandler = async (
  { request, url },
  next
) => {
  if (url.pathname.startsWith("/api")) {
    const errorRes = new Response(
      JSON.stringify({
        ok: false,
        error: "Invalid content type",
      }),
      {
        status: 400,
        headers: {
          "content-type": "application/json",
        },
      }
    );
    const contentType = request.headers.get("content-type");
    if (!contentType || !contentType.includes("application/json")) {
      return errorRes;
    }
    // Go to the next middleware
    const response = await next();
    // Format the response
    if (response.status >= 400) {
      return new Response(
        JSON.stringify({ ok: false, error: await response.text() }),
        {
          status: response.status,
          headers: {
            "content-type": "application/json",
          },
        }
      );
    } else {
      return new Response(
        JSON.stringify({ ok: true, ...(await response.json()) }),
        {
          status: response.status,
          headers: {
            ...response.headers,
            "content-type": "application/json",
          },
        }
      );
    }
  } else {
    return next();
  }
};

export const onRequest = sequence(ensureAPIRequest);
