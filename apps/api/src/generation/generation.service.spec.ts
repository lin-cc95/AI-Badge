import { GenerationService } from './generation.service';

describe('GenerationService', () => {
  beforeEach(() => jest.useFakeTimers());
  afterEach(() => jest.useRealTimers());

  it('moves a mock task to succeeded with three candidates', () => {
    const service = new GenerationService();
    const task = service.create({ styleId: 'soft', personaId: 'energetic', tags: ['mint'] });
    expect(task.status).toBe('QUEUED');
    jest.advanceTimersByTime(1900);
    const complete = service.get(task.id);
    expect(complete.status).toBe('SUCCEEDED');
    expect(complete.results).toHaveLength(3);
  });
});

