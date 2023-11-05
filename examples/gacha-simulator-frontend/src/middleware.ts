import type { MiddlewareResponseHandler } from "astro";
import { sequence } from "astro:middleware";
import pino from "pino";

const logger = pino({ name: "FlowContext" });

const ensureAPIRequest: MiddlewareResponseHandler = async (
  { request, url, cookies, locals },
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
    if (
      request.method !== "GET" &&
      (!contentType || !contentType.includes("application/json"))
    ) {
      return errorRes;
    }

    // setup locals
    locals.username =
      request.headers.get("x-app-username") ??
      cookies.get("x-app-username")?.value ??
      "";

    // Go to the next middleware
    let response: Response;
    let error: Error;
    try {
      response = await next();
    } catch (err: any) {
      error = err;
    }
    // Format the response
    if (error || response.status >= 400) {
      const errorMsg = response
        ? await response.text()
        : error?.message ?? "Unknown error";
      logger.error(errorMsg);
      return new Response(
        JSON.stringify({
          ok: false,
          error: errorMsg,
        }),
        {
          status: response?.status ?? 400,
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
