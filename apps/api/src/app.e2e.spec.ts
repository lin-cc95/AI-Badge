import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';

import { AppModule } from './app.module';
import { ApiErrorFilter } from './common/api-error.filter';

describe('AI Badge API vertical slice', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = module.createNestApplication();
    app.setGlobalPrefix('v1');
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true, forbidNonWhitelisted: true }));
    app.useGlobalFilters(new ApiErrorFilter());
    await app.init();
  });

  afterAll(async () => app?.close());

  it('rejects protected resources with the standard error envelope', async () => {
    const response = await request(app.getHttpServer()).get('/v1/devices').expect(401);
    expect(response.body.code).toBe('AUTH-401');
    expect(response.body.retryable).toBe(false);
  });

  it('logs in and completes an asynchronous generation task', async () => {
    const auth = await request(app.getHttpServer())
      .post('/v1/auth/login')
      .send({ username: 'demo', password: 'Badge123!test' })
      .expect(201);
    const created = await request(app.getHttpServer())
      .post('/v1/generation-tasks')
      .set('Authorization', `Bearer ${auth.body.accessToken}`)
      .set('Idempotency-Key', 'e2e-generation-1')
      .send({ styleId: 'soft', personaId: 'energetic', tags: ['mint'] })
      .expect(201);
    await new Promise((resolve) => setTimeout(resolve, 1900));
    const task = await request(app.getHttpServer())
      .get(`/v1/generation-tasks/${created.body.id}`)
      .set('Authorization', `Bearer ${auth.body.accessToken}`)
      .expect(200);
    expect(task.body.status).toBe('SUCCEEDED');
    expect(task.body.results).toHaveLength(3);
  });
});
