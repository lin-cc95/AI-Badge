import { Controller, Get, Header, Headers, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiExcludeEndpoint } from '@nestjs/swagger';
import { collectDefaultMetrics, register } from 'prom-client';
import { timingSafeEqual } from 'node:crypto';

import { Public } from '../common/public.decorator';

let metricsStarted = false;

@Controller()
export class HealthController {
  constructor(private readonly config: ConfigService) {
    if (this.metricsEnabled() && !metricsStarted) {
      collectDefaultMetrics({ prefix: 'ai_badge_' });
      metricsStarted = true;
    }
  }

  @Public()
  @Get('health')
  health() {
    return { status: 'ok', service: 'ai-badge-api', timestamp: new Date().toISOString() };
  }

  @Public()
  @ApiExcludeEndpoint()
  @Get('metrics')
  @Header('Content-Type', register.contentType)
  metrics(@Headers('x-metrics-token') providedToken?: string) {
    if (!this.metricsEnabled()) throw new NotFoundException('指标端点未启用');
    const expectedToken = this.config.getOrThrow<string>('METRICS_TOKEN');
    if (!providedToken || !this.matches(providedToken, expectedToken)) {
      throw new UnauthorizedException('指标访问令牌无效');
    }
    return register.metrics();
  }

  private metricsEnabled(): boolean {
    return this.config.get<string>('EXPOSE_METRICS', 'false').toLowerCase() === 'true';
  }

  private matches(left: string, right: string): boolean {
    const leftBytes = Buffer.from(left);
    const rightBytes = Buffer.from(right);
    return leftBytes.length === rightBytes.length && timingSafeEqual(leftBytes, rightBytes);
  }
}
