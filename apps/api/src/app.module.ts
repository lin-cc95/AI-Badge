import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';

import { AuthModule } from './auth/auth.module';
import { CharactersModule } from './characters/characters.module';
import { ChatModule } from './chat/chat.module';
import { JwtAuthGuard } from './common/jwt-auth.guard';
import { IdempotencyInterceptor } from './common/idempotency.interceptor';
import { DevicesModule } from './devices/devices.module';
import { GenerationModule } from './generation/generation.module';
import { HealthModule } from './health/health.module';
import { OperationsModule } from './operations/operations.module';
import { PersonasModule } from './personas/personas.module';
import { validateEnvironment } from './config/environment';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, validate: validateEnvironment }),
    JwtModule.registerAsync({
      global: true,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({ secret: config.getOrThrow<string>('JWT_SECRET') }),
    }),
    AuthModule,
    PersonasModule,
    CharactersModule,
    GenerationModule,
    DevicesModule,
    ChatModule,
    HealthModule,
    OperationsModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_INTERCEPTOR, useClass: IdempotencyInterceptor },
  ],
})
export class AppModule {}
