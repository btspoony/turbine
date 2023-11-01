import pino from "pino";
import { FlowService } from "./flow.service.js";
import { KeyManagerService } from "./key-manager.service.js";
import { RedisHelperService } from "./redis-helper.service.js";
import { FlowSigner } from "./flow.signer.js";

export interface FlowContextOption {
  flowJSON: object;
  redisPrefix?: string;
}

export class FlowContext {
  // Static methods
  static async create(opt: FlowContextOption): Promise<FlowContext> {
    const ctx = new FlowContext(opt);
    await ctx.init();
    return ctx;
  }

  // Instance methods
  private readonly logger = pino({ name: "FlowContext" });
  private readonly flowService: FlowService;
  private readonly keyManagerService: KeyManagerService;
  private readonly redisHelperService: RedisHelperService;

  private constructor(opt: FlowContextOption) {
    this.flowService = new FlowService(opt.flowJSON);
    this.keyManagerService = new KeyManagerService();
    this.redisHelperService = new RedisHelperService({
      prefix: opt.redisPrefix,
    });
    this.logger.info("FlowContext created");
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
   * Get the redis helper service
   */
  get redisHelper(): RedisHelperService {
    return this.redisHelperService;
  }

  /**
   * Create a new flow signer
   */
  createNewSigner(): FlowSigner {
    return new FlowSigner(
      this.flowService,
      this.redisHelperService,
      this.keyManagerService
    );
  }
}
