/**
 * Reveals the gacha result
 */
export async function revealTxids(txids: string[]) {
  const url = `/api/gacha/reveal`;
  return await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      txids: txids,
    }),
  }).then((res) => res.json());
}

/**
 * Load player inventory
 */
export async function getInventroy(world: string, username: string) {
  const url = `/api/player/${world}/inventory`;
  return await fetch(url, {
    headers: {
      "x-app-username": username,
    },
  }).then((res) => res.json());
}
