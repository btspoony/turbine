import { Redis } from "ioredis";
import type { NetworkType } from "./fcl.types";

export interface RedisHelperServiceOption {
  prefix?: string;
}

export class RedisHelperService {
  private readonly redis: Redis;
  private readonly network: NetworkType;
  private readonly prefix: string;

  constructor(opt: RedisHelperServiceOption) {
    this.network = (import.meta.env.FLOW_NETWORK as NetworkType) ?? "emulator";
    this.redis = new Redis(
      import.meta.env.REDIS_URL ?? {
        host: import.meta.env.REDIS_HOST ?? "localhost",
        port: parseInt(import.meta.env.REDIS_PORT ?? "6379"),
      }
    );
    this.prefix = opt.prefix ?? "FLOW";
  }

  /**
   * Execute a method or load from redis cache
   * @param methodKey
   * @param methodPromise
   */
  async executeOrLoadFromRedis<T>(
    methodKey: string,
    methodPromise: Promise<T>
  ): Promise<T> {
    if (!this.redis) {
      return await methodPromise;
    }

    const redisKey = `${this.prefix}:SERVICE_CACHE:${this.network}:KEY_VALUE:${methodKey}`;
    const cacheResult = await this.redis.get(redisKey);

    let result: T;
    if (!cacheResult) {
      result = await methodPromise;
      await this.redis.set(
        redisKey,
        typeof result === "string" ? result : JSON.stringify(result),
        "EX",
        1800 /* ex: half a hour */
      );
    } else {
      try {
        result = JSON.parse(cacheResult) as T;
      } catch (err) {
        result = cacheResult as T;
      }
    }
    return result;
  }

  /**
   * Push a key to redis pool
   * @param key
   * @param value
   * @param limit
   */
  async pushKeyToRedis(key: string, value: string) {
    const redisKeyPool = `${this.prefix}:SERVICE_POOL:${this.network}:DATA:${key}:SORTED_SET`;

    const now = Date.now();
    // set a timeout for key
    await this.redis.zadd(redisKeyPool, now, value);
  }

  /**
   * Fetch latest keys from redis pool
   * @param key
   * @param limit
   */
  async fetchLatestKeysFromRedis(
    key: string,
    limit?: number
  ): Promise<string[]> {
    if (!this.redis) {
      return [];
    }
    const redisKeyPool = `${this.prefix}:SERVICE_POOL:${this.network}:DATA:${key}:SORTED_SET`;
    // query last {limit} added values from redis
    return await this.redis.zrevrange(redisKeyPool, 0, limit ?? 20);
  }

  /**
   * Acquire a key index from redis pool
   */
  async acquireKeyIndex(
    address: string,
    max?: number,
    ttl: number = 1000 * 60 // 1 minute
  ): Promise<number> {
    max = max ?? parseInt(import.meta.env.FLOW_ACCOUNT_KEY_AMOUNT ?? "1");
    if (!this.redis) {
      return Math.floor(Math.random() * max);
    }

    const redisKeyPool = `${this.prefix}:SERVICE_POOL:${this.network}:ADDRESS:${address}:SORTED_SET`;
    const redisTotalAmountKey = `${this.prefix}:SERVICE_POOL:${this.network}:ADDRESS:${address}:KEY_VALUE`;

    const now = Date.now();
    const timeout = now + (ttl ?? 1000 * 60);
    const pair = await this.redis.zpopmin(redisKeyPool, 1);
    if (pair && pair.length === 2) {
      const [key, score] = pair;
      // set a timeout for key
      await this.redis.zadd(redisKeyPool, timeout, key);
      if (now - parseInt(score) >= 0) {
        // return key index
        return parseInt(key);
      }
    }
    // Need a new Key, check if reach max key?
    const currentKeyAmtStr = await this.redis.get(redisTotalAmountKey);
    const currentKeyAmt = parseInt(currentKeyAmtStr ?? "0");
    if (max > currentKeyAmt) {
      const p = this.redis.pipeline();
      p.incr(redisTotalAmountKey);
      p.zadd(redisKeyPool, timeout, currentKeyAmt.toString());
      await p.exec();
      // return current max key index
      return currentKeyAmt;
    } else {
      throw new Error("Reach max key amount.");
    }
  }

  async releaseKeyIndex(address: string, keyIndex: number) {
    if (!this.redis) return;

    const redisKeyPool = `${this.prefix}:SERVICE_POOL:${this.network}:ADDRESS:${address}:SORTED_SET`;

    // set a timeout for key
    await this.redis.zadd(redisKeyPool, Date.now(), keyIndex.toString());
  }
}
