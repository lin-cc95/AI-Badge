import { Controller, Get, Header } from '@nestjs/common';
import { ApiExcludeEndpoint } from '@nestjs/swagger';
import { collectDefaultMetrics, register } from 'prom-client';

import { Public } from '../common/public.decorator';

let metricsStarted = false;

@Controller()
export class HealthController {
  constructor() {
    if (!metricsStarted) {
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
  metrics() { return register.metrics(); }
}

