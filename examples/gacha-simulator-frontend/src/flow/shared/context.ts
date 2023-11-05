import pino from "pino";
import { FlowService } from "./flow.service.js";
import { KeyManagerService } from "./key-manager.service.js";
import { FlowSigner } from "./flow.signer.js";
import type { RedisHelperService } from "./redis-helper.service.js";

export interface FlowContextOption {
  flowJSON: object;
}

export class FlowContext {
  // Static methods
  static async create(opt: FlowContextOption): Promise<FlowContext> {
    const ctx = new FlowContext(opt);
    await ctx.init();
    return ctx;
  }

  // Instance methods
  private readonly flowService: FlowService;
  private readonly keyManagerService: KeyManagerService;

  private constructor(opt: FlowContextOption) {
    this.flowService = new FlowService(opt.flowJSON);
    this.keyManagerService = new KeyManagerService();
  }

  private async init() {
    this.flowService.onModuleInit();
  }

  /**
   * Get the flow service
   */
  get service(): FlowService {
    return this.flowService;
  }

  /**
   * Get the key manager service
   */
  get kms(): KeyManagerService {
    return this.keyManagerService;
  }

  /**
   * Create a new flow signer
   */
  createNewSigner(): FlowSigner {
    return new FlowSigner(this.flowService, this.keyManagerService);
  }
}
