import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable, of, tap } from 'rxjs';
import type { Request } from 'express';

@Injectable()
export class IdempotencyInterceptor implements NestInterceptor {
  private readonly cache = new Map<string, unknown>();

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest<Request>();
    if (!['POST', 'PUT', 'PATCH'].includes(request.method)) return next.handle();
    const idempotencyKey = request.header('idempotency-key');
    if (!idempotencyKey) return next.handle();
    const key = `${request.method}:${request.path}:${idempotencyKey}`;
    if (this.cache.has(key)) return of(this.cache.get(key));
    return next.handle().pipe(tap((value) => {
      this.cache.set(key, value);
      if (this.cache.size > 1000) this.cache.delete(this.cache.keys().next().value as string);
    }));
  }
}

