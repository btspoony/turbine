import { defineConfig } from "astro/config";
import UnoCSS from "unocss/astro";
import vue from "@astrojs/vue";
import vercel from "@astrojs/vercel/serverless";

// https://astro.build/config
export default defineConfig({
  site: "https://gacha-demo.turbine.run",
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
    functionPerRoute: false,
  }),
  vite: {
    ssr: {
      external: ["@onflow/fcl", "@turbine-cdc/examples-gacha"],
    },
  },
});
