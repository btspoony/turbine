import { defineConfig } from "astro/config";
import UnoCSS from "unocss/astro";
import vercel from "@astrojs/vercel/serverless";

// https://astro.build/config
export default defineConfig({
  site: "https://turbine.run",
  integrations: [
    UnoCSS({
      injectReset: true,
    }),
  ],
  output: "server",
  adapter: vercel({}),
});
