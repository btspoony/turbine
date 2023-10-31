export interface KeyEntry {
  index: number;
  keypair: KeyPair;
}

export interface KeyPair {
  privKeyHex: string;
  pubKeyHex: string;
  signatureAlgorithm?: "ECDSA_P256";
  hashAlgorithm?: "SHA3_256";
}

export class KeyManagerService {
  constructor() {}

  /**
   * Get the account address by label
   * @param label
   * @param blockchain
   */
  async getAccountAddress(_label: string): Promise<string> {
    // Temporary implementation, returned directly based on the environment variables.
    return Promise.resolve(import.meta.env.FLOW_CONTROLLER_ADDRESS);
  }

  /**
   * Temporary method to get the account keys
   * @param label
   */
  async getAccountKeys(_label: string): Promise<KeyEntry[]> {
    // Temporary implementation, returned directly based on the environment variables.
    return Promise.resolve([
      {
        index: 0,
        keypair: {
          privKeyHex: import.meta.env.FLOW_CONTROLLER_PRIVATE_KEY,
          pubKeyHex: import.meta.env.FLOW_CONTROLLER_PUBLIC_KEY,
          signatureAlgorithm: "ECDSA_P256",
          hashAlgorithm: "SHA3_256",
        },
      },
    ]);
  }

  /**
   * Temporary method to get key pair
   * @param label
   * @returns
   */
  async generateKeypairFor(_label: string): Promise<KeyPair> {
    // Temporary implementation, returned directly based on the environment variables.
    return Promise.resolve({
      privKeyHex: import.meta.env.FLOW_CONTROLLER_PRIVATE_KEY,
      pubKeyHex: import.meta.env.FLOW_CONTROLLER_PUBLIC_KEY,
      signatureAlgorithm: "ECDSA_P256",
      hashAlgorithm: "SHA3_256",
    });
  }
}
