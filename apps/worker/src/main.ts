import { Worker } from 'bullmq';
import IORedis from 'ioredis';

import { ConfigurableRestProvider, DeterministicMockProvider, ImageGenerationProvider, ModerationProvider } from './providers/ai-provider';

const redisUrl = process.env.REDIS_URL ?? 'redis://localhost:6379';
const connection = new IORedis(redisUrl, { maxRetriesPerRequest: null });
const mock = new DeterministicMockProvider();
const rest = new ConfigurableRestProvider(
  process.env.AI_BASE_URL ?? '',
  process.env.AI_API_KEY ?? '',
  process.env.IMAGE_MODEL ?? '',
  process.env.MODERATION_MODEL ?? '',
);

const generationWorker = new Worker('generation', async (job) => {
  const provider: ImageGenerationProvider & ModerationProvider = process.env.AI_PROVIDER === 'rest' ? rest : mock;
  await job.updateProgress(10);
  const results = await provider.generate(job.data);
  await job.updateProgress(75);
  const moderation = await provider.check({ assetKeys: results.map((item) => item.assetKey) });
  if (!moderation.allowed) throw new Error(`MODERATION_REJECTED:${moderation.reason ?? 'unknown'}`);
  await job.updateProgress(100);
  return { results, moderationStatus: 'PASSED' };
}, { connection, concurrency: 2 });

generationWorker.on('completed', (job) => console.info(JSON.stringify({ level: 'info', event: 'generation.completed', jobId: job.id })));
generationWorker.on('failed', (job, error) => console.error(JSON.stringify({ level: 'error', event: 'generation.failed', jobId: job?.id, error: error.message })));

const shutdown = async () => {
  await generationWorker.close();
  await connection.quit();
};

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
