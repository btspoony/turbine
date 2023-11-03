import { createGlobalState, useStorage } from "@vueuse/core";

export const useGlobalUsername = createGlobalState(() =>
  useStorage("x-app-username", "")
);
