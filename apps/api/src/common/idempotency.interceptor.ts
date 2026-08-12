import { CallHandler, ConflictException, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { createHash } from 'node:crypto';
import type { Request } from 'express';
import { Observable, of, tap } from 'rxjs';

type AuthenticatedRequest = Request & { user?: { sub: string } };
type CacheEntry = { fingerprint: string; response: unknown; expiresAt: number };

@Injectable()
export class IdempotencyInterceptor implements NestInterceptor {
  private readonly cache = new Map<string, CacheEntry>();
  private readonly ttlMs = 24 * 60 * 60 * 1000;
  private readonly maxEntries = 1000;

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    if (!['POST', 'PUT', 'PATCH'].includes(request.method)) return next.handle();
    const idempotencyKey = request.header('idempotency-key');
    const userId = request.user?.sub;
    if (!idempotencyKey || !userId) return next.handle();

    this.removeExpired();
    const key = `${userId}:${request.method}:${request.path}:${idempotencyKey}`;
    const fingerprint = this.fingerprint(request.body);
    const cached = this.cache.get(key);
    if (cached) {
      if (cached.fingerprint !== fingerprint) {
        throw new ConflictException('同一个 Idempotency-Key 不能用于不同请求内容');
      }
      return of(cached.response);
    }

    return next.handle().pipe(tap((response) => {
      this.cache.set(key, { fingerprint, response, expiresAt: Date.now() + this.ttlMs });
      while (this.cache.size > this.maxEntries) {
        this.cache.delete(this.cache.keys().next().value as string);
      }
    }));
  }

  private fingerprint(body: unknown): string {
    return createHash('sha256').update(JSON.stringify(this.normalize(body))).digest('hex');
  }

  private normalize(value: unknown): unknown {
    if (Array.isArray(value)) return value.map((item) => this.normalize(item));
    if (value && typeof value === 'object') {
      return Object.fromEntries(
        Object.entries(value as Record<string, unknown>)
          .sort(([left], [right]) => left.localeCompare(right))
          .map(([key, item]) => [key, this.normalize(item)]),
      );
    }
    return value;
  }

  private removeExpired(): void {
    const now = Date.now();
    for (const [key, entry] of this.cache) {
      if (entry.expiresAt <= now) this.cache.delete(key);
    }
  }
}
