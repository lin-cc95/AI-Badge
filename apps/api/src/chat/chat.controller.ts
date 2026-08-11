import { Body, Controller, Get, Param, Post, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';

import { CreateConversationDto, SendMessageDto } from './chat.dto';
import { ChatService } from './chat.service';

@ApiTags('chat')
@Controller('conversations')
export class ChatController {
  constructor(private readonly chat: ChatService) {}

  @Post()
  create(@Body() input: CreateConversationDto) { return this.chat.create(input.characterId); }

  @Get(':id')
  get(@Param('id') id: string) { return this.chat.get(id); }

  @Post(':id/messages/stream')
  async stream(@Param('id') id: string, @Body() input: SendMessageDto, @Res() response: Response) {
    this.chat.addUserMessage(id, input.content);
    response.status(200);
    response.setHeader('Content-Type', 'text/event-stream; charset=utf-8');
    response.setHeader('Cache-Control', 'no-cache, no-transform');
    response.setHeader('Connection', 'keep-alive');
    response.flushHeaders();
    const chunks = ['我在呢！', '今天也一起把心情', '调成薄荷味吧。'];
    for (const [index, chunk] of chunks.entries()) {
      response.write(`event: message.delta\ndata: ${JSON.stringify({ index, delta: chunk })}\n\n`);
      await new Promise((resolve) => setTimeout(resolve, 140));
    }
    const message = this.chat.addAssistantMessage(id, chunks.join(''), 'happy');
    response.write(`event: message.completed\ndata: ${JSON.stringify(message)}\n\n`);
    response.end();
  }
}

