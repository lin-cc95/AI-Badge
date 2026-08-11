import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

@Injectable()
export class ChatService {
  private readonly conversations = new Map<string, { id: string; characterId: string; messages: unknown[] }>();

  create(characterId: string) {
    const conversation = { id: randomUUID(), characterId, messages: [] };
    this.conversations.set(conversation.id, conversation);
    return conversation;
  }

  get(id: string) {
    const conversation = this.conversations.get(id);
    if (!conversation) throw new NotFoundException('会话不存在');
    return conversation;
  }

  addUserMessage(id: string, content: string) {
    const conversation = this.get(id);
    const message = { id: randomUUID(), role: 'user', content, createdAt: new Date().toISOString() };
    conversation.messages.push(message);
    return message;
  }

  addAssistantMessage(id: string, content: string, emotion: string) {
    const conversation = this.get(id);
    const message = { id: randomUUID(), role: 'assistant', content, emotion, moderationStatus: 'PASSED', createdAt: new Date().toISOString() };
    conversation.messages.push(message);
    return message;
  }
}

