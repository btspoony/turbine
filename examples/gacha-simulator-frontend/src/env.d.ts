/// <reference types="astro/client" />

interface ImportMetaEnv {
  readonly FLOW_NETWORK: string;
  readonly FLOW_ACCESS_NODE_URL?: string;

  readonly FLOW_ACCOUNT_KEY_AMOUNT: string;
  readonly FLOW_CONTROLLER_ADDRESS: string;
  readonly FLOW_CONTROLLER_PRIVATE_KEY: string;
  readonly FLOW_CONTROLLER_PUBLIC_KEY: string;

  readonly REDIS_HOST?: string;
  readonly REDIS_PORT?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

declare namespace App {
  interface Locals {
    username?: string;
  }
}
