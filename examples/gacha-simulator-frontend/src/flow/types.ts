export enum ItemCatagory {
  Character = 0,
  Weapon,
  Consumable,
  QuestItem,
}

export interface GachaPoolItem {
  id: string;
  // display
  name: string;
  description: string;
  thumbnail?: string;
  // info
  category: ItemCatagory;
  fungible: boolean;
  identity: string;
  rarity: number;
  traits: Record<string, number>;
}

export interface PlayerInventoryItem extends GachaPoolItem {
  // owned info
  itemEntityID: string;
  exp: number;
  level: number;
  quality: number;
  quantity: number;
}

export interface GachaPool {
  host: string;
  world: string;
  poolId: string;
  poolName: string;
}

export interface GeneralTransaction {
  txid: string;
}
