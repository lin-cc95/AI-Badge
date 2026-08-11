import { Injectable, NotFoundException } from '@nestjs/common';
import type { MessageEvent } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { BehaviorSubject, Observable } from 'rxjs';

import { CreateGenerationTaskDto } from './generation.dto';

type GenerationStatus = 'QUEUED' | 'GENERATING' | 'MODERATING' | 'SUCCEEDED' | 'FAILED_RETRYABLE' | 'FAILED_FINAL' | 'CANCELLED';
type GenerationTask = {
  id: string;
  status: GenerationStatus;
  progress: number;
  input: CreateGenerationTaskDto;
  results: Array<{ id: string; name: string; color: string; previewUrl: string }>;
  createdAt: string;
};

@Injectable()
export class GenerationService {
  private readonly tasks = new Map<string, GenerationTask>();
  private readonly streams = new Map<string, BehaviorSubject<MessageEvent>>();

  create(input: CreateGenerationTaskDto) {
    const id = randomUUID();
    const task: GenerationTask = { id, status: 'QUEUED', progress: 0.05, input, results: [], createdAt: new Date().toISOString() };
    this.tasks.set(id, task);
    const stream = new BehaviorSubject<MessageEvent>({ data: task, type: 'generation.progress', id });
    this.streams.set(id, stream);
    this.advance(id, 350, 'GENERATING', 0.35);
    this.advance(id, 850, 'GENERATING', 0.72);
    this.advance(id, 1350, 'MODERATING', 0.9);
    setTimeout(() => {
      const current = this.mustGet(id);
      current.status = 'SUCCEEDED';
      current.progress = 1;
      current.results = [
        { id: `${id}-a`, name: '桃桃', color: '#F5A6D9', previewUrl: `/v1/assets/demo/${id}-a.png` },
        { id: `${id}-b`, name: '米露', color: '#78E7C7', previewUrl: `/v1/assets/demo/${id}-b.png` },
        { id: `${id}-c`, name: '泡泡', color: '#89DDF0', previewUrl: `/v1/assets/demo/${id}-c.png` },
      ];
      this.emit(current);
      this.streams.get(id)?.complete();
    }, 1850);
    return task;
  }

  get(id: string) { return this.mustGet(id); }

  events(id: string): Observable<MessageEvent> {
    this.mustGet(id);
    return this.streams.get(id)!.asObservable();
  }

  cancel(id: string) {
    const task = this.mustGet(id);
    if (task.status === 'SUCCEEDED') return task;
    task.status = 'CANCELLED';
    this.emit(task);
    this.streams.get(id)?.complete();
    return task;
  }

  private advance(id: string, delay: number, status: GenerationStatus, progress: number) {
    setTimeout(() => {
      const task = this.tasks.get(id);
      if (!task || task.status === 'CANCELLED') return;
      task.status = status;
      task.progress = progress;
      this.emit(task);
    }, delay);
  }

  private emit(task: GenerationTask) {
    this.streams.get(task.id)?.next({ data: { ...task }, type: 'generation.progress', id: task.id });
  }

  private mustGet(id: string) {
    const task = this.tasks.get(id);
    if (!task) throw new NotFoundException('生成任务不存在');
    return task;
  }
}
