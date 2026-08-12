import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import type { NextFunction, Request, Response } from 'express';
import { randomUUID } from 'node:crypto';

import { AppModule } from './app.module';
import { ApiErrorFilter } from './common/api-error.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: false });
  const environment = app.get(ConfigService);
  const corsOrigins = environment.get<string>('CORS_ORIGINS', '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  if (corsOrigins.length > 0) {
    app.enableCors({ origin: corsOrigins, credentials: false });
  }
  app.enableShutdownHooks();
  app.setGlobalPrefix('v1');
  app.use((request: Request & { requestId?: string }, response: Response, next: NextFunction) => {
    request.requestId = request.header('x-request-id') ?? randomUUID();
    response.setHeader('x-request-id', request.requestId);
    response.setHeader('x-content-type-options', 'nosniff');
    response.setHeader('referrer-policy', 'no-referrer');
    response.setHeader('cache-control', 'no-store');
    next();
  });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true, forbidNonWhitelisted: true }));
  app.useGlobalFilters(new ApiErrorFilter());
  if (environment.get<string>('ENABLE_SWAGGER', 'false').toLowerCase() === 'true') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('AI Badge API')
      .setDescription('AI 吧唧本地演示 API')
      .setVersion('0.1.0')
      .addBearerAuth()
      .build();
    SwaggerModule.setup('v1/docs', app, SwaggerModule.createDocument(app, swaggerConfig), {
      jsonDocumentUrl: 'v1/openapi.json',
    });
  }
  await app.listen(Number(process.env.PORT ?? 3000), process.env.HOST ?? '127.0.0.1');
}

void bootstrap();
