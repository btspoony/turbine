import { defineConfig } from "astro/config";
import UnoCSS from "unocss/astro";
import vue from "@astrojs/vue";
import vercel from "@astrojs/vercel/serverless";

// https://astro.build/config
export default defineConfig({
  integrations: [
    vue({
      appEntrypoint: "/src/pages/_app",
    }),
    UnoCSS({
      injectReset: true,
    }),
  ],
  output: "server",
  adapter: vercel({
    functionPerRoute: true,
  }),
});
