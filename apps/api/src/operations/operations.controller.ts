import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { createHash, randomUUID } from 'node:crypto';

import { DiagnosticDto, TelemetryDto } from './operations.dto';

@ApiTags('operations')
@Controller()
export class OperationsController {
  @Get('assets')
  assets() {
    return { items: [], storagePolicy: 'private-signed-url', maxAgeSeconds: 900 };
  }

  @Get('assets/demo/:name')
  demoAsset(@Param('name') name: string) {
    return { id: name, type: 'character-preview', placeholder: true, color: '#78E7C7' };
  }

  @Get('firmware')
  firmware() {
    return { current: '0.1.0-sim', latest: '0.1.0-sim', required: false, compatibleModels: ['SIM-240'] };
  }

  @Post('diagnostics')
  diagnostics(@Body() input: DiagnosticDto) {
    return {
      diagnosticId: randomUUID(),
      accepted: true,
      deviceIdHash: createHash('sha256').update(input.deviceId).digest('hex').slice(0, 16),
      includedFields: input.includedFields,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
    };
  }

  @Post('telemetry/events')
  telemetry(@Body() input: TelemetryDto) {
    return { accepted: true, eventId: randomUUID(), name: input.name };
  }
}

