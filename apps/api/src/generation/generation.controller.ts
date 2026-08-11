import { Body, Controller, Get, Param, Post, Sse } from '@nestjs/common';
import type { MessageEvent } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Observable } from 'rxjs';

import { CreateGenerationTaskDto } from './generation.dto';
import { GenerationService } from './generation.service';

@ApiTags('generation')
@Controller('generation-tasks')
export class GenerationController {
  constructor(private readonly generation: GenerationService) {}
  @Post() create(@Body() input: CreateGenerationTaskDto) { return this.generation.create(input); }
  @Get(':id') get(@Param('id') id: string) { return this.generation.get(id); }
  @Sse(':id/events') events(@Param('id') id: string): Observable<MessageEvent> { return this.generation.events(id); }
  @Post(':id/cancel') cancel(@Param('id') id: string) { return this.generation.cancel(id); }
}
