import pino from "pino";
import * as fcl from "@onflow/fcl";
import type { Account, TransactionStatus } from "@onflow/typedefs";

import type {
  AccountProofData,
  AuthzFn,
  BlockHeaderObject,
  NetworkType,
} from "./fcl.types.js";

export class FlowService {
  private readonly logger = pino({ name: "FlowService" });
  private network: NetworkType;
  private accessNodeUrl?: string;
  private flowJSON: object;

  /**
   * Initialize the Flow SDK
   */
  constructor(flowJSON: object) {
    this.network = (import.meta.env.FLOW_NETWORK as NetworkType) ?? "emulator";
    this.accessNodeUrl = import.meta.env.FLOW_ACCESS_NODE_URL;
    this.flowJSON = flowJSON;
  }

  async onModuleInit() {
    const cfg = fcl.config();
    await cfg.put("flow.network", this.network);
    await cfg.put("fcl.limit", 9999);
    if (this.accessNodeUrl) {
      await cfg.put("accessNode.api", this.accessNodeUrl);
    } else {
      switch (this.network) {
        case "mainnet":
          await cfg.put("accessNode.api", "https://mainnet.onflow.org");
          break;
        case "testnet":
          await cfg.put("accessNode.api", "https://testnet.onflow.org");
          break;
        case "emulator":
          await cfg.put("accessNode.api", "http://localhost:8888");
          break;
        default:
          throw new Error(`Unknown network: ${String(this.network)}`);
      }
    }
    cfg.load({ flowJSON: this.flowJSON });
  }

  /**
   * Get account information
   */
  async getAccount(addr: string): Promise<Account> {
    return await fcl.send([fcl.getAccount(addr)]).then(fcl.decode);
  }

  /**
   * General method of sending transaction
   */
  async sendTransaction(
    code: string,
    args: fcl.ArgsFn,
    mainAuthz: AuthzFn,
    extraAuthz: AuthzFn[] = []
  ) {
    const transactionId = await fcl.mutate({
      cadence: code,
      args: args,
      proposer: mainAuthz,
      payer: mainAuthz,
      authorizations:
        extraAuthz.length === 0 ? [mainAuthz] : [mainAuthz, ...extraAuthz],
    });
    this.logger.info(`Tx Sent: ${transactionId}`);
    return transactionId;
  }

  /**
   * Send transaction with single authorization
   * @param transactionId
   * @param onSealed
   * @param onStatusUpdated
   * @param onErrorOccured
   */
  watchTransaction(
    transactionId: string,
    onSealed: (txId: string, errorMsg?: string) => void | undefined,
    onStatusUpdated: (status: TransactionStatus) => void | undefined,
    onErrorOccured: (errorMsg: string) => void | undefined
  ) {
    fcl.tx(transactionId).subscribe((res) => {
      if (onStatusUpdated) {
        onStatusUpdated(res);
      }

      if (res.status === 4) {
        if (res.errorMessage && onErrorOccured) {
          onErrorOccured(res.errorMessage);
        }
        // on sealed callback
        if (typeof onSealed === "function") {
          onSealed(
            transactionId,
            res.errorMessage ? res.errorMessage : undefined
          );
        }
      }
    });
  }

  /**
   * Get transaction status
   */
  async getTransactionStatus(
    transactionId: string
  ): Promise<TransactionStatus> {
    return await fcl.tx(transactionId).onceExecuted();
  }

  /**
   * Get chain id
   */
  async getChainId() {
    return await fcl.getChainId();
  }

  /**
   * Send transaction with single authorization
   */
  async onceTransactionSealed(
    transactionId: string
  ): Promise<TransactionStatus> {
    return fcl.tx(transactionId).onceSealed();
  }

  /**
   * Get block object
   * @param blockId
   */
  async getBlockHeaderObject(blockId: string): Promise<BlockHeaderObject> {
    return await fcl
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
      .send([fcl.getBlockHeader(), fcl.atBlockId(blockId)])
      .then(fcl.decode);
  }

  /**
   * Send script
   */
  async executeScript<T>(code: string, args: fcl.ArgsFn, defaultValue: T) {
    try {
      const queryResult = await fcl.query({
        cadence: code,
        args,
      });
      return queryResult ?? defaultValue;
    } catch (e) {
      console.error(e);
      return defaultValue;
    }
  }

  /**
   * Verify account proof
   */
  async verifyAccountProof(
    appIdentifier: string,
    opt: AccountProofData
  ): Promise<boolean> {
    if (this.network === "emulator") return true;

    return await fcl.AppUtils.verifyAccountProof(
      appIdentifier,
      {
        address: opt.address,
        nonce: opt.nonce,
        signatures: opt.signatures.map((one) => ({
          f_type: "CompositeSignature",
          f_vsn: "1.0.0",
          keyId: one.keyId,
          addr: one.addr,
          signature: one.signature,
        })),
      },
      {
        // use blocto adddres to avoid self-custodian
        // https://docs.blocto.app/blocto-sdk/javascript-sdk/flow/account-proof
        fclCryptoContract:
          this.network === "mainnet"
            ? "0xdb6b70764af4ff68"
            : "0x5b250a8a85b44a67",
      }
    );
  }
}
