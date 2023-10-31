import type { Account, CompositeSignature } from "@onflow/typedefs";

export type NetworkType = "mainnet" | "testnet" | "emulator";

export interface SigningData {
  message: string;
}

export interface AuthZ extends Account {
  addr: string;
  keyId: number;
  signingFunction: (data: SigningData) => Promise<CompositeSignature>;
}
export type AuthzFn = (account: Account) => Promise<AuthZ>;

export interface FTypeSignature extends CompositeSignature {
  f_type: "CompositeSignature";
  f_vsn: "1.0.0";
}

// Utils
export interface AccountProofData {
  address: string;
  nonce: string;
  signatures: FTypeSignature[];
}

export interface BlockHeaderObject {
  id: string;
  parentId: string;
  height: number;
  timestamp: string;
}
