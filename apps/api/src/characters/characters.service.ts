import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

import { CreateCharacterDto } from './characters.dto';

export type CharacterRecord = CreateCharacterDto & {
  id: string;
  ownerId: string;
  currentAssetVersion: number;
  createdAt: string;
};

@Injectable()
export class CharactersService {
  private readonly records = new Map<string, CharacterRecord>();
  private currentId?: string;

  list() {
    return { items: [...this.records.values()], currentId: this.currentId ?? null };
  }

  create(input: CreateCharacterDto) {
    const record: CharacterRecord = {
      ...input,
      color: input.color ?? '#78E7C7',
      id: randomUUID(),
      ownerId: 'user-demo',
      currentAssetVersion: 1,
      createdAt: new Date().toISOString(),
    };
    this.records.set(record.id, record);
    this.currentId ??= record.id;
    return record;
  }

  setCurrent(id: string) {
    if (!this.records.has(id)) throw new NotFoundException('角色不存在');
    this.currentId = id;
    return { currentId: id };
  }
}

