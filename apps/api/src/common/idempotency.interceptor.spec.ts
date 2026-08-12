import { CallHandler, ExecutionContext } from '@nestjs/common';
import { firstValueFrom, of } from 'rxjs';

import { IdempotencyInterceptor } from './idempotency.interceptor';

function context(userId: string, body: unknown): ExecutionContext {
  const request = {
    method: 'POST',
    path: '/characters',
    body,
    user: { sub: userId },
    header: (name: string) => name.toLowerCase() === 'idempotency-key' ? 'same-key' : undefined,
  };
  return {
    switchToHttp: () => ({ getRequest: () => request }),
  } as unknown as ExecutionContext;
}

describe('IdempotencyInterceptor', () => {
  it('isolates cached responses by authenticated user', async () => {
    const interceptor = new IdempotencyInterceptor();
    const first: CallHandler = { handle: () => of({ owner: 'first-user' }) };
    const second: CallHandler = { handle: () => of({ owner: 'second-user' }) };

    await expect(firstValueFrom(interceptor.intercept(context('user-a', { name: '桃桃' }), first)))
      .resolves.toEqual({ owner: 'first-user' });
    await expect(firstValueFrom(interceptor.intercept(context('user-b', { name: '桃桃' }), second)))
      .resolves.toEqual({ owner: 'second-user' });
  });

  it('rejects reusing a key for a different request body', async () => {
    const interceptor = new IdempotencyInterceptor();
    const handler: CallHandler = { handle: () => of({ id: 'created' }) };
    await firstValueFrom(interceptor.intercept(context('user-a', { name: '桃桃' }), handler));

    expect(() => interceptor.intercept(context('user-a', { name: '泡泡' }), handler))
      .toThrow('同一个 Idempotency-Key 不能用于不同请求内容');
  });
});
