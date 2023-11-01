import pino from "pino";
import elliptic from "elliptic";
import { SHA3 } from "sha3";
import * as fcl from "@onflow/fcl";
import type { Account, CompositeSignature } from "@onflow/typedefs";

import type { AuthZ, AuthzFn } from "./fcl.types.js";
import { FlowService } from "./flow.service.js";
import { RedisHelperService } from "./redis-helper.service.js";
import { KeyManagerService } from "./key-manager.service.js";

export class FlowSigner {
  private readonly logger = pino({ name: "FlowSigner" });
  private signerLabel: string = "default";

  constructor(
    private flowService: FlowService,
    private redisHelper: RedisHelperService,
    private kmService: KeyManagerService
  ) {}

  /**
   * Set the signer label
   */
  setLabel(label: string) {
    this.signerLabel = label;
  }

  async getAddress(label?: string): Promise<string> {
    return await this.kmService.getAccountAddress(label ?? this.signerLabel);
  }

  /**
   * Send a transaction with the given code and arguments
   */
  async sendTransactionWithKeyPool(code: string, args: fcl.ArgsFn) {
    const address = await this.getAddress();
    const keyIndex = await this.redisHelper.acquireKeyIndex(address);

    const authzFn = await this.buildAuthorization(keyIndex);
    const txid = await this.flowService.sendTransaction(code, args, authzFn);

    await this.redisHelper.releaseKeyIndex(address, keyIndex);
    await this.redisHelper.pushKeyToRedis("Transactions", txid);

    return txid;
  }

  /**
   * Build an authorization object for the Flow SDK
   */
  async buildAuthorization(index: number): Promise<AuthzFn> {
    const keyEntries = await this.kmService.getAccountKeys(this.signerLabel);
    if (index >= keyEntries.length) {
      throw new Error("Invalid key index");
    }
    const address = await this.getAddress();
    this.logger.info(`Authz Addr: ${address} - key[${index}]`);

    return async (txAccount: Account): Promise<AuthZ> => {
      const keyEntry = keyEntries[index];

      return Promise.resolve({
        ...txAccount,
        addr: fcl.sansPrefix(address),
        keyId: Number(keyEntry.index),
        signingFunction: async (signable): Promise<CompositeSignature> => {
          return Promise.resolve({
            f_type: "CompositeSignature",
            f_vsn: "1.0.0",
            addr: fcl.withPrefix(address),
            keyId: Number(keyEntry.index),
            signature: this._signWithKey(
              keyEntry.keypair.privKeyHex,
              signable.message
            ),
          });
        },
      });
    };
  }

  /**
   * Sign a message with the private key
   */
  private _signWithKey(privateKey: string, msg: string) {
    const ec = new elliptic.ec("p256");
    const key = ec.keyFromPrivate(Buffer.from(privateKey, "hex"));
    const sig = key.sign(this._hashMsg(msg));
    const n = 32;
    const r = sig.r.toArrayLike(Buffer, "be", n);
    const s = sig.s.toArrayLike(Buffer, "be", n);
    return Buffer.concat([r, s]).toString("hex");
  }

  /**
   * Hash a message
   */
  private _hashMsg(msg: string) {
    const sha = new SHA3(256);
    sha.update(Buffer.from(msg, "hex"));
    return sha.digest();
  }
}
