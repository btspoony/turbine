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
