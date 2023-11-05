import { resolve } from "node:path";
import { readFile } from "node:fs/promises";

/**
 * Load code from path
 * @param {'scripts' | 'transactions'} type
 * @param {string} path
 */
export async function loadCode(type, path) {
  if (type !== "scripts" && type !== "transactions") {
    throw new Error(`Invalid type: ${type}`);
  }
  const pathName = path.endsWith(".cdc") ? path : `${path}.cdc`;
  const dirname = new URL(".", import.meta.url).pathname;
  const filePath = resolve(dirname, `./${type}/${pathName}`);
  console.log(`Loading code from ${filePath}`);
  return await readFile(filePath, "utf-8");
}
